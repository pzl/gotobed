package main

import (
	"context"
	"encoding/json"
	"errors"
	"sync"
	"time"

	"github.com/sirupsen/logrus"
)

type Action struct {
	ID    string    `json:"id,omitempty"`
	State State     `json:"state"`
	T     time.Time `json:"time"`
}

func (a Action) MarshalJSON() ([]byte, error) {
	JSAction := struct {
		ID    string `json:"id,omitempty"`
		State State  `json:"state"`
		T     int64  `json:"time"`
	}{
		ID:    a.ID,
		State: a.State,
		T:     a.T.Unix(),
	}
	return json.Marshal(JSAction)
}

func (a *Action) UnmarshalJSON(data []byte) error {
	var j struct {
		ID    string `json:"id,omitempty"`
		State State  `json:"state"`
		T     int64  `json:"time"`
	}
	if err := json.Unmarshal(data, &j); err != nil {
		return err
	}

	a.ID = j.ID
	a.State = j.State
	a.T = time.Unix(j.T, 0)
	return nil
}

type Scheduler struct {
	add   chan TimerRequest
	sched map[string]Timer
	p     Pins
	l     *logrus.Logger
	mu    sync.Mutex
}

type Timer struct {
	A      Action
	T      *time.Timer
	C      context.Context
	cancel func()
}

type TimerRequest struct {
	T  Timer
	OK chan struct{}
}

func NewScheduler(p Pins, log *logrus.Logger) (*Scheduler, error) {
	s := Scheduler{
		sched: make(map[string]Timer),
		add:   make(chan TimerRequest),
		p:     p,
		l:     log,
		mu:    sync.Mutex{},
	}

	return &s, nil
}

func (s *Scheduler) Start(ctx context.Context) error {
	for {
		select {
		case tr := <-s.add:
			t := tr.T
			t.C, t.cancel = context.WithCancel(ctx)
			s.mu.Lock()
			s.sched[t.A.ID] = t
			s.mu.Unlock()
			tr.OK <- struct{}{}
			go func() {
				defer t.cancel() // clean up regardless
				s.l.Debug("spawned timer waiter thread")
				select {
				case <-t.T.C:
					s.l.Debug("timer expired for action, performing state change")
					setState(t.A.State, s.p)
					s.mu.Lock()
					delete(s.sched, t.A.ID)
					s.mu.Unlock()
				case <-t.C.Done():
					s.l.Debug("timer canceled, not performing changes")
				}
			}()
		case <-ctx.Done():
			return nil
		}
	}
}

func (s *Scheduler) Get() ([]Action, error) {
	s.mu.Lock()
	a := make([]Action, 0, len(s.sched))
	for _, k := range s.sched {
		a = append(a, k.A)
	}
	s.mu.Unlock()
	return a, nil
}

func (s *Scheduler) Delete(id string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	t, ok := s.sched[id]
	if !ok {
		return errors.New("no such timer")
	}
	// stop timer, cancel listener, remove from schedule
	t.T.Stop()
	t.cancel()
	delete(s.sched, id)
	return nil
}

func (s *Scheduler) Add(a Action) error {
	// time check
	if a.T.Before(time.Now()) {
		return errors.New("action has passed")
	}

	// send timer, wait for it to be added to the schedule and return
	tr := TimerRequest{
		T: Timer{
			A: a,
			T: time.NewTimer(a.T.Sub(time.Now())),
		},
		OK: make(chan struct{}),
	}
	s.add <- tr
	<-tr.OK
	return nil
}

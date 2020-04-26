package main

import (
	"context"
	"time"

	"github.com/sirupsen/logrus"
)

type Action struct {
	ID    string    `json:"id,omitempty"`
	State State     `json:"state"`
	T     time.Time `json:"time"`
}

type Scheduler struct {
	addTimer chan Action
	delTimer chan string
	sched    map[string]Timer
	p        Pins
	l        *logrus.Logger
}

type Timer struct {
	A      Action
	T      *time.Timer
	C      context.Context
	cancel func()
}

func NewScheduler(p Pins, log *logrus.Logger) (Scheduler, error) {
	s := Scheduler{
		sched:    make(map[string]Timer),
		addTimer: make(chan Action),
		delTimer: make(chan string),
		p:        p,
		l:        log,
	}

	return s, nil
}

func (s *Scheduler) Start(ctx context.Context) error {
	for {
		select {
		case a := <-s.addTimer:
			if a.T.Before(time.Now()) {
				s.l.WithField("action_time", a.T).Debug("requested time is before current time. Ignoring request")
				continue
			}
			s.l.Debug("creating timer")
			diff := a.T.Sub(time.Now())
			s.l.WithField("diff", diff).Info("timer difference")
			t := time.NewTimer(a.T.Sub(time.Now()))
			c, cancel := context.WithCancel(ctx)
			s.sched[a.ID] = Timer{A: a, T: t, C: c, cancel: cancel}
			go func() {
				s.l.Debug("spawned timer waiter thread")
				select {
				case <-t.C:
					s.l.Debug("timer expired for action, performing state change")
					setState(a.State, s.p)
					delete(s.sched, a.ID)
				case <-c.Done():
					s.l.Debug("timer change canceled. Listener exiting")
					// timer canceled. exit goroutine
				}
			}()
		case id := <-s.delTimer:
			t, ok := s.sched[id]
			if !ok {
				continue
			}
			// stop timer, cancel listener, remove from schedule
			t.T.Stop()
			t.cancel()
			delete(s.sched, id)
		case <-ctx.Done():
			return nil
		}
	}
}

func (s *Scheduler) Get() ([]Action, error) {
	a := make([]Action, 0, len(s.sched))
	for _, k := range s.sched {
		a = append(a, k.A)
	}
	return a, nil
}

func (s *Scheduler) Delete(id string) error {
	s.delTimer <- id
	return nil
}

func (s *Scheduler) Add(a Action) error {
	s.addTimer <- a
	return nil
}

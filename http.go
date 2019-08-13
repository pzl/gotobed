package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/go-chi/chi"
	"github.com/go-chi/chi/middleware"
	"github.com/pzl/mstk"
	"github.com/pzl/mstk/logger"
	"github.com/sirupsen/logrus"
)

type State struct {
	Red    bool `json:"red"`
	Yellow bool `json:"yellow"`
	Green  bool `json:"green"`
	Lamp   bool `json:"lamp"`
}

func setLog(s *mstk.Server) { s.Log = log }

func HTTP(ctx context.Context, log *logrus.Logger, pins Pins) {
	s := mstk.NewServer(mstk.Addr(":80"), setLog)

	r := chi.NewRouter()
	routes(r, log, pins)
	s.Http.Handler = r

	if err := s.Start(ctx); err != nil {
		log.WithError(err).Error("server error")
	}
	c, _ := context.WithTimeout(context.Background(), 2*time.Second)
	defer s.Shutdown(c)
}

func routes(r *chi.Mux, log *logrus.Logger, pins Pins) {
	r.Use(
		middleware.RealIP, // X-Forwarded-For
		middleware.RequestID,
		middleware.RequestLogger(logger.NewChi(log)),
		middleware.Heartbeat("/ping"),
		middleware.Recoverer,
	)

	r.Get("/state", func(w http.ResponseWriter, r *http.Request) {
		s, err := getState(pins)
		if err != nil {
			writeErr(w, r, err, "error fetching state", logrus.Fields{})
			return
		}
		writeJSON(w, r, s)
	})
	r.Post("/state", func(w http.ResponseWriter, r *http.Request) {
		var req State
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			writeErr(w, r, err, "decoding request JSON failed", logrus.Fields{})
			return
		}

		log := logger.GetLog(r)
		log.WithField("state", req).Debug("setting state")
		if err := setState(req, pins); err != nil {
			writeErr(w, r, err, "error setting state", logrus.Fields{})
			return
		}

		s, err := getState(pins)
		if err != nil {
			writeErr(w, r, err, "error fetching state", logrus.Fields{})
			return
		}

		writeJSON(w, r, s)
	})
	r.Get("/schedule", todo)
	r.Post("/schedule", todo)

	r.Get("/static/*", func(w http.ResponseWriter, r *http.Request) {
		http.StripPrefix("/static/", http.FileServer(http.Dir("web/dist"))).ServeHTTP(w, r)
	})

	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "web/dist/index.html")
	})
}

func todo(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("todo"))
}

func writeJSON(w http.ResponseWriter, r *http.Request, v interface{}) {
	var buf bytes.Buffer
	enc := json.NewEncoder(&buf)
	enc.SetEscapeHTML(true)

	if err := enc.Encode(v); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		/*
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte("{\"error\": \"unable to show response\"}"))
		*/
		return
	}

	w.Header().Set("Content-Type", "application/json")
	_, err := w.Write(buf.Bytes())
	if err != nil {
		log := logger.GetLog(r)
		log.WithError(err).Error("unable to printing JSON")
	}
}

func writeErr(w http.ResponseWriter, r *http.Request, err error, msg string, f logrus.Fields) {
	log := logger.GetLog(r)
	log.WithError(err).WithFields(f).Error(msg)
	w.WriteHeader(http.StatusInternalServerError)
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(fmt.Sprintf("{\"error\":\"%s: %s\"}", msg, err.Error())))
	return
}

func getState(pins Pins) (State, error) {
	var err error
	var s State
	if s.Red, err = Pin(pins.Red).Get(); err != nil {
		return s, fmt.Errorf("error fetching state for pin %d: %v", pins.Red, err)
	}
	if s.Green, err = Pin(pins.Green).Get(); err != nil {
		return s, fmt.Errorf("error fetching state for pin %d: %v", pins.Green, err)
	}
	if s.Yellow, err = Pin(pins.Yellow).Get(); err != nil {
		return s, fmt.Errorf("error fetching state for pin %d: %v", pins.Yellow, err)
	}
	if s.Lamp, err = Pin(pins.Lamp).Get(); err != nil {
		return s, fmt.Errorf("error fetching state for pin %d: %v", pins.Lamp, err)
	}
	return s, nil
}

func setState(s State, pins Pins) error {
	if err := Pin(pins.Red).Set(s.Red); err != nil {
		return fmt.Errorf("error setting state for pin %d: %v", pins.Red, err)
	}
	if err := Pin(pins.Yellow).Set(s.Yellow); err != nil {
		return fmt.Errorf("error setting state for pin %d: %v", pins.Yellow, err)
	}
	if err := Pin(pins.Green).Set(s.Green); err != nil {
		return fmt.Errorf("error setting state for pin %d: %v", pins.Green, err)
	}
	if err := Pin(pins.Lamp).Set(s.Lamp); err != nil {
		return fmt.Errorf("error setting state for pin %d: %v", pins.Lamp, err)
	}
	return nil
}

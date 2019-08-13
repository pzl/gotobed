package main

import (
	"context"
	"os"
	"os/signal"
	"sync"
	"syscall"

	"github.com/pzl/mstk"
	"github.com/sirupsen/logrus"
	"github.com/spf13/pflag"
)

var log *logrus.Logger

type Pins struct {
	Red    int
	Green  int
	Yellow int
	Lamp   int
}

func main() {
	pins, l, err := config()
	if err != nil {
		panic(err)
	}
	log = l

	cleanup, err := setupPins(pins, l)
	defer cleanup()
	if err != nil {
		panic(err)
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	go func() {
		sigint := make(chan os.Signal, 1)
		signal.Notify(sigint, os.Interrupt, os.Kill, syscall.SIGQUIT)
		<-sigint
		cancel()
	}()

	var wg sync.WaitGroup

	wg.Add(1)
	go func() {
		HTTP(ctx, l, pins)
		log.Info("HTTP service exited")
		wg.Done()
	}()

	wg.Wait()
	log.Info("service shutdown")
}

func config() (Pins, *logrus.Logger, error) {
	var p Pins

	conf := mstk.NewConfig("gotobed")
	conf.Log.Debug("reading configs")
	conf.SetFlags(func(p *pflag.FlagSet) {
		pins := pflag.NewFlagSet("pins", pflag.ExitOnError)
		pins.SortFlags = false
		pins.IntP("red", "r", 4, "red light GPIO Pin")
		pins.IntP("yellow", "y", 17, "red light GPIO Pin")
		pins.IntP("green", "g", 18, "green light GPIO Pin")
		pins.IntP("lamp", "l", 27, "red light GPIO Pin")

		p.SortFlags = false
		p.AddFlagSet(pins)
		p.AddFlagSet(mstk.CommonFlags())
	})
	if err := conf.Parse(); err != nil {
		return p, conf.Log, err
	}
	if err := conf.K.Unmarshal("", &p); err != nil {
		return p, conf.Log, err
	}
	conf.Log.WithFields(logrus.Fields{
		"red":    p.Red,
		"green":  p.Green,
		"yellow": p.Yellow,
		"lamp":   p.Lamp,
	}).Info("gpio pin numbers parsed")

	return p, conf.Log, nil
}

func setupPins(p Pins, log *logrus.Logger) (func(), error) {
	log.Debug("setting up pins")
	enabled := make([]int, 0, 4)
	cleanup := func() {
		log.WithField("enabled", enabled).Debug("cleaning up gpio pins")
		for _, e := range enabled {
			log.WithField("pin", Pin(e).Pin()).Trace("unexporting pin")
			if err := Pin(e).Disable(); err != nil {
				log.WithError(err).WithField("pin", Pin(e).Pin()).Error("error unexporting pin")
			}
		}
	}

	pins := []int{p.Red, p.Yellow, p.Green, p.Lamp}
	for _, pno := range pins {
		if err := Pin(pno).Enable(); err != nil {
			return cleanup, err
		}
		enabled = append(enabled, pno)
		if err := Pin(pno).Direction("out"); err != nil {
			return cleanup, err
		}
	}

	return cleanup, nil
}

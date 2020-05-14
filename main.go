package main

//go:generate go run -tags generate assets_gen.go

import (
	"context"
	"os"
	"os/signal"
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
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	go func() {
		sigint := make(chan os.Signal, 1)
		signal.Notify(sigint, os.Interrupt, os.Kill, syscall.SIGQUIT)
		<-sigint
		cancel()
	}()

	cfg, l, err := config()
	if err != nil {
		panic(err)
	}
	log = l

	if err := setupPins(cfg.Pins, l); err != nil {
		panic(err)
	}
	defer cleanupPins(cfg.Pins, l)

	sch, err := NewScheduler(cfg.Pins, l)
	if err != nil {
		panic(err)
	}

	go func() {
		if err := sch.Start(ctx); err != nil {
			log.WithError(err).Error("got error running scheduler")
		}
	}()

	// todo: advertise IP over zerconf?
	// todo: how to accept wifi credentials when traveling

	HTTP(ctx, l, cfg, sch)
	log.Info("HTTP service exited")
	cancel()
	log.Info("service shutdown")
}

type Config struct {
	Pins
	Port int
}

func config() (Config, *logrus.Logger, error) {
	var c struct {
		Red    int
		Green  int
		Yellow int
		Lamp   int
		Port   int
	}

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
		p.IntP("port", "p", 8088, "HTTP listening port")
	})
	if err := conf.Parse(); err != nil {
		return Config{}, conf.Log, err
	}
	if err := conf.K.Unmarshal("", &c); err != nil {
		return Config{}, conf.Log, err
	}

	conf.Log.WithField("config", c).Info("parsed")

	conf.Log.WithFields(logrus.Fields{
		"red":    c.Red,
		"green":  c.Green,
		"yellow": c.Yellow,
		"lamp":   c.Lamp,
	}).Info("gpio pin numbers parsed")

	cfg := Config{
		Pins: Pins{
			Red:    c.Red,
			Yellow: c.Yellow,
			Green:  c.Green,
			Lamp:   c.Lamp,
		},
		Port: c.Port,
	}

	return cfg, conf.Log, nil
}

func setupPins(p Pins, log *logrus.Logger) error {
	cleanupPins(p, log) // cleanup previous state

	log.Debug("setting up pins")
	pins := []int{p.Red, p.Yellow, p.Green, p.Lamp}
	for _, pno := range pins {
		if err := Pin(pno).Enable(); err != nil {
			return err
		}
		if err := Pin(pno).Direction("out"); err != nil {
			return err
		}
	}

	return nil
}

func cleanupPins(p Pins, log *logrus.Logger) {
	pins := []int{p.Red, p.Yellow, p.Green, p.Lamp}
	log.WithField("pins", pins).Debug("cleaning up gpio pins")
	for _, pn := range pins {
		log.WithField("pin", Pin(pn).Pin()).Trace("unexporting pin")
		if err := Pin(pn).Disable(); err != nil {
			log.WithError(err).WithField("pin", Pin(pn).Pin()).Error("error unexporting pin")
		}
	}
	return
}

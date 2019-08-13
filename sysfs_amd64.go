package main

import (
	"strconv"
)

// simulate
var curstate = make(map[Pin]bool)

type Pin int

func (p Pin) Pin() string { return strconv.Itoa(int(p)) }
func (p Pin) Enable() error {
	log.WithField("pin", p.Pin()).Trace("pin enabled")
	return nil
}
func (p Pin) Disable() error {
	log.WithField("pin", p.Pin()).Trace("pin disabled")
	return nil
}
func (p Pin) Direction(d string) error {
	log.WithField("pin", p.Pin()).WithField("direction", d).Trace("pin direction set")
	return nil
}
func (p Pin) Set(b bool) error {
	curstate[p] = b
	return nil
}
func (p Pin) Get() (bool, error) {
	if v, ok := curstate[p]; !ok {
		return false, nil
	} else {
		return v, nil
	}
}

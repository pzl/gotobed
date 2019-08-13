package main

import (
	"os"
	"strconv"
)

const gpio_path = "/sys/class/gpio"

type Pin int

func (p Pin) Pin() string    { return strconv.Itoa(int(p)) }
func (p Pin) Enable() error  { return openAndWrite(gpio_path+"/export", []byte(p.Pin())) }
func (p Pin) Disable() error { return openAndWrite(gpio_path+"/unexport", []byte(p.Pin())) }
func (p Pin) Direction(d string) error {
	return openAndWrite(gpio_path+"/gpio"+p.Pin()+"/direction", []byte(d))
}
func (p Pin) Set(b bool) error {
	v := []byte{'0'}
	if b {
		v[0] = '1'
	}
	return openAndWrite(gpio_path+"/gpio"+p.Pin()+"/value", v)
}
func (p Pin) Get() (bool, error) {
	s, err := openAndRead(gpio_path + "/gpio" + p.Pin() + "/value")
	if err != nil {
		return false, err
	}
	v, err := strconv.Atoi(s)
	if err != nil {
		return false, err
	}

	if v == 1 {
		return true, nil
	}
	return false, nil

}

func openAndWrite(filename string, v []byte) error {
	f, err := os.OpenFile(filename, os.O_WRONLY, 0600)
	if err != nil {
		return err
	}
	defer f.Close()

	_, err = f.Write(v)
	return err
}

func openAndRead(filename string) (string, error) {
	f, err := os.OpenFile(filename, os.O_RDONLY, 0600)
	if err != nil {
		return "", err
	}
	defer f.Close()

	buf := make([]byte, 1)
	if _, err = f.Read(buf); err != nil {
		return "", err
	}

	return string(buf), nil
}

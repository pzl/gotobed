<h3 align="center">gotobed</h3>

<div align="center">

  [![Status](https://img.shields.io/badge/status-active-success.svg)]() 
  [![GitHub Issues](https://img.shields.io/github/issues/pzl/gotobed.svg)](https://github.com/pzl/gotobed/issues)
  [![GitHub Pull Requests](https://img.shields.io/github/issues-pr/pzl/gotobed.svg)](https://github.com/pzl/gotobed/pulls)
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

</div>

---

<p align="center"> A toddler bedtime routine controller (hardware involved)
    <br> 
</p>


## About

`gotobed` is the software side of a raspberry pi-controlled traffic light in my toddler's room.

### Hardware

- Adafruit [Tower Light](https://www.adafruit.com/product/2993) (and [power supply](https://www.adafruit.com/product/352)) (or any similar tower light, or wires to be switched on/off)
- a 4-channel relay (here is [the one I used](https://www.microcenter.com/product/476352/4-channel-relay-module)).
- a raspberry pi (I use a pi zero w)

For more permanent installation, I put these things in a standard project box, with connectors like [DC barrel jacks](https://www.amazon.com/dp/B073LF3FQK) for the 12V in, [IEC C14](https://www.amazon.com/s?k=c14+mount&ref=nb_sb_noss_2) for mains in, a [panel mounted plug](https://www.amazon.com/s?k=us+plug+panel+mount&ref=nb_sb_noss_2) for lamp control, etc.

### Software

This *is* the software! It comes in two parts:

- a `go` binary. This serves as an HTTP server on the pi, offering a JSON API for querying and setting the lights and lamp. It also serves the static web control
- a nuxt (vue) single page web app. It is a graphic front-end to the API, to click light bulbs and things, consuming the API.



## License

MIT License (c) 2019 Dan Panzarella

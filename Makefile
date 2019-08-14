TARGET=gotobed
PIBIN=$(TARGET)-arm
WEB=web/dist/index.html

all: $(TARGET) $(WEB)
pi: $(PIBIN) web.tar.gz

$(TARGET): $(wildcard *.go)
	go build

$(PIBIN): $(wildcard *.go)
	CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=6 go build -o $(TARGET)-arm

$(WEB): $(wildcard web/assets/*) $(wildcard web/components/*) $(wildcard web/layouts/*) $(wildcard web/pages/*) web/nuxt.config.js
	cd web; npm run generate

web.tar.gz: $(WEB)
	tar -czvf web.tar.gz web/dist	

clean:
	$(RM) -rf $(TARGET) $(TARGET)-arm web.tar.gz

.PHONY: clean
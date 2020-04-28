TARGET=gotobed
PIBIN=$(TARGET)-arm

all: $(TARGET)
pi: $(PIBIN)

$(TARGET): $(wildcard *.go) assets.go
	go build

$(PIBIN): $(wildcard *.go)
	CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=6 go build -o $(TARGET)-arm

assets.go: assets_gen.go web/dist/index.html
	go generate

web/dist/index.html: web/node_modules $(shell find web -type f -name '*.vue') $(shell find web -type f -name '*.js')
	cd web && npm run build

web/node_modules: web/package.json web/package-lock.json
	cd web && npm install

clean:
	$(RM) -rf $(TARGET) $(TARGET)-arm

.PHONY: clean
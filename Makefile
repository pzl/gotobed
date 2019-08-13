TARGET=gotobed


all: $(TARGET)


$(TARGET): $(wildcard *.go)
	go build


pi:
	CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=6 go build -o $(TARGET)-arm

clean:
	$(RM) -rf $(TARGET) $(TARGET)-arm

.PHONY: clean
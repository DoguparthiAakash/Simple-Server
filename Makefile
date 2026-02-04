.PHONY: build run clean

BINARY=server

build:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o $(BINARY) ./cmd/server

run:
	PORT=8080 ./$(BINARY)

clean:
	rm -f $(BINARY)

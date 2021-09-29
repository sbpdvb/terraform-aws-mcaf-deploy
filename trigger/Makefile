clean:
	rm -rf bin

test:
	go test ./...
	go mod tidy

build: test
	GOOS=linux GOARCH=amd64 go build -o ../bin/trigger

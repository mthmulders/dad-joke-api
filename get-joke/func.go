package main

import (
	"context"
	"encoding/json"
	"func/jokes"
	"io"
	"time"

	fdk "github.com/fnproject/fdk-go"
)

func main() {
	fdk.Handle(fdk.HandlerFunc(myHandler))
}

func myHandler(ctx context.Context, in io.Reader, out io.Writer) {
	now := time.Now()

	msg := struct {
		Timestamp time.Time `json:"ts"`
		Joke      string    `json:"joke"`
	}{
		Timestamp: now,
		Joke:      jokes.GetRandomJoke(),
	}

	json.NewEncoder(out).Encode(&msg)
}

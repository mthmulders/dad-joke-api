package main

import (
	"context"
	"encoding/json"
	"fmt"
	"func/jokes"
	"io"

	fdk "github.com/fnproject/fdk-go"
)

func main() {
	fdk.Handle(fdk.HandlerFunc(myHandler))
}

type person struct {
	Name string `json:"name"`
}

func readPersonFromRequest(in io.Reader) person {
	person := &person{Name: "World"}
	json.NewDecoder(in).Decode(person)
	return *person
}

func myHandler(ctx context.Context, in io.Reader, out io.Writer) {
	person := readPersonFromRequest(in)

	msg := struct {
		Greeting string `json:"greeting"`
		Joke     string `json:"joke"`
	}{
		Greeting: fmt.Sprintf("Hello %s", person.Name),
		Joke:     jokes.GetRandomJoke(),
	}

	json.NewEncoder(out).Encode(&msg)
}

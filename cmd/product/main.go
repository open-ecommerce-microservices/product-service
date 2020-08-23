package main

import (
	"log"
	"net/http"
	"strconv"

	"github.com/go-zoo/bone"
)

func main() {
	mux := bone.New()

	mux.RegisterValidatorFunc("isNum", func(s string) bool {
		if _, err := strconv.Atoi(s); err == nil {
			return true
		}
		return false
	})

	mux.Get("/", http.HandlerFunc(HomeHandler))

	// Start Listening
	log.Fatal(mux.ListenAndServe(":8080"))

}

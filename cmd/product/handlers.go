package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/open-ecommerce-microservices/product-service/internal/app"
)

// HomeHandler ...
func HomeHandler(rw http.ResponseWriter, req *http.Request) {
	if data, err := json.Marshal(&app.Application{Name: "Products Service", Version: "0.0.1"}); err != nil {
		log.Printf("%v", fmt.Errorf("error marshaling data: %w", err))
		rw.WriteHeader(500)
	} else {
		rw.Write(data)
	}
	rw.Header().Add("Content-Type", "application/json")
}

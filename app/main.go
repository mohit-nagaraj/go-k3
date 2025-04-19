package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("Request received from IP: %s\n", r.RemoteAddr)
		fmt.Fprintln(w, "Hello from Go!")
	})
	http.ListenAndServe(":8080", nil)
}

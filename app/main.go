package main

import (
	"fmt"
	"net/http"
	
	"basic-server/internal/handlers"
	"basic-server/internal/middleware"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func main() {
	http.HandleFunc("/", middleware.Metrics(handlers.Home))
	http.HandleFunc("/health", middleware.Metrics(handlers.Health))
	http.Handle("/metrics", promhttp.Handler())

	fmt.Println("Server starting on :8080...")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		panic(fmt.Sprintf("Server failed to start: %v", err))
	}
}
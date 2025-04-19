package main

import (
	"fmt"
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	requestCounter = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"path", "status"},
	)
	
	requestDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "Duration of HTTP requests in seconds",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"path"},
	)
)

func metricsMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		
		wrapper := newResponseWriter(w)
		
		next(wrapper, r)
		
		duration := time.Since(start).Seconds()
		statusCode := fmt.Sprintf("%d", wrapper.statusCode)
		
		requestCounter.WithLabelValues(r.URL.Path, statusCode).Inc()
		requestDuration.WithLabelValues(r.URL.Path).Observe(duration)
	}
}

type responseWriter struct {
	http.ResponseWriter
	statusCode int
}

func newResponseWriter(w http.ResponseWriter) *responseWriter {
	return &responseWriter{w, http.StatusOK}
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("Request received from IP: %s\n", r.RemoteAddr)
	fmt.Fprintln(w, "Hello from Go!")
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, "OK")
}

func main() {
	http.HandleFunc("/", metricsMiddleware(homeHandler))
	http.HandleFunc("/health", metricsMiddleware(healthHandler))
	
	http.Handle("/metrics", promhttp.Handler())
	
	fmt.Println("Server starting on :8080...")
	http.ListenAndServe(":8080", nil)
}
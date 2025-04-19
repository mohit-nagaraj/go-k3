package middleware

import (
	"fmt"
	"net/http"
	"time"
	
	"basic-server/internal/metrics"
)

func Metrics(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		ww := NewResponseWriter(w)
		
		next(ww, r)
		
		duration := time.Since(start).Seconds()
		statusCode := fmt.Sprintf("%d", ww.StatusCode())
		
		metrics.RequestCounter.WithLabelValues(r.URL.Path, statusCode).Inc()
		metrics.RequestDuration.WithLabelValues(r.URL.Path).Observe(duration)
	}
}
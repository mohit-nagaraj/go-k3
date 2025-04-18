# Start from the official Go image for building
FROM golang:1.24 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy go source files
COPY . .

# Build the Go application
RUN go build -o main .

# Final slim image to run the app
FROM debian:bookworm-slim

# Set working directory in final image
WORKDIR /app

# Copy the compiled binary from builder stage
COPY --from=builder /app/main .

# Expose port 8080 to match containerPort in deployment
EXPOSE 8080

# Run the binary
CMD ["./main"]

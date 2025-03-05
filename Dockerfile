# Stage 1: Build the custom OpenTelemetry Collector
FROM golang:latest AS otelcollector-builder
WORKDIR /src
RUN update-ca-certificates

# Install the OpenTelemetry Collector Builder
RUN GO111MODULE=on go install go.opentelemetry.io/collector/cmd/builder@v0.121.0

# Copy the builder config and build the custom collector
COPY builder-config.yaml .
RUN export CGO_ENABLED=0 && builder --config=builder-config.yaml

# Stage 2: Build the OpAMP Supervisor
FROM golang:1.23 AS opampsupervisor
WORKDIR /src
ENV CGO_ENABLED=0
COPY opampsupervisor .
RUN go build -trimpath -o opampsupervisor .

# Stage 3: Final image
FROM alpine:latest

# Copy the OpAMP Supervisor binary
COPY --from=opampsupervisor --chmod=755 /src/opampsupervisor /opampsupervisor

# Copy the custom-built OpenTelemetry Collector binary
COPY --from=otelcollector-builder --chmod=755 /src/output/otelcontribcol /otelcol-custom

# Copy the OpenTelemetry Collector configuration
COPY collector-config.yaml /etc/otel/config.yaml

WORKDIR /var/lib/otelcol/supervisor
COPY supervisor.yml .

ENTRYPOINT ["/opampsupervisor", "--config", "supervisor.yml"]

EXPOSE 4317 4318 13333

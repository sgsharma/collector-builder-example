FROM golang:latest AS base

RUN update-ca-certificates

# download the builder utility
RUN GO111MODULE=on go install go.opentelemetry.io/collector/cmd/builder@v0.109.0

COPY builder-config.yaml /

# build our custom collector using our provided builder-config
RUN export CGO_ENABLED=0 && \
    builder --config=/builder-config.yaml

COPY collector-config.yaml /etc/otel/config.yaml
CMD ["/bin/sh", "-c", "/go/build/otelcol-custom --config /etc/otel/config.yaml"]
EXPOSE 4317 4318 13333

ARG ALPINE_IMAGE=alpine
ARG ALPINE_IMAGE_VERSION=3.18
ARG GOLANG_IMAGE=golang
ARG GOLANG_IMAGE_VERSION=1.21
ARG ENVOY_IMAGE=envoyproxy/envoy
ARG ENVOY_IMAGE_VERSION=1.27.0
ARG GOMPLATE_VERSION=latest

FROM ${GOLANG_IMAGE}:${GOLANG_IMAGE_VERSION}-${ALPINE_IMAGE}${ALPINE_IMAGE_VERSION} as gomplate_builder

ARG GOMPLATE_VERSION
RUN go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@${GOMPLATE_VERSION}

FROM ${ENVOY_IMAGE}:v${ENVOY_IMAGE_VERSION}
ARG ENVOY_TEMPLATE_CONFIG_PATH
COPY ${ENVOY_TEMPLATE_CONFIG_PATH} /etc/envoy/envoy.yaml.tmpl

COPY --from=gomplate_builder /go/bin/gomplate /usr/local/bin/gomplate
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/bin/envoy", "-c", "/etc/envoy/envoy.yaml"]
#!/usr/bin/env sh
set -e
gomplate --file /etc/envoy/envoy.yaml.tmpl --out /etc/envoy/envoy.yaml
envoy --mode validate -c /etc/envoy/envoy.yaml
exec "${@}"

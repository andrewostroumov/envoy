## template:                   generate envoy.yaml from templates/envoy.yaml.tmpl
template:
	@gomplate \
		--file $(HOME)/Projects/gitlab.time2go.tech/pinup/gateways/template-builder/templates/envoy.yaml.tmpl \
		--template routes=$(HOME)/Projects/gitlab.time2go.tech/pinup/gateways/template-builder/templates/routes.yaml.tmpl \
		--template clusters=$(HOME)/Projects/gitlab.time2go.tech/pinup/gateways/template-builder/templates/clusters.yaml.tmpl \
		--context gateway=gateway.yaml \
		--out build/envoy.yaml.tmpl \
		--verbose
docker-build:
	@make template
	@docker build --build-arg ENVOY_TEMPLATE_CONFIG_PATH=build/envoy.yaml.tmpl -t envoy:build -f Dockerfile .
## docker run:                 run docker image
docker-run:
	@make docker-build
	@docker run --rm --name envoy -p 8080:8080 --network local \
		-e CORS_DOMAIN=* \
		-e OPENTELEMETRY_COLLECTOR_HOST=jaeger \
		-e OPENTELEMETRY_COLLECTOR_PORT=4317 \
		-e ENVOY_AUTHZ_PLUGIN_HOST=envoy-authz \
		-e ENVOY_AUTHZ_PLUGIN_PORT=9090 \
		envoy:build
## deps:                       (re)installs gomplate
deps:
	@go install -ldflags "-s -w" github.com/hairyhenderson/gomplate/v4/cmd/gomplate@latest

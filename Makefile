GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
VERSION ?= '$(shell hack/version.sh)'

# Images management
REGISTRY?="ghcr.io/kosmos-io"
REGISTRY_USER_NAME?=""
REGISTRY_PASSWORD?=""
REGISTRY_SERVER_ADDRESS?=""
KIND_IMAGE_TAG?="v1.25.3"

TARGETS := netdr-floater \

CTL_TARGETS := netctl

# Build code.
#
# Args:
#   GOOS:   OS to build.
#   GOARCH: Arch to build.
#
# Example:
#   make
#   make all
#   make netdr-floater
#   make netdr-floater GOOS=linux
CMD_TARGET=$(TARGETS) $(CTL_TARGETS)

.PHONY: all
all: $(CMD_TARGET)

.PHONY: $(CMD_TARGET)
$(CMD_TARGET):
	BUILD_PLATFORMS=$(GOOS)/$(GOARCH) hack/build.sh $@

# Build image.
#
# Args:
#   GOARCH:      Arch to build.
#   OUTPUT_TYPE: Destination to save image(docker/registry).
#
# Example:
#   make images
#   make image-netdr-floater
#   make image-netdr-floater GOARCH=arm64
IMAGE_TARGET=$(addprefix image-, $(TARGETS))
.PHONY: $(IMAGE_TARGET)
$(IMAGE_TARGET):
	set -e;\
	target=$$(echo $(subst image-,,$@));\
	make $$target GOOS=linux;\
	VERSION=$(VERSION) REGISTRY=$(REGISTRY) BUILD_PLATFORMS=linux/$(GOARCH) hack/docker.sh $$target

images: $(IMAGE_TARGET)

# Build and push multi-platform image to DockerHub
#
# Example
#   make multi-platform-images
#   make mp-image-netdr
MP_TARGET=$(addprefix mp-image-, $(TARGETS))
.PHONY: $(MP_TARGET)
$(MP_TARGET):
	set -e;\
	target=$$(echo $(subst mp-image-,,$@));\
	make $$target GOOS=linux GOARCH=amd64;\
	make $$target GOOS=linux GOARCH=arm64;\
	VERSION=$(VERSION) REGISTRY=$(REGISTRY) \
		OUTPUT_TYPE=registry \
		BUILD_PLATFORMS=linux/amd64,linux/arm64 \
		hack/docker.sh $$target

multi-platform-images: $(MP_TARGET)

.PHONY: clean
clean:
	rm -rf _tmp _output

.PHONY: update
update:
	hack/update-all.sh

.PHONY: verify
verify:
	hack/verify-all.sh

.PHONY: test
test:
	mkdir -p ./_output/coverage/
	go test --race --v ./pkg/... -coverprofile=./_output/coverage/coverage_pkg.txt -covermode=atomic
	go test --race --v ./cmd/... -coverprofile=./_output/coverage/coverage_cmd.txt -covermode=atomic

upload-images: images
	@echo "push images to $(REGISTRY)"
	docker push ${REGISTRY}/netdr-floater:${VERSION}

.PHONY: release
release:
	@make release-netctl GOOS=linux GOARCH=amd64
	@make release-netctl GOOS=linux GOARCH=arm64
	@make release-netctl GOOS=darwin GOARCH=amd64
	@make release-netctl GOOS=darwin GOARCH=arm64

release-netctl:
	hack/release.sh netctl ${GOOS} ${GOARCH}

.PHONY: lint
lint: golangci-lint
	$(GOLANGLINT_BIN) run

.PHONY: lint-fix
lint-fix: golangci-lint
	$(GOLANGLINT_BIN) run --fix

golangci-lint:
ifeq (, $(shell which golangci-lint))
	GO111MODULE=on go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.54.2
GOLANGLINT_BIN=$(shell go env GOPATH)/bin/golangci-lint
else
GOLANGLINT_BIN=$(shell which golangci-lint)
endif

image-base-kind-builder:
	docker buildx build \
	    -t $(REGISTRY)/node:$(KIND_IMAGE_TAG) \
        --platform=linux/amd64,linux/arm64 \
        --push \
        -f cluster/images/buildx.kind.Dockerfile .

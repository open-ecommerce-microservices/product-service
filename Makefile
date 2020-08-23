.PHONY: build test coverage run clean wait

OK_COLOR=\033[32;01m
NO_COLOR=\033[0m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m

# Build Flags
BUILD_DATE = $(shell date -u --rfc-3339=seconds)
BUILD_HASH ?= $(shell git rev-parse --short HEAD)
APP_VERSION ?= undefined
BUILD_NUMBER ?= dev

NOW = $(shell date -u '+%Y%m%d%I%M%S')

GO := go
DOCKER := docker
DOCKER_EXISTS := $(shell type $(DOCKER) > /dev/null 2> /dev/null; echo $$? )
DOCKER_COMPOSE := docker-compose
BUILDOS ?= $(shell go env GOHOSTOS)
BUILDARCH ?= amd64
GOFLAGS ?=
ECHOFLAGS ?=
ROOT_DIR := $(realpath .)

BIN_WEBSERVER := product-service
BUILD_PATH := ./cmd/product
LOCAL_VARIABLES := $(shell env)

PKGS = $(shell $(GO) list ./...)

ENVFLAGS = GO111MODULE=on CGO_ENABLED=0 GOOS=$(BUILDOS) GOARCH=$(BUILDARCH)
ENVFLAGS_EVENTS = GO111MODULE=on CGO_ENABLED=0 GOOS=linux GOARCH=amd64
BUILDENV ?= GOOS=$(BUILDOS) GOARCH=$(BUILDARCH)
BUILDFLAGS ?= -a $(GOFLAGS) $(GO_LINKER_FLAGS)
EXTLDFLAGS = -extldflags "-lm -lstdc++ -static"

## usage: show available actions
usage: Makefile
	@echo $(ECHOFLAGS) "to use make call:"
	@echo $(ECHOFLAGS) "    make <action>"
	@echo $(ECHOFLAGS) ""
	@echo $(ECHOFLAGS) "list of available actions:"
	@if [ -x /usr/bin/column ]; \
	then \
		echo "$$(sed -n 's/^## /    /p' $< | column -t -s ':')"; \
	else \
		echo "$$(sed -n 's/^## /    /p' $<)"; \
	fi

## build: build server
build:
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Building binary (bin/$(BIN_WEBSERVER))...$(NO_COLOR)"
	@echo $(ECHOFLAGS) "$(WARN_COLOR) $(LOCAL_VARIABLES) $(NO_COLOR)"
	$(GO) build -v -o bin/$(BIN_WEBSERVER) $(BUILD_PATH)

## test: run unit tests
test:
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Running tests with envs:$(NO_COLOR)"
	@echo $(ECHOFLAGS) "$(WARN_COLOR) $(LOCAL_VARIABLES) $(NO_COLOR)"
	$(GO) test -v -race -cover $(PKGS)

## run: run server
run:
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Running server with envs:$(NO_COLOR)"
	@echo $(ECHOFLAGS) "$(WARN_COLOR) $(LOCAL_VARIABLES) $(NO_COLOR)"
	./bin/$(BIN_WEBSERVER) $(args)

## wait: used only to wait for database connections
wait:
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Waiting for the database...$(NO_COLOR)"
	bash scripts/tcp-port-wait.sh $(DATABASE_HOST) $(DATABASE_PORT)

## clean: clean local binaries
clean:
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Running clean...$(NO_COLOR)"
	@rm -rf bin/$(BIN_WEBSERVER)
	@echo $(ECHOFLAGS) "$(OK_COLOR)App clear! :)$(NO_COLOR)"
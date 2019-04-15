OS_ARCH:=$(shell docker info --format='{{.OSType}}:{{.Architecture}}')

ifeq "$(OS_ARCH)" "linux:s390x"
    GOLANG_ALPINE=s390x/golang:1.10.8-alpine3.9
    ALPINE=s390x/alpine:3.9
    ARCH=s390x
    ARCH_IMG=-s390x
else ifeq "$(OS_ARCH)" "linux:ppc64le"
    GOLANG_ALPINE=ppc64le/golang:1.10.8-alpine3.9
    ALPINE=ppc64le/alpine:3.9
    ARCH=ppc64le
    ARCH_IMG=-ppc64le
else ifeq "$(OS_ARCH)" "linux:x86_64"
    GOLANG_ALPINE=golang:1.10.8-alpine3.9
    ALPINE=alpine:3.9
    ARCH=x86_64
    ARCH_IMG=
else
    $(error $(OS_ARCH) not supported)
endif

export GOLANG_ALPINE
export ALPINE
export ARCH_IMG
export ARCH

TAG?=dev
export TAG

build: dockereng/ucp-swarm$(ARCH_IMG)

push:
	@echo Pushing image image $@:$(TAG)
	docker push dockereng/ucp-swarm$(ARCH_IMG):$(TAG)

dockereng/ucp-swarm$(ARCH_IMG):
	@echo Building image $@:$(TAG)
	docker build --build-arg GOLANG_ALPINE=$(GOLANG_ALPINE) --build-arg ALPINE=$(ALPINE) -t dockereng/ucp-swarm$(ARCH_IMG):$(TAG) .

.PHONY: build

SERVICE_N := sampledb
TAG := v1
IMAGE_NAME_BASE := geunsam2/mha-$(SERVICE_N)

.PHONY: help build push

help:
	@printf "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)\n"

build: ## Builds docker image latest
	for count in $$(seq 1 4); do docker build --pull -t $(IMAGE_NAME_BASE):db$${count}$(TAG) -f Dockerfile-db --build-arg SERVICE_N=$(SERVICE_N) --build-arg F_NUM=$${count} . ; done
	for count in $$(seq 1 2); do docker build --pull -t $(IMAGE_NAME_BASE):haproxy$${count}$(TAG) -f Dockerfile-haproxy --build-arg SERVICE_N=$(SERVICE_N) --build-arg F_NUM=$${count} .; done
	docker build --pull -t $(IMAGE_NAME_BASE):manager$(TAG) -f Dockerfile-manager --build-arg SERVICE_N=$(SERVICE_N) --build-arg MHA_HAPROXY_IMG_1=$(IMAGE_NAME_BASE):haproxy1$(TAG) --build-arg MHA_HAPROXY_IMG_2=$(IMAGE_NAME_BASE):haproxy2$(TAG) .

push: ## Build and Pushes the docker image to hub.docker.com
	# Don't --pull here, we don't want any last minute upsteam changes
	for count in $$(seq 1 4); do docker push $(IMAGE_NAME_BASE):db$${count}$(TAG); done
	for count in $$(seq 1 2); do docker push $(IMAGE_NAME_BASE):haproxy$${count}$(TAG); done
	docker push $(IMAGE_NAME_BASE):manager$(TAG)

SERVICE_N := sampledb-1
TAG := v1
IMAGE_NAME_BASE := geunsam2/mha-$(SERVICE_N)
MYSQL_PASS := admin123!@#

.PHONY: help build push clean

help:
	@printf "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)\n"

build: ## Builds docker image latest
	docker build --pull -t $(IMAGE_NAME_BASE):db1$(TAG) -f Dockerfile-db --build-arg SERVICE_N=$(SERVICE_N) --build-arg F_NUM=1 .
	docker build --pull -t $(IMAGE_NAME_BASE):db2$(TAG) -f Dockerfile-db --build-arg SERVICE_N=$(SERVICE_N) --build-arg F_NUM=2 .
	docker build --pull -t $(IMAGE_NAME_BASE):db3$(TAG) -f Dockerfile-db --build-arg SERVICE_N=$(SERVICE_N) --build-arg F_NUM=3 .
	docker build --pull -t $(IMAGE_NAME_BASE):db4$(TAG) -f Dockerfile-db --build-arg SERVICE_N=$(SERVICE_N) --build-arg F_NUM=4 .
	docker build --pull -t $(IMAGE_NAME_BASE):manager$(TAG) -f Dockerfile-manager --build-arg SERVICE_N=$(SERVICE_N) --build-arg MHA_HAPROXY_IMG_1=$(IMAGE_NAME_BASE):haproxy1$(TAG) --build-arg MHA_HAPROXY_IMG_2=$(IMAGE_NAME_BASE):haproxy2$(TAG) .
	docker build --pull -t $(IMAGE_NAME_BASE):haproxy1$(TAG) -f Dockerfile-haproxy --build-arg SERVICE_N=$(SERVICE_N) --build-arg F_NUM=1 .
	docker build --pull -t $(IMAGE_NAME_BASE):haproxy2$(TAG) -f Dockerfile-haproxy --build-arg SERVICE_N=$(SERVICE_N) --build-arg F_NUM=2 .

push: ## Pushes the docker image to hub.docker.com
	# Don't --pull here, we don't want any last minute upsteam changes
	docker build --pull -t $(IMAGE_NAME_BASE):db1$(TAG) -f Dockerfile-db --build-arg SERVICE_N=$(SERVICE_N) --build-arg F_NUM=1 .
	docker build --pull -t $(IMAGE_NAME_BASE):db2$(TAG) -f Dockerfile-db --build-arg SERVICE_N=$(SERVICE_N) --build-arg F_NUM=2 .
	docker build --pull -t $(IMAGE_NAME_BASE):db3$(TAG) -f Dockerfile-db --build-arg SERVICE_N=$(SERVICE_N) --build-arg F_NUM=3 .
	docker build --pull -t $(IMAGE_NAME_BASE):db4$(TAG) -f Dockerfile-db --build-arg SERVICE_N=$(SERVICE_N) --build-arg F_NUM=4 .
	docker build --pull -t $(IMAGE_NAME_BASE):manager$(TAG) -f Dockerfile-manager --build-arg SERVICE_N=$(SERVICE_N) --build-arg MHA_HAPROXY_IMG_1=$(IMAGE_NAME_BASE):haproxy1$(TAG) --build-arg MHA_HAPROXY_IMG_2=$(IMAGE_NAME_BASE):haproxy2$(TAG) .
	docker build --pull -t $(IMAGE_NAME_BASE):haproxy1$(TAG) -f Dockerfile-haproxy --build-arg SERVICE_N=$(SERVICE_N) --build-arg F_NUM=1 .
	docker build --pull -t $(IMAGE_NAME_BASE):haproxy2$(TAG) -f Dockerfile-haproxy --build-arg SERVICE_N=$(SERVICE_N) --build-arg F_NUM=2 .
	docker push $(IMAGE_NAME_BASE):db1$(TAG)
	docker push $(IMAGE_NAME_BASE):db2$(TAG)
	docker push $(IMAGE_NAME_BASE):db3$(TAG)
	docker push $(IMAGE_NAME_BASE):db4$(TAG)
	docker push $(IMAGE_NAME_BASE):manager$(TAG)
	docker push $(IMAGE_NAME_BASE):haproxy1$(TAG)
	docker push $(IMAGE_NAME_BASE):haproxy2$(TAG)

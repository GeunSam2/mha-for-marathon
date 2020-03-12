NAME := cmdbmha-dev
NAME2 := haproxy-stadb-dev
TAG := v1
TAG2 := v1
IMAGE_NAME := geunsam2/$(NAME)
IMAGE_NAME2 := geunsam2/$(NAME2)
MYSQL_PASS := admin123!@#

.PHONY: help build push clean

help:
	@printf "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)\n"

build: ## Builds docker image latest
	mkdir -p key/db1 key/db2 key/db3 key/db4 key/manager
	ssh-keygen -b 2048 -t rsa -f key/db1/id_rsa -q -C "" -N "" 2>/dev/null <<< y >/dev/null
	ssh-keygen -b 2048 -t rsa -f key/db2/id_rsa -q -C "" -N "" 2>/dev/null <<< y >/dev/null
	ssh-keygen -b 2048 -t rsa -f key/db3/id_rsa -q -C "" -N "" 2>/dev/null <<< y >/dev/null
	ssh-keygen -b 2048 -t rsa -f key/db4/id_rsa -q -C "" -N "" 2>/dev/null <<< y >/dev/null
	ssh-keygen -b 2048 -t rsa -f key/manager/id_rsa -q -C "" -N "" 2>/dev/null <<< y >/dev/null
	cat key/*/*.pub | tee key/db1/authorized_keys key/db2/authorized_keys key/db3/authorized_keys key/db4/authorized_keys key/manager/authorized_keys
	chmod 644 key/*/authorized_keys
	chmod 644 key/*/id_rsa.pub
	chmod 600 key/*/id_rsa
	docker build --pull -t $(IMAGE_NAME):db1$(TAG) -f Dockerfile-db1 .
	docker build --pull -t $(IMAGE_NAME):db2$(TAG) -f Dockerfile-db2 .
	docker build --pull -t $(IMAGE_NAME):db3$(TAG) -f Dockerfile-db3 .
	docker build --pull -t $(IMAGE_NAME):db4$(TAG) -f Dockerfile-db4 .
	docker build --pull -t $(IMAGE_NAME):manager$(TAG) -f Dockerfile-manager .
	docker build --pull -t $(IMAGE_NAME2):m1$(TAG) -f Dockerfile-haproxy1 .
	docker build --pull -t $(IMAGE_NAME2):m2$(TAG) -f Dockerfile-haproxy2 .

push: ## Pushes the docker image to hub.docker.com
	# Don't --pull here, we don't want any last minute upsteam changes
	mkdir -p key/db1 key/db2 key/db3 key/db4 key/manager
	ssh-keygen -b 2048 -t rsa -f key/db1/id_rsa -q -C "" -N "" 2>/dev/null <<< y >/dev/null
	ssh-keygen -b 2048 -t rsa -f key/db2/id_rsa -q -C "" -N "" 2>/dev/null <<< y >/dev/null
	ssh-keygen -b 2048 -t rsa -f key/db3/id_rsa -q -C "" -N "" 2>/dev/null <<< y >/dev/null
	ssh-keygen -b 2048 -t rsa -f key/db4/id_rsa -q -C "" -N "" 2>/dev/null <<< y >/dev/null
	ssh-keygen -b 2048 -t rsa -f key/manager/id_rsa -q -C "" -N "" 2>/dev/null <<< y >/dev/null
	cat key/*/*.pub | tee key/db1/authorized_keys key/db2/authorized_keys key/db3/authorized_keys key/db4/authorized_keys key/manager/authorized_keys
	chmod 644 key/*/authorized_keys
	chmod 644 key/*/id_rsa.pub
	chmod 600 key/*/id_rsa
	docker build --pull -t $(IMAGE_NAME):db1$(TAG) -f Dockerfile-db1 .
	docker build --pull -t $(IMAGE_NAME):db2$(TAG) -f Dockerfile-db2 .
	docker build --pull -t $(IMAGE_NAME):db3$(TAG) -f Dockerfile-db3 .
	docker build --pull -t $(IMAGE_NAME):db4$(TAG) -f Dockerfile-db4 .
	docker build --pull -t $(IMAGE_NAME):manager$(TAG) -f Dockerfile-manager .
	docker build --pull -t $(IMAGE_NAME2):m1$(TAG) -f Dockerfile-haproxy1 .
	docker build --pull -t $(IMAGE_NAME2):m2$(TAG) -f Dockerfile-haproxy2 .
	docker push $(IMAGE_NAME):db1$(TAG)
	docker push $(IMAGE_NAME):db2$(TAG)
	docker push $(IMAGE_NAME):db3$(TAG)
	docker push $(IMAGE_NAME):db4$(TAG)
	docker push $(IMAGE_NAME):manager$(TAG)
	docker push $(IMAGE_NAME2):m1$(TAG)
	docker push $(IMAGE_NAME2):m2$(TAG)

run: ## build image and run
	mkdir -p key/db1 key/db2 key/db3 key/db4 key/manager
	ssh-keygen -b 2048 -t rsa -f key/db1/id_rsa -q -C "" -N "" 2>/dev/null <<< y >/dev/null
	ssh-keygen -b 2048 -t rsa -f key/db2/id_rsa -q -C "" -N "" 2>/dev/null <<< y >/dev/null
	ssh-keygen -b 2048 -t rsa -f key/db3/id_rsa -q -C "" -N "" 2>/dev/null <<< y >/dev/null
	ssh-keygen -b 2048 -t rsa -f key/db4/id_rsa -q -C "" -N "" 2>/dev/null <<< y >/dev/null
	ssh-keygen -b 2048 -t rsa -f key/manager/id_rsa -q -C "" -N "" 2>/dev/null <<< y >/dev/null
	cat key/*/*.pub | tee key/db1/authorized_keys key/db2/authorized_keys key/db3/authorized_keys key/db4/authorized_keys key/manager/authorized_keys
	chmod 644 key/*/authorized_keys
	chmod 644 key/*/id_rsa.pub
	chmod 600 key/*/id_rsa
	docker build --pull -t $(IMAGE_NAME):db1$(TAG) -f Dockerfile-db1 .
	docker build --pull -t $(IMAGE_NAME):db2$(TAG) -f Dockerfile-db2 .
	docker build --pull -t $(IMAGE_NAME):db3$(TAG) -f Dockerfile-db3 .
	docker build --pull -t $(IMAGE_NAME):db4$(TAG) -f Dockerfile-db4 .
	docker build --pull -t $(IMAGE_NAME):manager$(TAG) -f Dockerfile-manager .
	docker build --pull -t $(IMAGE_NAME2):m1$(TAG) -f Dockerfile-haproxy1 .
	docker build --pull -t $(IMAGE_NAME2):m2$(TAG) -f Dockerfile-haproxy2 .
	docker run -dit -p 11996:3306 -p 11997:22 --name mhadb1 --rm -e MYSQL_ROOT_PASSWORD=$(MYSQL_PASS) $(IMAGE_NAME):db1$(TAG)
	docker run -dit -p 11998:3306 -p 11999:22 --name mhadb2 --rm -e MYSQL_ROOT_PASSWORD=$(MYSQL_PASS) $(IMAGE_NAME):db2$(TAG)
	docker run -dit -p 12000:3306 -p 12001:22 --name mhadb3 --rm -e MYSQL_ROOT_PASSWORD=$(MYSQL_PASS) $(IMAGE_NAME):db3$(TAG)
	docker run -dit -p 11995:22 --name mhamanager --rm -e MYSQL_ROOT_PASSWORD=$(MYSQL_PASS) $(IMAGE_NAME):manager$(TAG)

clean: ## Remove built images
	docker rmi $(IMAGE_NAME):db1$(TAG)
	docker rmi $(IMAGE_NAME):db2$(TAG)
	docker rmi $(IMAGE_NAME):db3$(TAG)
	docker rmi $(IMAGE_NAME):db4$(TAG)
	docker rmi $(IMAGE_NAME):manager$(TAG)
	docker rmi $(IMAGE_NAME2):m1$(TAG)
	docker rmi $(IMAGE_NAME2):m2$(TAG)


include Makefile.settings

.PHONY: init build run clean publish logs

DOCKER_REGISTRY ?= docker.io
ORG_NAME ?= dockerproductionaws
REPO_NAME ?= jenkins
export DOCKER_ENGINE ?= 1.12.1
export DOCKER_GID ?= 100

init:
	${INFO} "Creating volumes..."
	@ docker volume create --name=jenkins_home

build: init
	${INFO} "Creating wheels..."
	@ docker-compose up wheel
	@ docker-compose down -v || true
	${INFO} "Building image..."
	@ docker-compose build --pull
	${INFO} "Build complete"

run: init
	${INFO} "Starting services..."
	@ docker-compose up -d jenkins
	${INFO} "Services running"

publish: run
	${INFO} "Publishing image..."
	@ docker tag $$(docker inspect -f '{{ .Image }}' $$(docker-compose ps -q jenkins)) $(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME)
	@ docker push $(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME)
	${INFO} "Publish complete"

clean:
	${INFO} "Stopping services..."
	@ docker-compose down -v || true
	${INFO} "Services stopped"

logs:
	@ docker-compose logs -f jenkins

all: test

docker-build:
	@echo Building bashdot-test image
	docker build -q --tag=bashdot-test .

test: docker-build
	@echo Running tests
	docker run -i bashdot-test:latest
	@echo Tests completed succesfully

shell: docker-build
	docker run -it --entrypoint /bin/bash bashdot-test:latest

all: test

docker-build:
	@echo Building dotfiler-test image
	docker build -q --tag=dotfiler-test .

test: docker-build
	@echo Running tests
	docker run -i dotfiler-test:latest
	@echo Tests completed succesfully

shell: docker-build
	docker run -it --entrypoint /bin/bash dotfiler-test:latest

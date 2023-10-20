.PHONY: serve

MKDOCS_IMAGE ?= edgex-mkdocs

clean:
	rm -rf docs/*/
	docker rmi -f $(MKDOCS_IMAGE)

build-docker:
	docker build \
		-f Dockerfile.docs \
		-t $(MKDOCS_IMAGE) \
		.

build: build-docs

# Can be used to verify that mkdocs build works properly
build-docs: build-docker
	docker run --rm \
		-v $(PWD):/docs \
		-w /docs \
		-e ENABLED_HTMLPROOFER \
		$(MKDOCS_IMAGE) \
		build

# Most common use case, serve docs on :8008
serve: build-docker
	docker run --rm \
		-it \
		-p 8008:8008 \
		-v $(PWD):/docs \
		-w /docs \
		-e ENABLED_HTMLPROOFER \
		$(MKDOCS_IMAGE)


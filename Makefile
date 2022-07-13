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

# Most common use case, serve docs on :8001 (8001 changed due to port conflicts with kong)
serve: build-docker
	docker run --rm \
		-it \
		-p 8001:8000 \
		-v $(PWD):/docs \
		-w /docs \
		-e ENABLED_HTMLPROOFER \
		$(MKDOCS_IMAGE)


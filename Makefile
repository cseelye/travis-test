SCRIPT_DIR=tool
TOOL_NAME=$(SCRIPT_DIR)
DEV_IMAGE_NAME=$(TOOL_NAME)-dev
DEV_IMAGE_TARGET=dev
PROD_IMAGE_NAME=$(TOOL_NAME)

.DEFAULT_GOAL := build
SHELL = bash -o pipefail
DEV_IMAGE_MARKER = .$(subst :,-,$(DEV_IMAGE_NAME))
PROD_IMAGE_MARKER = .$(subst :,-,$(PROD_IMAGE_NAME))

# Override command names with g-prefix on macOS, error if they are not installed
TOUCH = touch
MKTEMP = mktemp --tmpdir
uname=$(shell uname -s)
ifeq ($(uname),Darwin)
	TOUCH = gtouch
    MKTEMP = gmktemp --tmpdir=/tmp
endif
TOOLS = $(TOUCH) $(firstword $(MKTEMP))
K := $(foreach exec,$(TOOLS),\
	$(if $(shell which $(exec)),asdf,$(warn "No $(exec) in PATH")))

# Allow silencing all targets by setting V=0 on the make commandline
V ?= 1
ifeq ($(shell  test $(V) -le 0; echo $$?;),0)
.SILENT:
endif

PYTHON_SOURCES = $(shell find $(SCRIPT_DIR) -name "*.py" -a -not -name "test_*")

# Print a make variable, for debugging
print-%  : ; @echo $* = $($*)

# Create a file whose existance and modification date match a container image.
# This brings a container image into make's world and allows make to do its
# normal magic with dependencies, build avoidance, etc.
# $1 the image name
# $2 the marker filename
define create_image_marker
	time=$$(docker image inspect --format '{{.Metadata.LastTagTime}}' $1 2>/dev/null | perl -pe 's/\s+[^\s]+$$//'); \
	if [[ $$? -eq 0 ]]; then \
		$(TOUCH) -d "$${time}" '$2'; \
	else \
		$(RM) '$2'; \
	fi
endef

# Idempotent deletion of a container instance
# $1 the container name
define delete_container
	if docker container inspect $1 &>/dev/null; then \
		docker container rm --force $1; \
	fi
endef

# Idempotent deletion of a container image
# $1 the image name
define delete_image
	if docker image inspect $1 &>/dev/null; then \
		docker image rm --force $1; \
	fi
endef

# Idempotent deletion of a container instance and image
# $1 the container name
# $2 the image name
define delete_container_and_image
	$(call delete_container,$1)
	$(call delete_image,$2)
endef

.PHONY: .create-dev-image-marker
.create-dev-image-marker:
	@$(call create_image_marker,$(DEV_IMAGE_NAME),$(DEV_IMAGE_MARKER))

.PHONY: dev-container
# Generate the dev container
dev-container: $(DEV_IMAGE_MARKER) | .create-dev-image-marker

$(DEV_IMAGE_MARKER): Dockerfile requirements.txt requirements_dev.txt
	$(call delete_image,$(DEV_IMAGE_NAME)) && \
	DOCKER_BUILDKIT=1 docker image build --force-rm --target=$(DEV_IMAGE_TARGET) --tag=$(DEV_IMAGE_NAME) .








.PHONY: lint
lint:
	pylint --rcfile=pylintrc \
		$(PYTHON_SOURCES)

.PHONY: test
test:
	pytest --verbose --cov=$(SCRIPT_DIR)

.PHONY: shell
shell:
	docker container run --rm -it \
		--volume $(CURDIR):/work \
		--workdir /work \
		--entrypoint /bin/bash \
		$(DEV_IMAGE_NAME)

.PHONY: clean
clean:
	find $(CURDIR) -name "__pycache__" -type d -print0 | xargs -0 -I {} rm -r "{}"
	find $(CURDIR) -name "*.pyc" -type f -exec rm {} \;

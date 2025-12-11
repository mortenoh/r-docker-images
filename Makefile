# Names for your images
BASE_IMAGE      := my-r-base
INLA_IMAGE      := my-r-inla
INLA_MINI_IMAGE := my-r-inla-mini

# Default target: show help
.PHONY: help
help:
	@echo "R Docker Images"
	@echo ""
	@echo "Build targets:"
	@echo "  make build           - Build all images"
	@echo "  make build-base      - Build $(BASE_IMAGE) (base R, multi-arch)"
	@echo "  make build-inla      - Build $(INLA_IMAGE) (R + INLA, amd64 only)"
	@echo "  make build-inla-mini - Build $(INLA_MINI_IMAGE) (R + INLA optimized, amd64 only)"
	@echo ""
	@echo "Test targets:"
	@echo "  make test            - Run all tests"
	@echo "  make test-base       - Test $(BASE_IMAGE) with minimalist_example_r"
	@echo "  make test-inla       - Test $(INLA_IMAGE) with INLA_baseline_model"
	@echo "  make test-inla-mini  - Test $(INLA_MINI_IMAGE) with INLA_baseline_model"
	@echo ""
	@echo "Other targets:"
	@echo "  make size            - Show image sizes"
	@echo "  make clean           - Remove all images"

.PHONY: build
build: build-base build-inla build-inla-mini

.PHONY: build-base
build-base:
	docker build --quiet --no-cache -t $(BASE_IMAGE):latest -f Dockerfile .

.PHONY: build-inla
build-inla:
	docker build --quiet --no-cache -t $(INLA_IMAGE):latest -f Dockerfile.inla .

.PHONY: build-inla-mini
build-inla-mini:
	docker build --quiet --no-cache -t $(INLA_MINI_IMAGE):latest -f Dockerfile.inla-mini .

# Show image sizes in a nice table
.PHONY: size
size:
	@echo "Image sizes:"
	@docker images $(BASE_IMAGE) --format "  $(BASE_IMAGE): \t{{.Size}}"
	@docker images $(INLA_IMAGE) --format "  $(INLA_IMAGE): \t{{.Size}}"
	@docker images $(INLA_MINI_IMAGE) --format "  $(INLA_MINI_IMAGE): \t{{.Size}}"

# Test targets
.PHONY: test test-base test-inla test-inla-mini

test: test-base test-inla test-inla-mini

test-base:
	@echo "Testing $(BASE_IMAGE) with minimalist_example_r..."
	docker run --rm -v $(PWD)/test-repos/minimalist_example_r:/app -w /app $(BASE_IMAGE):latest Rscript isolated_run.r

test-inla:
	@echo "Testing $(INLA_IMAGE) with INLA_baseline_model..."
	docker run --rm -v $(PWD)/test-repos/INLA_baseline_model:/app -w /app $(INLA_IMAGE):latest Rscript isolated_run.R

test-inla-mini:
	@echo "Testing $(INLA_MINI_IMAGE) with INLA_baseline_model..."
	docker run --rm -v $(PWD)/test-repos/INLA_baseline_model:/app -w /app $(INLA_MINI_IMAGE):latest Rscript isolated_run.R

# Clean: remove all images
.PHONY: clean
clean:
	-docker rmi $(BASE_IMAGE):latest
	-docker rmi $(INLA_IMAGE):latest
	-docker rmi $(INLA_MINI_IMAGE):latest

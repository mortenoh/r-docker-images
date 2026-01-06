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
	@echo "  make test-inla       - Test $(INLA_IMAGE) with chap_model_template_r"
	@echo "  make test-inla-mini  - Test $(INLA_MINI_IMAGE) with chap_model_template_r"
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
	docker build --quiet --no-cache --platform linux/amd64 -t $(INLA_IMAGE):latest -f Dockerfile.inla .

.PHONY: build-inla-mini
build-inla-mini:
	docker build --quiet --no-cache --platform linux/amd64 -t $(INLA_MINI_IMAGE):latest -f Dockerfile.inla-mini .

# Show image sizes (virtual size includes shared base layers)
.PHONY: size
size:
	@echo "Image sizes (virtual / unique content):"
	@docker images $(BASE_IMAGE):latest --format "  $(BASE_IMAGE):\t{{.Size}}" 2>/dev/null || echo "  $(BASE_IMAGE):\tnot built"
	@docker images $(INLA_IMAGE):latest --format "  $(INLA_IMAGE):\t{{.Size}}" 2>/dev/null || echo "  $(INLA_IMAGE):\tnot built"
	@docker images $(INLA_MINI_IMAGE):latest --format "  $(INLA_MINI_IMAGE):\t{{.Size}}" 2>/dev/null || echo "  $(INLA_MINI_IMAGE):\tnot built"

# Test targets
.PHONY: test test-base test-inla test-inla-mini

test: test-base test-inla test-inla-mini

test-base:
	@echo "Testing $(BASE_IMAGE) with minimalist_example_r..."
	docker run --rm -v $(PWD)/test-repos/minimalist_example_r:/app -w /app $(BASE_IMAGE):latest Rscript isolated_run.r

test-inla:
	@echo "Testing $(INLA_IMAGE) with chap_model_template_r..."
	docker run --rm --platform linux/amd64 -v $(PWD)/test-repos/chap_model_template_r:/app -w /app $(INLA_IMAGE):latest Rscript isolated_run.r

test-inla-mini:
	@echo "Testing $(INLA_MINI_IMAGE) with chap_model_template_r..."
	docker run --rm --platform linux/amd64 -v $(PWD)/test-repos/chap_model_template_r:/app -w /app $(INLA_MINI_IMAGE):latest Rscript isolated_run.r

# Clean: remove all images (force, ignore errors)
.PHONY: clean
clean:
	@docker rmi -f $(BASE_IMAGE):latest 2>/dev/null || true
	@docker rmi -f $(INLA_IMAGE):latest 2>/dev/null || true
	@docker rmi -f $(INLA_MINI_IMAGE):latest 2>/dev/null || true
	@echo "Cleaned"

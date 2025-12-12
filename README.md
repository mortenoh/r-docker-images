# R Docker Images

Docker images for R with optional INLA (Integrated Nested Laplace Approximation) support.

## Images

| Image | Size | Architecture | Description |
|-------|------|--------------|-------------|
| `my-r-base` | ~437 MB | amd64, arm64 | Base R runtime |
| `my-r-inla` | ~2.1 GB | amd64 only | R + INLA + full build tools |
| `my-r-inla-mini` | ~850 MB | amd64 only | R + INLA optimized (no build tools) |

**Note:** INLA only provides x86_64 Linux binaries. The INLA images must be built and run with `--platform linux/amd64` on ARM systems (e.g., Apple Silicon).

## Quick Start

```bash
# Build all images
make build

# Build specific image
make build-base       # Base R only
make build-inla       # R + INLA (full)
make build-inla-mini  # R + INLA (optimized)

# Run tests
make test

# Check image sizes
make size
```

## Usage

### Base R
```bash
docker run --rm -v $(pwd):/app -w /app my-r-base:latest Rscript script.r
```

### INLA (on ARM/Apple Silicon)
```bash
docker run --rm --platform linux/amd64 \
  -v $(pwd):/app -w /app \
  my-r-inla-mini:latest Rscript script.R
```

## Included R Packages

### my-r-base
- Base R only (CRAN packages can be installed at runtime)

### my-r-inla / my-r-inla-mini
- INLA (Bayesian inference)
- fmesher (mesh generation for INLA)
- sf (spatial features)
- spdep (spatial dependence)
- dplyr (data manipulation)
- dlnm (distributed lag non-linear models)
- yaml, jsonlite (data formats)

## Building for CI/CD

The GitHub Actions workflow (`.github/workflows/build.yml`) automatically:
- Builds `my-r-base` for linux/amd64 and linux/arm64
- Builds INLA images for linux/amd64 only
- Pushes to GitHub Container Registry (ghcr.io)
- Runs tests against sample repositories

## Test Repositories

The `test-repos/` directory contains sample projects for testing:
- `minimalist_example_r/` - Basic R linear regression (tests my-r-base)
- `INLA_baseline_model/` - INLA spatial model (tests my-r-inla*)

## Architecture Notes

INLA downloads precompiled x86_64 binaries during installation. There is no native ARM64 support. Options for ARM users:

1. **Recommended:** Use `--platform linux/amd64` with Rosetta 2 emulation
2. Build from source (complex, requires patching x86-specific compiler flags)
3. Use alternative packages (Stan, brms, PyMC for Python)

## Optimizations

The mini image achieves ~60% size reduction through:
- Multi-stage build (build tools not in final image)
- `dep=FALSE` for INLA (avoids installing 150+ suggested packages)
- Stripped debug symbols from shared libraries
- Removed help/doc/html files from R packages

## License

MIT

# R 4.5 on Debian 13 (trixie). Debian ships the R we want natively,
# so we skip the CRAN apt dance that was needed on Ubuntu noble.

FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  ca-certificates \
  r-base \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# When you `docker run -it image`, you drop directly into the R shell
CMD ["R"]

# Dockerfile: Ubuntu 24.04 + CRAN R (noble-cran40) + R shell as default

FROM ubuntu:24.04

# Avoid interactive prompts during package install
ENV DEBIAN_FRONTEND=noninteractive

# Set a sane locale
RUN apt-get update \
  && apt-get install -y --no-install-recommends locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LANG=en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
  LC_ALL=en_US.UTF-8

# Install basic tools and HTTPS support
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  wget \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Add CRAN signing key (Michael Rutter) and CRAN repo for Ubuntu Noble
# This matches the official CRAN Ubuntu instructions, adapted for root in Docker.  [oai_citation:1‡CRAN](https://cran.r-project.org/bin/linux/ubuntu/fullREADME.html?utm_source=chatgpt.com)
RUN wget -qO /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc \
  https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
  && echo "deb https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" \
  > /etc/apt/sources.list.d/cran-r.list

# Install R (runtime only, no dev headers)
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  r-base \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Default working directory
WORKDIR /workspace

# When you `docker run -it image`, you drop directly into the R shell
CMD ["R"]

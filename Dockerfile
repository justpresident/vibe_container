FROM node:lts-slim

ARG TZ
ENV TZ="$TZ"

ARG CLAUDE_CODE_VERSION=latest
ARG GEMINI_VERSION=latest

# Install basic development tools and iptables/ipset
RUN apt-get update && apt-get install -y --no-install-recommends \
  aggregate \
  bash \
  build-essential \
  ca-certificates \
  curl \
  dnsutils \
  fzf \
  gh \
  git \
  gnupg2 \
  grep \
  iproute2 \
  ipset \
  iptables \
  iputils-ping \
  jq \
  less \
  man-db \
  mc \
  nano \
  procps \
  ripgrep \
  sudo \
  tree \
  unzip \
  vim \
  wget \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ARG USERNAME=node

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Create workspace and config directories and set permissions
RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

# Set up non-root user
USER node

RUN git clone --depth=1 https://github.com/justpresident/bootstrap.git ~/bootstrap && cd ~/bootstrap && UPDATE_FONTS=n ./bootstrap.sh

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH=/home/node/.cargo/bin:${PATH}
RUN rustup component add rust-analyzer
RUN cargo install taska
##############

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

ENV SHELL=/bin/bash

# Set the default editor and visual
ENV EDITOR=vim
ENV VISUAL=vim


# Install Claude
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Install Gemini
RUN npm install -g @google/gemini-cli@${GEMINI_VERSION}

# Install Codex
RUN npm i -g @openai/codex

USER node

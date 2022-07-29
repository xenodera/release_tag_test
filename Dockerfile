FROM rust:1.62.1-slim-bullseye AS dev

# ローカルのtargetディレクトリにビルドするとマウントしている時に遅くなるのでビルドディレクトリを変える
ENV CARGO_TARGET_DIR=/tmp/target \
  DEBIAN_FRONTEND=noninteractive \
  LC_CTYPE=ja_JP.utf8 \
  LANG=ja_JP.utf8

RUN apt-get update \
  && apt-get install -y -q \
  ca-certificates \
  locales \
  libpq-dev \
  gnupg \
  apt-transport-https\
  libssl-dev \
  pkg-config \
  curl \
  build-essential \
  git \
  clang \
  cmake \
  libstdc++-10-dev \
  libssl-dev \
  libxxhash-dev \
  zlib1g-dev \
  && echo "ja_JP UTF-8" > /etc/locale.gen \
  && locale-gen \
  && echo "install mold" \
  && cd /tmp \
  && git clone https://github.com/rui314/mold.git \
  && cd mold \
  && git checkout v1.0.1 \
  && make -j$(nproc) CXX=clang++ \
  && make install

RUN echo "install rust tools" \
  && rustup component add clippy \
  && cargo install cargo-watch cargo-make \
  && chmod go-w /usr/local/cargo /usr/local/cargo/bin

WORKDIR /app

COPY Cargo.toml ./Cargo.toml
COPY src/main.rs ./src/main.rs

RUN RUSTFLAGS="-C debuginfo=1" cargo build \
  --release --color never \
  --bin release-tag-test

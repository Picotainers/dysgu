FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

ARG DYSGU_REPO=https://github.com/kcleal/dysgu.git
ARG DYSGU_REF=v1.9.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      curl \
      git \
      libbz2-dev \
      libcurl4-openssl-dev \
      libdeflate-dev \
      liblzma-dev \
      libssl-dev \
      pkg-config \
      python3 \
      python3-dev \
      python3-pip \
      python3-venv \
      zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/samtools/htslib/releases/download/1.21/htslib-1.21.tar.bz2 | tar xj -C /tmp && \
    mv /tmp/htslib-1.21 /tmp/htslib && \
    cd /tmp/htslib && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    rm -rf /tmp/htslib

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

RUN pip install --no-cache-dir --upgrade pip setuptools wheel meson ninja

RUN git clone --depth 1 --branch "${DYSGU_REF}" "${DYSGU_REPO}" /tmp/dysgu && \
    pip install --no-cache-dir /tmp/dysgu && \
    rm -rf /tmp/dysgu

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      libcurl4 \
      libdeflate0 \
      libgomp1 \
      libstdc++6 \
      python3 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /usr/local/lib/libhts* /usr/local/lib/
COPY --from=builder /usr/local/lib/libdeflate* /usr/local/lib/

RUN ldconfig

ENV PATH="/opt/venv/bin:${PATH}"

WORKDIR /data
ENTRYPOINT ["dysgu"]
CMD ["--help"]

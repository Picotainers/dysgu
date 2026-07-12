FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      autoconf \
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

RUN git clone --depth 1 --branch 1.21 https://github.com/samtools/htslib.git /tmp/htslib && \
    cd /tmp/htslib && \
    autoreconf -i && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    rm -rf /tmp/htslib

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

RUN pip install --no-cache-dir --upgrade pip setuptools wheel meson ninja

RUN git clone --depth 1 https://github.com/kcleal/dysgu.git /tmp/dysgu && \
    pip install --no-cache-dir /tmp/dysgu && \
    rm -rf /tmp/dysgu

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
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

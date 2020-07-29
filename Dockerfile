FROM python:3.8-buster as base

FROM base as builder
RUN mkdir /install
WORKDIR /install
COPY requirements.txt /tmp/requirements.txt
RUN pip install --install-option="--prefix=/install" -r /tmp/requirements.txt

FROM base as prod
ARG VCS_REF=unknown
ARG BUILD_DATE=unknown
ARG VERSION=0.0
LABEL maintainer="cseelye@gmail.com" \
      org.opencontainers.image.authors="cseelye@gmail.com" \
      org.opencontainers.image.url="https://github.com/cseelye/pydevbase" \
      org.opencontainers.image.title="pydevbase" \
      org.opencontainers.image.description="Sample docker image/makefile/CICD" \
      org.opencontainers.image.revision="$VCS_REF" \
      org.opencontainers.image.created="$BUILD_DATE" \
      org.opencontainers.image.version="$VERSION"

ENV TERM=xterm-color
ENV PYTHONUNBUFFERED=1

COPY --from=builder /install /usr/local
COPY tool /tool

WORKDIR /tool
ENTRYPOINT ["standalone.py"]

FROM prod as dev
COPY requirements.txt /tmp/requirements.txt
COPY requirements_dev.txt /tmp/requirements_dev.txt
RUN pip install -r /tmp/requirements_dev.txt
ENTRYPOINT []

FROM alpine:3.10

ARG VCS_REF=unknown
ARG BUILD_DATE=unknown
ARG VERSION=0.0
ARG IMAGE_NAME=simplemonitor
LABEL maintainer="cseelye@gmail.com" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.description="Container for SimpleMonitor" \
      org.label-schema.docker.cmd="docker run --detach --volume /abspath/mymainconfig.ini:/monitor/monitor.ini --volume /abspath/mymonitorconfig.ini:/monitor/monitors.ini cseelye/simplemonitor" \
      org.label-schema.name=$IMAGE_NAME \
      org.label-schema.url="https://github.com/jamesoff/simplemonitor" \
      org.label-schema.vcs-url="https://github.com/cseelye/simplemonitor-container" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

RUN apk update && \
    apk add \
        bind-tools \
        curl \
        iputils \
        python3 \
        py3-cryptography \
        tar && \
    curl -L https://bootstrap.pypa.io/get-pip.py | python3 && \
    mkdir -p /monitor && \
    curl -L https://github.com/jamesoff/simplemonitor/tarball/master | tar --strip-components 1 -xzC /monitor && \
    cd /monitor && \
    pip install -r requirements.txt

WORKDIR /monitor
ENTRYPOINT ["python3", "monitor.py"]


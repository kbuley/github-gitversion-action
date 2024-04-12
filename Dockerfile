ARG ALPINE_VERSION=3.19
ARG GITVERSION_VERSION=5.12.0

FROM alpine:${ALPINE_VERSION}

LABEL "repository"="https://github.com/kbuley/github-gitversion-action"
LABEL "homepage"="https://github.com/kbuley/github-gitversion-action"
LABEL "maintainer"="Kevin Buley"

RUN apk --no-cache add bash git curl jq

RUN case "${TARGETARCH}" in \
  arm64) export GVARCH='arm64' ;; \
  amd64) export GVARCH='x64' ;; \
  esac  \
  && wget --progress=dot:giga "https://github.com/GitTools/GitVersion/releases/download/${GITVERSION_VERSION}/gitversion-linux-musl-${GVARCH}-${GITVERSION_VERSION}.tar.gz" \
  && tar zxvf "gitversion-linux-musl-${GVARCH}-${GITVERSION_VERSION}.tar.gz" \
  && mv gitversion /bin \
  && chmod +rx /bin/gitversion

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

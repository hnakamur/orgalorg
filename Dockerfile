# syntax = docker/dockerfile:experimental

# use golang base image
ARG GO_VERSION=1.13.3
FROM golang:${GO_VERSION}-buster

# install nfpm
ARG NFPM_VERSION=v1.1.0
ADD https://github.com/goreleaser/nfpm/releases/download/${NFPM_VERSION}/nfpm_amd64.deb /tmp/
RUN dpkg -i /tmp/nfpm_amd64.deb

# install github-release
ARG GITHUB_RELEASE_VERSION=v0.7.2
RUN curl -sSL https://github.com/hnakamur/github-release/releases/download/$GITHUB_RELEASE_VERSION/github-release.linux-amd64.tar.gz | tar zxf - -C /usr/local/bin

# Build executable to ./orgalorg
COPY . /src
WORKDIR /src
RUN go build -tags 'osusergo netgo' .

# build packages
ARG VERSION
RUN tar cf - orgalorg | gzip -9 > orgalorg.linux-amd64.tar.gz
RUN nfpm pkg --target orgalorg.amd64.deb

## make release
ARG GITHUB_USER=hnakamur
ARG GITHUB_REPO=orgalorg
ARG COMMIT
RUN --mount=type=secret,id=github_token,target=/github_token \
  github-release release \
    -s $(cat /github_token) \
    -t v$VERSION \
    -c $COMMIT \
  && github-release upload \
    -s $(cat /github_token) \
    -t v$VERSION \
    -f orgalorg.linux-amd64.tar.gz \
    -n orgalorg.linux-amd64.tar.gz \
  && github-release upload \
    -s $(cat /github_token) \
    -t v$VERSION \
    -f orgalorg.amd64.deb \
    -n orgalorg.amd64.deb

FROM --platform=$BUILDPLATFORM golang:1.20.1 as builder

ARG COREDNS_REF
WORKDIR /usr/src/app
RUN git clone https://github.com/coredns/coredns.git /usr/src/app &&\
  git checkout $COREDNS_REF

COPY extra-plugins.cfg .
RUN cat plugin.cfg extra-plugins.cfg > plugin.cfg
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH make


FROM --platform=$TARGETPLATFORM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/src/app/coredns /coredns

EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]

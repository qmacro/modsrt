FROM alpine:3.19

RUN apk add bash jq
COPY modsrt.jq entrypoint /

ENTRYPOINT ["/entrypoint"]
CMD ["--help"]

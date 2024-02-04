FROM alpine:3.19 AS buildv
WORKDIR /vlang
RUN apk --no-cache --update-cache add musl-dev libc-dev gc-dev git make gcc upx
RUN git clone --filter=blob:none https://github.com/vlang/v /vlang
RUN cd /vlang; make; /vlang/v version
RUN /vlang/v symlink

WORKDIR /edu
COPY . .
RUN mkdir /app
RUN v -v install
RUN v -compress -cflags -static -cc gcc -prod -d trace_request_url -skip-unused -o /app/edu-platform .
RUN mv ./assets /app && mv ./lessons /app && mv ./templates /app

FROM scratch
LABEL maintainer="Delyan Angelov <delian66@gmail.com>"
COPY --from=buildv /app /app

EXPOSE 8082/tcp
ENTRYPOINT ["/app/edu-platform"]

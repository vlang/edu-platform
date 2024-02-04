FROM alpine:3.19 AS buildv
WORKDIR /vlang
RUN apk --no-cache --update-cache add musl-dev libc-dev gc-dev git make gcc upx
RUN git clone --filter=blob:none https://github.com/vlang/v /vlang
RUN cd /vlang; make; /vlang/v version
RUN /vlang/v symlink

FROM buildv as buildapp
WORKDIR /app
COPY . .
COPY --from=buildv /vlang/v /vlang/v 
RUN /vlang/v symlink
RUN /vlang/v -v install
RUN /vlang/v -compress -cflags -static -cc gcc -prod -d trace_request_url -skip-unused -o edu-platform .

FROM alpine:3.19 as final
LABEL maintainer="Delyan Angelov <delian66@gmail.com>"
WORKDIR /app
COPY ./lessons.json ./lessons.json
COPY ./lessons      ./lessons
COPY ./templates    ./templates
COPY ./assets       ./assets
COPY --from=buildapp /app/edu-platform ./edu-platform

EXPOSE 8082
ENTRYPOINT ["./edu-platform"]

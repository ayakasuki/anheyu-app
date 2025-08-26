FROM alpine:latest

ARG TARGETARCH

WORKDIR /anheyu

RUN apk update \
    && apk add --no-cache tzdata vips-tools ffmpeg libheif libraw-tools \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

RUN if [ "$TARGETARCH" = "amd64" ]; then \
        apk add --no-cache wget ca-certificates \
        && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
        && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-2.35-r0.apk \
        && apk add --no-cache glibc-2.35-r0.apk \
        && rm glibc-2.35-r0.apk \
    ; fi

ENV LD_LIBRARY_PATH="/lib:/usr/glibc-compat/lib:$LD_LIBRARY_PATH" \
    AN_SETTING_DEFAULT_ENABLE_FFMPEG_GENERATOR=true \
    AN_SETTING_DEFAULT_ENABLE_VIPS_GENERATOR=true \
    AN_SETTING_DEFAULT_ENABLE_LIBRAW_GENERATOR=true

COPY anheyu-app-linux-${TARGETARCH} ./anheyu-app

COPY default_files ./default-data

COPY entrypoint.sh ./entrypoint.sh

RUN chmod +x ./anheyu-app ./entrypoint.sh

EXPOSE 8091 443

ENTRYPOINT ["./entrypoint.sh"]
CMD ["./anheyu-app"]
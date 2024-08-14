FROM alpine:3.16

RUN <<EOF
apk update
apk add --no-cache nodejs npm
npm install -g serve
EOF

COPY ./build build/

ENTRYPOINT serve -s build

EXPOSE 3000

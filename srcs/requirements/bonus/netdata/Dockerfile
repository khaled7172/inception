FROM alpine:3.23

RUN apk update && apk add --no-cache netdata

EXPOSE 19999

# -D = run in foreground (real PID 1 process, no daemonizing / hacky loops)
CMD ["netdata", "-D"]

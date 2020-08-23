#            FROM golang:1.15.0-alpine3.12          alpine:3.12.0
#                      |                                 |
#                   builder                            runner

FROM golang:1.15.0-alpine3.12 as builder
LABEL maintainer="hi@geraldoandrade.com"
WORKDIR /go/src/github.com/open-ecommerce-microservices/product-service
RUN apk update && apk add --no-cache git make coreutils zip netcat-openbsd bash
COPY . .
RUN make build

FROM alpine:3.12.0 as runner
RUN apk update && apk add --no-cache ca-certificates
COPY --from=builder /go/src/github.com/open-ecommerce-microservices/product-service/bin/product-service /usr/bin/
ENV APP_PORT=8080
EXPOSE ${APP_PORT}
CMD [ "/usr/bin/product-service" ]
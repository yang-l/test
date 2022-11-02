FROM 305985460937.dkr.ecr.us-east-1.amazonaws.com/golang:1.19.3 as builder

WORKDIR /app

COPY src/ /app

RUN go test -v
RUN go build -o /server

FROM gcr.io/distroless/base-debian11

WORKDIR /

COPY --from=builder /server /server

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/server"]

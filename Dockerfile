FROM gcr.io/distroless/static

WORKDIR /

# Copy app binary
COPY ./runpubip .

EXPOSE 8080

CMD ["./runpubip"]

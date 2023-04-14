FROM node:16-alpine
RUN apk add --no-cache ca-certificates bash curl jq git
RUN npm install -g pnpm@7
WORKDIR /app
COPY . /app
RUN chmod +x /app/run-audit.sh
ENTRYPOINT ["/app/run-audit.sh"]

FROM node:16-alpine
RUN apk add --no-cache ca-certificates bash curl jq git
RUN npm install -g pnpm@7
COPY . .
RUN chmod +x /run-audit.sh
ENTRYPOINT ["/run-audit.sh"]

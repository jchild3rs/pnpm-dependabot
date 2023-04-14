FROM node:16-alpine
RUN apk add --no-cache ca-certificates bash curl jq
RUN npm install -g pnpm@7
COPY run-audit.sh /run-audit.sh
RUN chmod +x /run-audit.sh
ENTRYPOINT ["/run-audit.sh"]

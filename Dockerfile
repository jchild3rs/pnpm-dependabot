FROM alpine:3.10
COPY run-audit.sh /run-audit.sh
RUN chmod +x /run-audit.sh
ENTRYPOINT ["/run-audit.sh"]

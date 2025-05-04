FROM alpine:3.21.3
ARG NEW_USER_NAME="admin"

RUN apk add --update --no-cache openssh python3 py3-psycopg2
COPY sshd_config /etc/ssh/sshd_config

ENV SSHD_CREATE_ROOT_KEY=true
ENV SSHD_CREATE_BASTION_KEY=true
ENV BASTION_USER=admin
ENV BASTION_PASSWORD=password

ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 22
COPY entrypoint.sh /
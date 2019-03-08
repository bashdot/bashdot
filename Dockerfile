FROM ubuntu

RUN apt-get update
RUN apt-get install -y bats
RUN mkdir -p /root/profiles/public /root/profiles/private

COPY dotfiler /usr/bin
COPY profiles/public /root/profiles/public/
COPY profiles/private /root/profiles/private/
COPY test.bats /root

ENTRYPOINT ["bats", "/root/test.bats"]

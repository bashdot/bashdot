FROM ubuntu

RUN apt-get update
RUN apt-get install -y bats
RUN mkdir -p /root/profiles

COPY bashdot /usr/bin
COPY profiles/ /root/profiles/
COPY test.bats /root

RUN chmod 755 /usr/bin/bashdot

ENTRYPOINT ["bats", "/root/test.bats"]

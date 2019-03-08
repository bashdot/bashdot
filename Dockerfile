FROM ubuntu

RUN apt-get update
RUN apt-get install -y bats
RUN mkdir -p /root/profiles/public /root/profiles/private

COPY bashdot /usr/bin
COPY profiles/public /root/profiles/public/
COPY profiles/private /root/profiles/private/
COPY test.bats /root

RUN chmod 755 /usr/bin/bashdot
RUN rm /root/.bashrc /root/.profile

ENTRYPOINT ["bats", "/root/test.bats"]

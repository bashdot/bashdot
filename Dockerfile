FROM ubuntu

RUN apt-get update
RUN apt-get install -y bats
RUN mkdir -p /root/profiles/home /root/profiles/shared /root/profiles/work

COPY bashdot /usr/bin
COPY profiles/home /root/profiles/home/
COPY profiles/shared /root/profiles/shared/
COPY profiles/work /root/profiles/work/
COPY test.bats /root

RUN chmod 755 /usr/bin/bashdot
RUN rm /root/.bashrc /root/.profile

ENTRYPOINT ["bats", "/root/test.bats"]

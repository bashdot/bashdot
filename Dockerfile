FROM ubuntu

RUN apt-get update
RUN apt-get install -y bats

RUN mkdir -p /root/profiles /root/another_test/profiles

COPY testdata/profiles/ /root/profiles/
COPY testdata/profiles/ /root/another_test/profiles/
COPY bashdot /usr/bin
COPY test.bats /root

RUN chmod 755 /usr/bin/bashdot
RUN rm -f /root/.bashrc

ENTRYPOINT ["bats", "/root/test.bats"]

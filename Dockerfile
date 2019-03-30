FROM ubuntu

RUN apt-get update --fix-missing
RUN apt-get install -y bats vim

RUN mkdir -p /root/another_test

COPY testdata/ /root/
COPY testdata/ /root/another_test/
COPY bashdot /usr/bin
COPY test.bats /root

RUN chmod 755 /usr/bin/bashdot
RUN rm -f /root/.bashrc

ENTRYPOINT ["bats", "/root/test.bats"]

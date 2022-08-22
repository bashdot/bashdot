FROM cimg/base:2022.05

RUN sudo mkdir -p /var/lib/apt/lists/partial /root
RUN sudo apt-get update --fix-missing
RUN sudo apt-get install -y bats vim

RUN mkdir -p /home/circleci/another_test

COPY testdata/ /home/circleci/
COPY testdata/ /home/circleci/another_test/
COPY bashdot /usr/bin
COPY test.bats /home/circleci/
RUN sudo chown -R circleci /home/circleci

RUN sudo chmod 755 /usr/bin/bashdot
RUN rm -f /home/circleci/.bashrc

ENTRYPOINT ["bats", "/home/circleci/test.bats"]

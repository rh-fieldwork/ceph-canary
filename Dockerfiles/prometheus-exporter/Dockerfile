FROM registry.redhat.io/ubi8/ubi

# Install python and prometheus-client
RUN dnf -y install python3 python3-pip && \
    pip3 install 'prometheus-client==0.10.1'

EXPOSE 8000

CMD tail -f /dev/null

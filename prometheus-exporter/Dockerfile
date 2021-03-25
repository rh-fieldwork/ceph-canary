FROM registry.redhat.io/ubi8/ubi

# Install python and prometheus-client
RUN dnf -y install python3 python3-pip rsync && \
    pip3 install prometheus-client

# Create work directory 
RUN mkdir /exporter && chmod 777 /exporter

EXPOSE 8000

CMD tail -f /dev/null

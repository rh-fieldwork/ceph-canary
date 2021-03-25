FROM registry.redhat.io/ubi8/ubi

# Install python and prometheus-client
RUN dnf -y install python3 python3-pip rsync && \
    pip3 install prometheus-client

# Copy scripts and config file
COPY /exporter/ /exporter/
RUN chmod 777 /exporter

EXPOSE 8000

# The run script uses standard ways to run the application
CMD ["python3", "/exporter/prometheusclient.py"]

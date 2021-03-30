FROM registry.fedoraproject.org/fedora-minimal:32

# Install fio
RUN microdnf install fio vi && microdnf clean all

# Create work directory.
RUN mkdir -p /scripts  && chmod 777 /scripts
WORKDIR scripts

CMD tail -f /dev/null 

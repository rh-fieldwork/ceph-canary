FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

#  Install required packages for fio.
RUN microdnf install gcc make git zlib-devel \
 && microdnf clean all

# Install fio.
RUN git clone --depth=1 git://github.com/axboe/fio.git fio \
 && cd fio/ \
 && ./configure \
 && make && make install \
 && microdnf remove gcc

# Create work directory.
RUN mkdir -p /scripts \
 && chmod 777 /scripts
WORKDIR scripts

CMD tail -f /dev/null

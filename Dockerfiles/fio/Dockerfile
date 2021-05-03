FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

#  Install required packages for fio.
RUN microdnf install gcc make git zlib-devel \
 && microdnf clean all

# Install fio.
RUN git clone --depth 1 --branch fio-3.26 git://github.com/axboe/fio.git fio \
 && cd fio/ \
 && ./configure \
 && make && make install \
 && microdnf remove gcc

CMD tail -f /dev/null

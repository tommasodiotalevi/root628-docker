FROM dciangot/dask-scheduler:v8

RUN yum -y update \
    && yum -y upgrade \
    && yum -y install davix libXpm-devel libXft-devel cmake\
    && yum -y clean all 



# Build ROOT 6.28

RUN git clone --branch v6-28-00 --depth=1 https://github.com/root-project/root.git root_src
RUN mkdir root_build
RUN cmake -Dgminimal=ON -Dpyroot=ON -Ddataframe=ON -Dgnuinstall=ON -Ddev=ON \
          -Dbuiltin_xrootd=ON -Dxrootd=ON -Dbuiltin_davix=ON -Ddavix=ON  \
          -Dtmva=ON -Dmlp=ON -Dtmva-pymva=ON -Dtmva-cpu=ON -Dtmva-sofie=ON \
          -Dasimage=ON -Druntime_cxxmodules=ON \
          -B root_build -S root_src
RUN cmake --build root_build -- install -j$(nproc)
# Remove artifacts
RUN rm -rf root_build root_src

# Change environment so that libraries are properly found
RUN echo /usr/local/lib/root >> /etc/ld.so.conf && ldconfig
ENV PYTHONPATH /usr/local/lib/root:$PYTHONPATH
ENV CLING_STANDARD_PCH none

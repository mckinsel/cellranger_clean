FROM ubuntu:zesty

# Install dependencies for cellranger
RUN apt-get update \
 && apt-get install -y \
    cython \
    golang-1.8 \
    libbz2-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libgfortran-5-dev \
    libffi-dev \
    libhdf5-dev \
    libncurses-dev \
    libpixman-1-dev \
    libpng-dev \
    libsodium-dev \
    libssl-dev \
    libtiff5-dev \
    libxml2-dev \
    libxslt1-dev \
    libzmq3-dev \
    python-cairo \
    python-h5py \
    python-libtiff \
    python-matplotlib \
    python-nacl \
    python-numpy \
    python-pip \
    python-libxml2 \
    python-redis \
    python-ruamel.yaml \
    python-sip \
    python-sqlite \
    python-tables \
    python-tk \
    samtools \
    zlib1g-dev

RUN ln -s /usr/lib/go-1.8/bin/go /usr/bin/go

COPY requirements.txt /opt/requirements.txt
RUN pip install -r /opt/requirements.txt

# Install rust and cargo. Note that installing with apt gets a rust that won't complie
# cellranger.
RUN apt-get install -y \
    curl \
    git \
 && curl https://sh.rustup.rs -sSf | sh -s -- -y

ENV PATH /root/.cargo/bin/:$PATH

# Build cellranger itself 
RUN git clone https://github.com/mckinsel/cellranger.git \
 && cd cellranger \
 && make

# Install Martian. Note that we're just building the executables, not the web stuff
RUN git clone --recursive https://github.com/martian-lang/martian.git \
 && cd martian \
 && make mrc mrf mrg mrp mrs mrt_helper mrstat mrjob

# Set up paths to cellranger. This is most of what sourceme.bash would do.
ENV PATH /cellranger/bin/:/cellranger/lib/bin:/cellranger/tenkit/bin/:/cellranger/tenkit/lib/bin:/martian/bin/:$PATH
ENV PYTHONPATH /cellranger/lib/python:/cellranger/tenkit/lib/python:$PYTHONPATH
ENV MROPATH /cellranger/mro/:/cellranger/tenkit/mro/
ENV _TENX_LD_LIBRARY_PATH whatever

# Install bcl2fastq. mkfastq requires it.
RUN apt-get update \
 && apt-get install -y alien unzip wget \
 && wget https://support.illumina.com/content/dam/illumina-support/documents/downloads/software/bcl2fastq/bcl2fastq2-v2-19-1-linux.zip \
 && unzip bcl2fastq2*.zip \
 && alien bcl2fastq2*.rpm \
 && dpkg -i bcl2fastq2*.deb \
 && rm bcl2fastq2*.deb bcl2fastq2*.rpm bcl2fastq2*.zip

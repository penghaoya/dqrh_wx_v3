FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    MPLBACKEND=Agg \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:${PATH}"

ARG INSTALL_TORCH=0

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        ca-certificates \
        gfortran \
        libeccodes-dev \
        libgeos-dev \
        libgl1 \
        libglib2.0-0 \
        libhdf5-dev \
        libnetcdf-dev \
        libproj-dev \
        libgomp1 \
        pkg-config \
        proj-bin \
        tzdata && \
    rm -rf /var/lib/apt/lists/*

RUN python -m venv "${VIRTUAL_ENV}" && \
    pip install --upgrade \
        Cython==0.29.37 \
        pip==24.2 \
        setuptools==75.1.0 \
        wheel==0.44.0 && \
    pip install --prefer-binary \
        numpy==1.26.4 \
        scipy==1.11.4 \
        pandas==2.2.3 \
        xarray==2024.7.0 \
        netCDF4==1.6.5 \
        h5py==3.11.0 \
        h5netcdf==1.3.0 \
        matplotlib==3.8.4 \
        pyproj==3.6.1 \
        shapely==2.0.6 \
        cartopy==0.23.0 \
        pykrige==1.7.2 \
        cfgrib==0.9.14.1 \
        metpy==1.6.3 \
        pillow==10.4.0 \
        opencv-python-headless==4.10.0.84 && \
    pip install --prefer-binary --no-build-isolation pygrib==2.1.6 && \
    if [ "${INSTALL_TORCH}" = "1" ]; then \
        pip install --prefer-binary torch==2.4.1; \
    fi

RUN mkdir -p /mnt/data2/DPS/WorkDir/EXE /opt/python-3.10.13/bin && \
    printf '%s\n' '#!/usr/bin/env sh' 'exec /opt/venv/bin/python "$@"' > /opt/python-3.10.13/bin/python && \
    printf '%s\n' '#!/usr/bin/env sh' 'exec /opt/venv/bin/pip "$@"' > /opt/python-3.10.13/bin/pip && \
    chmod +x /opt/python-3.10.13/bin/python /opt/python-3.10.13/bin/pip

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]

# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

# This Dockerfile is for DDM tutorial
# The buid from the base of minimal-notebook, based on python 3.8.8
 
ARG BASE_CONTAINER=jupyter/scipy-notebook:aarch64-python-3.8
FROM $BASE_CONTAINER

LABEL maintainer="Hu Chuan-Peng <hcp4715@hotmail.com>"

USER root

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y apt-utils && \
    apt-get install -y --no-install-recommends build-essential && \
    apt-get install -y --no-install-recommends gcc-aarch64-linux-gnu && \
    apt-get install -y --no-install-recommends g++-aarch64-linux-gnu && \
    apt-get install -y libatlas-base-dev && \
    apt-get install -y gfortran && \
    apt-get install -y libopenblas-dev && \
    apt-get install -y liblapack-dev && \
    apt-get install -y --no-install-recommends ffmpeg dvipng && \
    rm -rf /var/lib/apt/lists/*

# set the env variables
RUN export CC=aarch64-linux-gnu-gcc &&\
    export CXX=aarch64-linux-gnu-g++ &&\
    export LD=aarch64-linux-gnu-ld &&\
    export AR=aarch64-linux-gnu-ar &&\
    export CROSS_COMPILE=aarch64-linux-gnu-

USER $NB_UID

# Install Python 3 packages
RUN conda install --quiet --yes \
    'arviz=0.12.0' \
    'git' \
    'jupyter_bokeh' \
    && \
    conda clean --all -f -y && \
    fix-permissions "/home/${NB_USER}"

# conda install -c conda-forge python-graphviz
RUN conda install -c conda-forge --quiet --yes \
    'python-graphviz' \
    && \
    conda clean --all -f -y && \
    fix-permissions "/home/${NB_USER}"

# uinstall pymc 5 to avoid conflict:
RUN pip uninstall --no-cache-dir pymc -y && \
    pip uninstall --no-cache-dir pandas -y && \
    fix-permissions "/home/${NB_USER}"

USER $NB_UID
RUN pip install --upgrade pip && \
    pip install --no-cache-dir 'pandas==2.0.1' && \
    pip install --no-cache-dir 'plotly==4.14.3' && \
    pip install --no-cache-dir 'cufflinks==0.17.3' && \
    # install ptitprince for raincloud plot in python
    pip install --no-cache-dir 'ptitprince==0.2.*' && \
    pip install --no-cache-dir 'p_tqdm' && \
    # install paranoid-scientist for pyddm
    pip install --no-cache-dir 'paranoid-scientist' && \
    pip install --no-cache-dir 'pyddm' && \
    # install bambi
    pip install --no-cache-dir 'pymc3==3.11.*' && \
    pip install --no-cache-dir 'bambi==0.8.*' && \
    pip install --no-cache-dir git+https://github.com/hcp4715/pymc2 &&\
    # pip install --no-cache-dir git+https://github.com/hddm-devs/kabuki  
    pip install --no-cache-dir git+https://gitee.com/epool/kabuki.git && \ 
    pip install --no-cache-dir git+https://github.com/hddm-devs/hddm@3dcf4af58f2b7ce44c8b7e6a2afb21073d0a5ef9 && \
    fix-permissions "/home/${NB_USER}"

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" &&\
     fix-permissions "/home/${NB_USER}"

USER $NB_UID
WORKDIR $HOME

# Copy example data and scripts to the example folder
RUN mkdir /home/$NB_USER/scripts && \
    mkdir /home/$NB_USER/example && \
    rm -r /home/$NB_USER/work && \
    fix-permissions /home/$NB_USER

COPY /temp/HDDM_official_tutorial_reproduced.ipynb /home/${NB_USER}/example
COPY /temp/RLHDDMtutorial_reproduced.ipynb /home/${NB_USER}/example
COPY /scripts/HDDMarviz.py /home/${NB_USER}/scripts
COPY /scripts/plot_ppc_by_cond.py /home/${NB_USER}/scripts
COPY /scripts/pointwise_loglik_gen.py /home/${NB_USER}/scripts
COPY /scripts/post_pred_gen_redefined.py /home/${NB_USER}/scripts
COPY /scripts/InferenceDataFromHDDM.py /home/${NB_USER}/scripts
COPY /tutorial/dockerHDDM_tutorial.ipynb /home/${NB_USER}/example
COPY /tutorial/Run_all_models.py /home/${NB_USER}/example
COPY /tutorial/Def_Models.py /home/${NB_USER}/example
FROM ubuntu:20.04

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

ENV DEBIAN_FRONTEND noninteractive

##################################
#### ---- Tools: setup   ---- ####
##################################
ENV LANG C.UTF-8
ARG LIB_DEV_LIST="apt-utils"
ARG LIB_BASIC_LIST="curl wget unzip ca-certificates"
ARG LIB_COMMON_LIST="sudo bzip2 git xz-utils unzip vim net-tools"
ARG LIB_TOOL_LIST="graphviz"

RUN set -eux; \
    apt-get update -y && \
    apt-get install -y --no-install-recommends ${LIB_DEV_LIST}  ${LIB_BASIC_LIST}  ${LIB_COMMON_LIST} ${LIB_TOOL_LIST} && \
    apt-get clean -y && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf
    
##############################################
#### ---- Installation Directories   ---- ####
##############################################
ENV INSTALL_DIR=${INSTALL_DIR:-/usr}
ENV SCRIPT_DIR=${SCRIPT_DIR:-$INSTALL_DIR/scripts}

############################################
##### ---- System: certificates : ---- #####
##### ---- Corporate Proxy      : ---- #####
############################################
COPY ./scripts ${SCRIPT_DIR}
COPY certificates /certificates
RUN ${SCRIPT_DIR}/setup_system_certificates.sh
RUN ${SCRIPT_DIR}/setup_system_proxy.sh

#########################################
#### ---- Node from NODESOURCES ---- ####
#########################################
# Ref: https://github.com/nodesource/distributions
ARG NODE_VERSION=${NODE_VERSION:-current}
ENV NODE_VERSION=${NODE_VERSION}
RUN apt-get update -y && \
    curl -k -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean -y && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*
    
RUN cd ${SCRIPT_DIR}; ${SCRIPT_DIR}/setup_npm_proxy.sh

########################
#### ---- Yarn ---- ####
########################
# Ref: https://classic.yarnpkg.com/en/docs/install/#debian-stable
RUN curl -k -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -y && \ 
    apt-get install -y yarn && \
    apt-get clean -y && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

###################################
#### ---- user: developer ---- ####
###################################
#### ---------------------
#### ---- USER, GROUP ----
#### ---------------------
ENV USER=${USER:-developer}
ENV HOME=/home/${USER}

## -- setup NodeJS user profile
RUN groupadd ${USER} && useradd ${USER} -m -d ${HOME} -s /bin/bash -g ${USER} && \
    ## -- Ubuntu -- \
    usermod -aG sudo ${USER} && \
    ## -- Centos -- \
    #usermod -aG wheel ${USER} && \
    echo "${USER} ALL=NOPASSWD:ALL" | tee -a /etc/sudoers && \
    echo "USER =======> ${USER}" && ls -al ${HOME}

#########################################
##### ---- Docker Entrypoint : ---- #####
#########################################
ENV APP_HOME=${APP_HOME:-$HOME/app}
ENV APP_MAIN=${APP_MAIN:-setup.sh}

COPY --chown=${USER}:${USER} docker-entrypoint.sh /
COPY --chown=$USER:$USER app ${APP_HOME}
COPY --chown=$USER:$USER ${APP_MAIN} ${APP_HOME}/

ENTRYPOINT ["/docker-entrypoint.sh"]

#####################################
##### ---- user: developer ---- #####
#####################################
WORKDIR ${APP_HOME}
USER ${USER}

ENTRYPOINT ["/docker-entrypoint.sh"]

#### (Test only)
CMD ["setup.sh"]
#CMD ["/bin/bash"]


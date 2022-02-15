FROM ubuntu:20.04

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

ENV DEBIAN_FRONTEND noninteractive

##############################################
#### ---- Installation Directories   ---- ####
##############################################
ENV INSTALL_DIR=${INSTALL_DIR:-/usr}
ENV SCRIPT_DIR=${SCRIPT_DIR:-$INSTALL_DIR/scripts}

##############################################
#### ---- Corporate Proxy Auto Setup ---- ####
##############################################
#### ---- Transfer setup ---- ####
COPY ./scripts ${SCRIPT_DIR}
RUN chmod +x ${SCRIPT_DIR}/*.sh

#### ---- Apt Proxy & NPM Proxy & NPM Permission setup if detected: ---- ####
RUN cd ${SCRIPT_DIR} && ${SCRIPT_DIR}/setup_system_proxy.sh

########################################
#### update ubuntu and Install commons
########################################
ARG LIB_DEV_LIST="apt-utils"
ARG LIB_BASIC_LIST="curl wget unzip ca-certificates"
ARG LIB_COMMON_LIST="sudo bzip2 git xz-utils unzip vim"
ARG LIB_TOOL_LIST="graphviz"

RUN apt-get update -y && \
    apt-get install -y ${LIB_DEV_LIST}  ${LIB_BASIC_LIST}  ${LIB_COMMON_LIST} ${LIB_TOOL_LIST} && \
    apt-get install -y sudo && \
    apt-get clean -y && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

#########################################
#### ---- Node from NODESOURCES ---- ####
#########################################
# Ref: https://github.com/nodesource/distributions
ARG NODE_VERSION=${NODE_VERSION:-current}
ENV NODE_VERSION=${NODE_VERSION}
RUN apt-get update -y && \
    curl -k -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
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

COPY --chown=$USER:$USER app ${APP_HOME}
COPY --chown=$USER:$USER ${APP_MAIN} ${APP_HOME}/

COPY --chown=${USER}:${USER} docker-entrypoint.sh /
COPY --chown=${USER}:${USER} scripts /scripts
COPY --chown=${USER}:${USER} certificates /certificates
RUN /scripts/setup_system_certificates.sh

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


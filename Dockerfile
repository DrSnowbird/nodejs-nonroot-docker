FROM ubuntu:20.04

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

ENV DEBIAN_FRONTEND noninteractive

#### ---------------------
#### ---- USER, GROUP ----
#### ---------------------
ENV USER_ID=${USER_ID:-1000}
ENV GROUP_ID=${GROUP_ID:-1000}


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
ARG LIB_DEV_LIST="apt-utils automake pkg-config libpcre3-dev zlib1g-dev liblzma-dev"
ARG LIB_BASIC_LIST="curl iputils-ping nmap net-tools build-essential software-properties-common apt-transport-https"
ARG LIB_COMMON_LIST="bzip2 libbz2-dev git wget unzip vim python3-pip python3-setuptools python3-dev python3-venv python3-numpy python3-scipy python3-pandas python3-matplotlib"
ARG LIB_TOOL_LIST="graphviz libsqlite3-dev sqlite3 git xz-utils"

RUN apt-get update -y && \
    apt-get install -y ${LIB_DEV_LIST} && \
    apt-get install -y ${LIB_BASIC_LIST} && \
    apt-get install -y ${LIB_COMMON_LIST} && \
    apt-get install -y ${LIB_TOOL_LIST} && \
    apt-get install -y sudo && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

#########################################
#### ---- Node from NODESOURCES ---- ####
#########################################
# Ref: https://github.com/nodesource/distributions
ARG NODE_VERSION=${NODE_VERSION:-16}
ENV NODE_VERSION=${NODE_VERSION}
RUN apt-get update -y && \
    curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest
    
RUN cd ${SCRIPT_DIR}; ${SCRIPT_DIR}/setup_npm_proxy.sh

###################################
#### ---- user: developer ---- ####
###################################
ENV USER_ID=${USER_ID:-1000}
ENV GROUP_ID=${GROUP_ID:-1000}
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

COPY docker-entrypoint.sh /
COPY ${APP_MAIN}  ${APP_HOME}/

RUN sudo chmod +x /docker-entrypoint.sh

#####################################
##### ---- user: developer ---- #####
#####################################
WORKDIR ${APP_HOME}
USER ${USER}

ENTRYPOINT ["/docker-entrypoint.sh"]

#### (Test only)
CMD ["setup.sh"]
#CMD ["/bin/bash"]


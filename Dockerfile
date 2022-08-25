# Use the standard Amazon Linux base, provided by ECR/KaOS
# It points to the standard shared Amazon Linux image, with a versioned tag.
FROM amazonlinux:2

# https://docs.docker.com/engine/reference/builder/#maintainer-deprecated
LABEL maintainer="Amazon AWS"

# Framework Versions
ENV VERSION_NODE_12=12
ENV VERSION_NODE_DEFAULT=$VERSION_NODE_12
ENV VERSION_YARN=1.22.0
ENV VERSION_AMPLIFY=7.6.26

# UTF-8 Environment
ENV LANGUAGE en_US:en
ENV LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

## Install OS packages
RUN touch ~/.bashrc
RUN yum -y update && \
    yum -y install \
        alsa-lib-devel \
        autoconf \
        automake \
        bzip2 \
        bison \
        bzr \
        cmake \
        expect \
        fontconfig \
        git \
        gcc-c++ \
        GConf2-devel \
        gtk2-devel \
        gtk3-devel \
        libnotify-devel \
        libpng \
        libpng-devel \
        libffi-devel \
        libtool \
        libX11 \
        libXext \
        libxml2 \
        libxml2-devel \
        libXScrnSaver \
        libxslt \
        libxslt-devel \
        libyaml \
        libyaml-devel \
        make \
        nss-devel \
        openssl-devel \
        openssh-clients \
        patch \
        procps \
        python3 \
        python3-devel \
        readline-devel \
        sqlite-devel \
        tar \
        tree \
        unzip \
        wget \
        which \
        xorg-x11-server-Xvfb \
        zip \
        zlib \
        zlib-devel \
    yum clean all && \
    rm -rf /var/cache/yum

## Install python3.8
RUN wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz
RUN tar xvf Python-3.8.0.tgz
WORKDIR Python-3.8.0
RUN ./configure --enable-optimizations --prefix=/usr/local
RUN make altinstall

## Install Node
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
RUN /bin/bash -c ". ~/.nvm/nvm.sh &&     nvm install $VERSION_NODE_12 && nvm use $VERSION_NODE_12 && \
	npm install -g yarn@${VERSION_YARN} sm grunt-cli bower vuepress gatsby-cli && \
	nvm alias default ${VERSION_NODE_DEFAULT} && nvm cache clear"

# Handle yarn for any `nvm install` in the future
RUN echo "yarn@${VERSION_YARN}" > /root/.nvm/default-packages

## Install awscli
RUN /bin/bash -c "pip3.8 install awscli && rm -rf /var/cache/apk/*"

## Install SAM CLI
RUN /bin/bash -c "pip3.8 install aws-sam-cli"

## Installing Cypress
RUN /bin/bash -c ". ~/.nvm/nvm.sh && \
    nvm use ${VERSION_NODE_DEFAULT} && \
    npm install -g --unsafe-perm=true --allow-root cypress"

## Install AWS Amplify CLI for all node versions
RUN /bin/bash -c ". ~/.nvm/nvm.sh && nvm use ${VERSION_NODE_12} && \
    npm config set user 0 && npm config set unsafe-perm true && \
	npm install -g @aws-amplify/cli@${VERSION_AMPLIFY}"


## Environment Setup
RUN echo export PATH="/usr/local/rvm/bin:\
/root/.nvm/versions/node/${VERSION_NODE_DEFAULT}/bin:\
$(python3 -m site --user-base)/bin:\
$(python3.8 -m site --user-base)/bin:\
$PATH" >> ~/.bashrc && \
     echo "nvm use ${VERSION_NODE_DEFAULT} 1> /dev/null" >> ~/.bashrc

ENTRYPOINT [ "bash", "-c" ]

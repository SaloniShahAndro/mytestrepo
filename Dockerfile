FROM debian:stretch-slim

LABEL authors https://www.oda-alexandre.com

ENV USER vscode
ENV HOME /home/${USER}
ENV USER_UID=1000
ENV USER_GID=$USER_UID


RUN echo -e '\033[36;1m ******* CONFIG SOURCES DEBIAN ******** \033[0m' && \
  echo 'deb http://deb.debian.org/debian stretch main contrib non-free' > /etc/apt/sources.list && \
  echo 'deb-src http://deb.debian.org/debian stretch main contrib non-free' >> /etc/apt/sources.list

RUN echo -e '\033[36;1m ******* INSTALL PREREQUISITES ******** \033[0m' && \
  apt-get update && apt-get install -y --no-install-recommends \
  sudo \
  ca-certificates \
  apt-transport-https \
  software-properties-common \
  gnupg \
  gnupg2 \
  curl \
  build-essential \
  dpkg-dev \
  jetring \
  dh-make \
  dirmngr
  
RUN echo -e '\033[36;1m ******* ADD USER ******** \033[0m' && \
  useradd -d ${HOME} -m ${USER} && \
  passwd -d ${USER} && \
  adduser ${USER} sudo &&\
  echo $USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER

RUN echo -e '\033[36;1m ******* SELECT USER ******** \033[0m'
USER ${USER}

RUN echo -e '\033[36;1m ******* SELECT WORKING SPACE ******** \033[0m'
WORKDIR ${HOME}

RUN echo -e '\033[36;1m ******* ADD SOURCES KEY MICROSOFT ******** \033[0m' && \
  curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

RUN echo -e '\033[36;1m ******* INSTALL VSCODE ******** \033[0m' && \
  echo 'deb https://packages.microsoft.com/repos/vscode stable main' | sudo tee -a /etc/apt/sources.list.d/vscode.list && \
  sudo apt-get update && sudo apt-get install -y \
  code \
  git \
  python3 \
  python3-setuptools \
  libasound2 \
  libatk1.0-0 \
  libcairo2 \
  libcups2 \
  libexpat1 \
  libfontconfig1 \
  libfreetype6 \
  libgtk2.0-0 \
  libpango-1.0-0 \
  libx11-xcb1 \
  libxcomposite1 \
  libxcursor1 \
  libxdamage1 \
  libxext6 \
  libxfixes3 \
  libxi6 \
  libxrandr2 \
  libxrender1 \
  libxss1 \
  libxtst6 \
  openssh-client \
  php && \
  sudo easy_install3 pip

RUN echo -e '\033[36;1m ******* INSTALL POWERSHELL ******** \033[0m' && \
  echo 'deb https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main' | sudo tee -a /etc/apt/sources.list.d/powershell.list && \
  sudo apt-get update && sudo apt-get install -y \
  powershell



RUN echo -e '\033[36;1m ******* ADD SOURCES DOCKER ******** \033[0m' && \
  echo 'deb https://download.docker.com/linux/debian buster stable' | sudo tee -a /etc/apt/sources.list.d/docker.list && \
  curl https://download.docker.com/linux/debian/gpg | sudo apt-key add - 

RUN echo -e '\033[36;1m ******* INSTALL DOCKER ******** \033[0m' && \
  sudo apt-get update && sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-compose

RUN echo -e '\033[36;1m ******* CREATION GROUPE DOCKER ******** \033[0m' && \
  sudo groupadd -f docker

RUN echo -e '\033[36;1m ******* ADD USER TO GROUP DOCKER ******** \033[0m' && \
  sudo usermod -a -G docker $USER

RUN echo -e '\033[36;1m ******* CONTAINER START COMMAND ******** \033[0m'


RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh && \
sudo bash nodesource_setup.sh && \
sudo apt-get update && \
sudo apt-get install nodejs && \
nodejs -v && \
npm -v  
RUN sudo apt-get update && sudo apt-get install git
ENTRYPOINT /usr/share/code/code \
FROM node:lts-alpine
ENV USER vscode
ENV HOME /home/${USER}
WORKDIR ${HOME}
COPY package*.json ./
RUN  npm install
COPY . .
RUN sudo chown -R 1000:1000 /home/vscode
CMD ["npm", "run", "dev"]
VOLUME [ "/myvolume" ]
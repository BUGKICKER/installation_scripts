#!/bin/bash
# reference: https://www.metabase.com/docs/latest/developers-guide/build
# environment
# OS version 
# kernel: Linux kylin 4.19.91-24.8.el8.ks8.11.x86_64  
# name: Kylin Linux Advanced Server release V10 (Sun)
# image url: https://distro-images.kylinos.cn:8802/web_pungi/download/share/HCrXv9VIWec4hwopd62Oukz7UsZBtL03/Kylin-Server-10-8.2-Release-Build09-20211104-X86_64.iso 
# if the image url is invalid, go to this url for clue: https://blog.csdn.net/itas109/article/details/109453945 (compatible version)

node_tar=node-v18.14.0-linux-x64
java_tar=jdk-11.0.18+10

# install nodejs and yarn
# if the url is invalided,go to the nodejs official site
wget https://nodejs.org/dist/v18.14.0/node-v18.14.0-linux-x64.tar.xz
tar -xvf ${node_tar}.tar.xz

cat >> ~/.bash_profile <<EOF
export PATH=$PATH:$(pwd)/${node_tar}/bin
export CYPRESS_INSTALL_BINARY=0
EOF

export PATH=$PATH:$(pwd)/${node_tar}/bin
# don't download cypress
export CYPRESS_INSTALL_BINARY=0

npm install -g yarn

# install jdk
# https://adoptopenjdk.net/archive.html go to this site to download jdk
java -version
if [ $? -ne 0 ];then 
  tar -zxvf ${java_tar}.tar.gz

  cat >> ~/.bash_profile <<EOF
export PATH=$PATH:$(pwd)/${java_tar}/bin
export JAVA_HOME=$(pwd)/${java_tar}
EOF

  export PATH=$PATH:$(pwd)/${java_tar}/bin
  export JAVA_HOME=$(pwd)/${java_tar}
  java -version
else
  echo "java installed"
fi

# install clojure
# if the url is invalided, go to this site: https://clojure.org/guides/install_clojure
curl -O https://download.clojure.org/install/linux-install-1.11.1.1224.sh
chmod +x linux-install-1.11.1.1224.sh
sudo ./linux-install-1.11.1.1224.sh

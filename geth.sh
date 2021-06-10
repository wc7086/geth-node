#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "#=================================================
#       System Required: Centos/Debian/Ubuntu
#       Description: Docker geth-node
#       Version: 1.0.0
#       Author: wc7086
#       Github: https://github.com/wc7086/geth-node
#================================================="

readonly GREEN='\e[92m'
readonly NONE='\e[0m'

read -erp "请输入自定义数据目录（默认$HOME/Goerli）:" geth_date
[[ -z $geth_data ]] && readonly geth_date=$HOME/Goerli
read -erp "请输入自定义rpc http端口（默认8545）:" geth_http_port
[[ -z $geth_http_port ]] && readonly geth_http_port=8545
read -erp "请输入自定义rpc ws端口（默认8546）:" geth_ws_port
[[ -z $geth_ws_port ]] && readonly geth_ws_port=8546

# Install docker
if [[ ! -x $(command -v docker) ]]; then
  echo -e "${GREEN}Install docker${NONE}" >&2
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
fi

# Start watchtower
if [[ ! "$(docker ps -q -f name=watchtower)" ]]; then
  echo -e "${GREEN}Start watchtower${NONE}"
  # cleanup
  [[ "$(docker ps -aq -f status=exited -f name=watchtower)" ]] && docker rm watchtower
  # run your container
  docker run -d --name watchtower --restart unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower -c
fi

echo -e "${GREEN}Start ethereum-node${NONE}"
docker run -d --name geth-node --restart unless-stopped -v $geth_date:/root/.ethereum -p $geth_http_port:8545 -p $geth_ws_port:8546 -p 30303:30303 -p 30303:30303/udp ethereum/client-go --http --http.addr=0.0.0.0 --http.port=$geth_http_port --ws --ws.addr=0.0.0.0 --ws.port=$geth_ws_port --goerli --syncmode "light"

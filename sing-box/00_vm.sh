#!/bin/bash

re="\033[0m"
red="\033[1;91m"
green="\e[1;32m"
yellow="\e[1;33m"
purple="\e[1;35m"
red() { echo -e "\e[1;91m$1\033[0m"; }
green() { echo -e "\e[1;32m$1\033[0m"; }
yellow() { echo -e "\e[1;33m$1\033[0m"; }
purple() { echo -e "\e[1;35m$1\033[0m"; }
reading() { read -p "$(red "$1")" "$2"; }
export LC_ALL=C
USERNAME=$(whoami)
USERNAME=$(whoami | tr '[:upper:]' '[:lower:]')
MD5_HASH=$(echo -n "$USERNAME" | md5sum | awk '{print $1}')
export UUID=${UUID:-${MD5_HASH:0:8}-${MD5_HASH:8:4}-4${MD5_HASH:12:3}-$(echo $((RANDOM % 4 + 8)) | head -c 1)${MD5_HASH:15:3}-${MD5_HASH:19:12}}
export NEZHA_SERVER=${NEZHA_SERVER:-''}     # 哪吒面板地址
export NEZHA_PORT=${NEZHA_PORT:-'5555'}     # 哪吒面板通信端口
export NEZHA_KEY=${NEZHA_KEY:-''}           # 哪吒密钥，端口为{443,8443,2096,2087,2083,2053}其中之一时自动开启tls
export ARGO_DOMAIN=${ARGO_DOMAIN:-''}       # ARGO 固定隧道域名，留空将使用临时隧道
export ARGO_AUTH=${ARGO_AUTH:-''}           # ARGO 固定隧道json或token，留空将使用临时隧道
export CFIP=${CFIP:-'www.visa.com.tw'}      # 优选ip或优选域名
export CFPORT=${CFPORT:-'443'}              # 优选ip或优选域名对应端口  
export SUB_TOKEN=${SUB_TOKEN:-${UUID:0:8}}
export CHAT_ID=${CHAT_ID:-''} 
export BOT_TOKEN=${BOT_TOKEN:-''} 

[[ "$HOSTNAME" == "s1.ct8.pl" ]] && WORKDIR="${HOME}/domains/${USERNAME}.ct8.pl/logs" && FILE_PATH="${HOME}/domains/${USERNAME}.ct8.pl/public_html" || WORKDIR="${HOME}/domains/${USERNAME}.serv00.net/logs" && FILE_PATH="${HOME}/domains/${USERNAME}.serv00.net/public_html"
rm -rf "$WORKDIR" && mkdir -p "$WORKDIR" "$FILE_PATH" && chmod 777 "$WORKDIR" "$FILE_PATH" >/dev/null 2>&1
bash -c 'ps aux | grep $(whoami) | grep -v "sshd\|bash\|grep" | awk "{print \$2}" | xargs -r kill -9 >/dev/null 2>&1' >/dev/null 2>&1

check_binexec_and_port () {
  purple "正在安装中,请稍等..."
  port_list=$(devil port list)
  tcp_ports=$(echo "$port_list" | grep -c "tcp")
  udp_ports=$(echo "$port_list" | grep -c "udp")

  if [[ $tcp_ports -lt 1 ]]; then
      red "没有可用的TCP端口,正在调整..."

      if [[ $udp_ports -ge 3 ]]; then
          udp_port_to_delete=$(echo "$port_list" | awk '/udp/ {print $1}' | head -n 1)
          devil port del udp $udp_port_to_delete
          green "已删除udp端口: $udp_port_to_delete"
      fi

      while true; do
          tcp_port=$(shuf -i 10000-65535 -n 1)
          result=$(devil port add tcp $tcp_port 2>&1)
          if [[ $result == *"succesfully"* ]]; then
              green "已添加TCP端口: $tcp_port"
              tcp_port1=$tcp_port
              break
          else
              yellow "端口 $tcp_port 不可用，尝试其他端口..."
          fi
      done

      green "端口已调整完成, 将断开SSH连接, 请重新连接SSH并重新执行脚本"
      devil binexec on >/dev/null 2>&1
      kill -9 $(ps -o ppid= -p $$) >/dev/null 2>&1
  else
      tcp_ports=$(echo "$port_list" | awk '/tcp/ {print $1}')
      tcp_port1=$(echo "$tcp_ports" | sed -n '1p')

      purple "当前TCP端口: $tcp_port1"
  fi

  export PORT=$tcp_port1
}
check_binexec_and_port

argo_configure() {
  if [[ -z $ARGO_AUTH || -z $ARGO_DOMAIN ]]; then
    green "ARGO_DOMAIN or ARGO_AUTH is empty,use quick tunnel"
    return
  fi

  if [[ $ARGO_AUTH =~ TunnelSecret ]]; then
    echo $ARGO_AUTH > tunnel.json
    cat > tunnel.yml << EOF
tunnel: $(cut -d\" -f12 <<< "$ARGO_AUTH")
credentials-file: tunnel.json
protocol: http2

ingress:
  - hostname: $ARGO_DOMAIN
    service: http://localhost:$PORT
    originRequest:
      noTLSVerify: true
  - service: http_status:404
EOF
  else
    green "ARGO_AUTH mismatch TunnelSecret,use token connect to tunnel"
  fi
}
argo_configure
wait

ARCH=$(uname -m) && DOWNLOAD_DIR="." && mkdir -p "$DOWNLOAD_DIR" && FILE_INFO=()
if [ "$ARCH" == "arm" ] || [ "$ARCH" == "arm64" ] || [ "$ARCH" == "aarch64" ]; then
    FILE_INFO=("https://github.com/eooce/test/releases/download/arm64/sb web" "https://github.com/eooce/test/releases/download/arm64/bot13 bot" "https://github.com/eooce/test/releases/download/ARM/swith npm")
elif [ "$ARCH" == "amd64" ] || [ "$ARCH" == "x86_64" ] || [ "$ARCH" == "x86" ]; then
    FILE_INFO=("https://github.com/eooce/test/releases/download/freebsd/xary web" "https://github.com/eooce/test/releases/download/freebsd/server bot" "https://github.com/eooce/test/releases/download/freebsd/swith npm")
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi
declare -A FILE_MAP
generate_random_name() {
    local chars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890
    local name=""
    for i in {1..6}; do
        name="$name${chars:RANDOM%${#chars}:1}"
    done
    echo "$name"
}

for entry in "${FILE_INFO[@]}"; do
    URL=$(echo "$entry" | cut -d ' ' -f 1)
    RANDOM_NAME=$(generate_random_name)
    NEW_FILENAME="$DOWNLOAD_DIR/$RANDOM_NAME"
    
    if [ -e "$NEW_FILENAME" ]; then
        green "$NEW_FILENAME already exists, Skipping download"
    else
        curl -L -sS -o "$NEW_FILENAME" "$URL"
        green "Downloading $NEW_FILENAME"
    fi
    chmod +x "$NEW_FILENAME"
    FILE_MAP[$(echo "$entry" | cut -d ' ' -f 2)]="$NEW_FILENAME"
done
wait

generate_config() {
  
  cat > config.json << EOF
{
    "log":{
        "access":"/dev/null",
        "error":"/dev/null",
        "loglevel":"none"
    },
    "inbounds":[
        {
          "tag":"vmess-ws",
          "port": ${PORT},
          "listen": "0.0.0.0",
          "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "${UUID}"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                    "path": "/vmess-argo"
                }
            }
        }
    ],
    "dns":{
        "servers":[
            "https+local://8.8.8.8/dns-query"
        ]
    },
    "outbounds": [
        {
          "protocol": "freedom",
          "tag": "direct"
          },
        {
          "protocol": "blackhole",
          "tag": "blocked"
        }
    ] 
}
EOF
}
generate_config
wait

if [ -e "$(basename ${FILE_MAP[web]})" ]; then
    nohup ./"$(basename ${FILE_MAP[web]})" -c config.json >/dev/null 2>&1 &
    sleep 2
    pgrep -x "$(basename ${FILE_MAP[web]})" > /dev/null && green "$(basename ${FILE_MAP[web]}) is running" || { red "$(basename ${FILE_MAP[web]}) is not running, restarting..."; pkill -x "$(basename ${FILE_MAP[web]})" && nohup ./"$(basename ${FILE_MAP[web]})" -c config.json >/dev/null 2>&1 & sleep 2; purple "$(basename ${FILE_MAP[web]}) restarted"; }
fi

if [ -e "$(basename ${FILE_MAP[bot]})" ]; then
    if [[ $ARGO_AUTH =~ ^[A-Z0-9a-z=]{120,250}$ ]]; then
      args="tunnel --edge-ip-version auto --no-autoupdate --protocol http2 run --token ${ARGO_AUTH}"
    elif [[ $ARGO_AUTH =~ TunnelSecret ]]; then
      args="tunnel --edge-ip-version auto --config tunnel.yml run"
    else
      args="tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile "${WORKDIR}/boot.log" --loglevel info --url http://localhost:$PORT"
    fi
    nohup ./"$(basename ${FILE_MAP[bot]})" $args >/dev/null 2>&1 &
    sleep 2
    pgrep -x "$(basename ${FILE_MAP[bot]})" > /dev/null && green "$(basename ${FILE_MAP[bot]}) is running" || { red "$(basename ${FILE_MAP[bot]}) is not running, restarting..."; pkill -x "$(basename ${FILE_MAP[bot]})" && nohup ./"$(basename ${FILE_MAP[bot]})" "${args}" >/dev/null 2>&1 & sleep 2; purple "$(basename ${FILE_MAP[bot]}) restarted"; }
fi

if [ -e "$(basename ${FILE_MAP[npm]})" ]; then
    tlsPorts=("443" "8443" "2096" "2087" "2083" "2053")
    if [[ "${tlsPorts[*]}" =~ "${NEZHA_PORT}" ]]; then
      NEZHA_TLS="--tls"
    else
      NEZHA_TLS=""
    fi
    if [ -n "$NEZHA_SERVER" ] && [ -n "$NEZHA_PORT" ] && [ -n "$NEZHA_KEY" ]; then
        export TMPDIR=$(pwd)
        nohup ./"$(basename ${FILE_MAP[npm]})" -s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} ${NEZHA_TLS} >/dev/null 2>&1 &
        sleep 2
        pgrep -x "$(basename ${FILE_MAP[npm]})" > /dev/null && green "$(basename ${FILE_MAP[npm]}) is running" || { red "$(basename ${FILE_MAP[npm]}) is not running, restarting..."; pkill -x "$(basename ${FILE_MAP[npm]})" && nohup ./"$(basename ${FILE_MAP[npm]})" -s "${NEZHA_SERVER}:${NEZHA_PORT}" -p "${NEZHA_KEY}" ${NEZHA_TLS} >/dev/null 2>&1 & sleep 2; purple "$(basename ${FILE_MAP[npm]}) restarted"; }
    else
        purple "NEZHA variable is empty, skipping running"
    fi
fi

sleep 1
rm -f "$(basename ${FILE_MAP[npm]})" "$(basename ${FILE_MAP[web]})" "$(basename ${FILE_MAP[bot]})"

get_argodomain() {
  if [[ -n $ARGO_AUTH ]]; then
    echo "$ARGO_DOMAIN"
  else
    local retry=0
    local max_retries=6
    local argodomain=""
    while [[ $retry -lt $max_retries ]]; do
      ((retry++))
      argodomain=$(grep -oE 'https://[[:alnum:]+\.-]+\.trycloudflare\.com' "${WORKDIR}/boot.log" | sed 's@https://@@') 
      if [[ -n $argodomain ]]; then
        break
      fi
      sleep 1
    done
    echo "$argodomain"
  fi
}

install_keepalive () {
    purple "正在安装保活服务中,请稍等......"
    keep_path="$HOME/domains/keep.${USERNAME}.serv00.net/public_nodejs"
    [ -d "$keep_path" ] || mkdir -p "$keep_path"
    app_file_url="https://xray.2go.us.kg/app.js"

    if command -v curl &> /dev/null; then
        curl -s -o "${keep_path}/app.js" "$app_file_url"
    elif command -v wget &> /dev/null; then
        wget -q -O "${keep_path}/app.js" "$app_file_url"
    else
        echo "警告: 文件下载失败,请手动从https://xray.2go.us.kg/app.js下载文件,并将文件上传到${keep_path}目录下"
        return
    fi

    cat > ${keep_path}/.env <<EOF
UUID=${UUID}
CFIP=${CFIP}
CFPORT=${CFPORT}
SUB_TOKEN=${SUB_TOKEN}
TELEGRAM_CHAT_ID=${CHAT_ID}
TELEGRAM_BOT_TOKEN=${BOT_TOKEN}
NEZHA_SERVER=${NEZHA_SERVER}
NEZHA_PORT=${NEZHA_PORT}
NEZHA_KEY=${NEZHA_KEY}
ARGO_DOMAIN=${ARGO_DOMAIN}
ARGO_AUTH=$([[ -z "$ARGO_AUTH" ]] && echo "" || ([[ "$ARGO_AUTH" =~ ^\{.* ]] && echo "'$ARGO_AUTH'" || echo "$ARGO_AUTH"))
EOF
    devil www add ${USERNAME}.serv00.net php > /dev/null 2>&1
    devil www add keep.${USERNAME}.serv00.net nodejs /usr/local/bin/node18 > /dev/null 2>&1
    ip_address=$(devil vhost list | sed -n '5p' | awk '{print $1}')
    devil ssl www add $ip_address le le keep.${USERNAME}.serv00.net > /dev/null 2>&1
    ln -fs /usr/local/bin/node18 ~/bin/node > /dev/null 2>&1
    ln -fs /usr/local/bin/npm18 ~/bin/npm > /dev/null 2>&1
    mkdir -p ~/.npm-global
    npm config set prefix '~/.npm-global'
    echo 'export PATH=~/.npm-global/bin:~/bin:$PATH' >> $HOME/.bash_profile && source $HOME/.bash_profile
    rm -rf $HOME/.npmrc > /dev/null 2>&1
    cd ${keep_path} && npm install dotenv axios --silent > /dev/null 2>&1
    rm $HOME/domains/keep.${USERNAME}.serv00.net/public_nodejs/public/index.html > /dev/null 2>&1
    devil www options keep.${USERNAME}.serv00.net sslonly on > /dev/null 2>&1
    if devil www restart keep.${USERNAME}.serv00.net 2>&1 | grep -q "succesfully"; then
        green "\n全自动保活服务安装成功\n"
        green "========================================================\n"
        purple "访问 https://keep.${USERNAME}.serv00.net/stop 结束进程\n"
        purple "访问 https://keep.${USERNAME}.serv00.net/list 全部进程列表\n"
        yellow "访问 https://keep.${USERNAME}.serv00.net/start 调起保活程序\n"
        purple "访问 https://keep.${USERNAME}.serv00.net/status 查看进程状态\n"
        green "========================================================"
        curl -sk "https://keep.${USERNAME}.serv00.net/start" | grep -q "running" && green "\n所有服务都运行正常,全自动保活任务添加成功\n" || red "\n存在未运行的进程,请访问 https://keep.${USERNAME}.serv00.net/status 检查,建议执行以下命令后重装: \ndevil www del $USERNAME.serv00.net\ndevil www del keep.$USERNAME.serv00.net\nrm -rf $HOME/$USERNAME/domains/*\nshopt -s extglob dotglob\nrm -rf $HOME/!(domains|mail|repo)\n"
        purple "如果需要Telegram通知,请先在Telegram @Botfather 申请 Bot-Token,并带CHAT_ID和BOT_TOKEN环境变量运行\n\n"
    else
        red "全自动保活服务安装失败: \n${yellow}devil www del $USERNAME.serv00.net\ndevil www del keep.$USERNAME.serv00.net\nrm -rf $HOME/$USERNAME/domains/*\nshopt -s extglob dotglob\nrm -rf $HOME/!(domains|mail|repo)\n${red}请依次执行上述命令后重新安装!"
    fi
}

generate_links() {
  argodomain=$(get_argodomain)
  echo -e "\e[1;32mArgoDomain: \e[1;35m${argodomain}\e[0m\n"
  sleep 1
  isp=$(curl -s --max-time 2 https://speed.cloudflare.com/meta | awk -F\" '{print $26}' | sed -e 's/ /_/g' || echo "00")
  get_name() { if [ "$HOSTNAME" = "s1.ct8.pl" ]; then SERVER="CT8"; else SERVER=$(echo "$HOSTNAME" | cut -d '.' -f 1); fi; echo "$SERVER"; }
  NAME=${isp}-$(get_name)-vmess-argo-${USERNAME}
  FILE_PATH="/usr/home/${USERNAME}/domains/${USERNAME}.serv00.net/public_html"
  cat > ${FILE_PATH}/${SUB_TOKEN}_vmess.log <<EOF
vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${NAME}\", \"add\": \"${CFIP}\", \"port\": \"${CFPORT}\", \"id\": \"${UUID}\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"${argodomain}\", \"path\": \"vmess-argo?ed=2048\", \"tls\": \"tls\", \"sni\": \"${argodomain}\", \"alpn\": \"\" }" | base64 -w0)
EOF
  cat ${FILE_PATH}/${SUB_TOKEN}_vmess.log
  green "\n订阅连接: https://${USERNAME}.serv00.net/${SUB_TOKEN}_vmess.log 适用于V2ranN/Nekobox/Karing/小火箭/sterisand/Loon 等\n" 
  rm -rf config.json fake_useragent_0.2.0.json ${WORKDIR}/boot.log ${WORKDIR}/tunnel.json ${WORKDIR}/tunnel.yml 
  install_keepalive
}
generate_links

yellow "Serv00|ct8老王一键vmess-ws-tls(argo)无交互安装脚本\n"
echo -e "${green}issues反馈：${re}${yellow}https://github.com/eooce/Sing-box/scrips${re}\n"
echo -e "${green}反馈论坛：${re}${yellow}https://bbs.vps8.me${re}\n"
echo -e "${green}TG反馈群组：${re}${yellow}https://t.me/vps888${re}\n"
purple "转载请保留出处，违者必纠！请勿滥用！！!\n"
purple "Running done!\n"
purple "Thank you for using this script,enjoy!\n"

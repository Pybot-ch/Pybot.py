#!/usr/bin/env bash

RED="\033[1;31m"
GREEN="\033[1;32m"
CYAN="\033[1;36m"
NC="\033[0m"
THIS_DIR=`pwd`
print_logo() {
  echo -e "${GREEN}   ____                                  _   _          _\n"\
  " / ___|  _ __    ___    _   _   _ __   | | | |   ___  | |  _ __     ___   _ __\n${NC}"\
  "| |  _  | '__|  / _ \  | | | | | '_ \  | |_| |  / _ \ | | | '_ \   / _ \ | '__|\n"\
  "| |_| | | |    | (_) | | |_| | | |_) | |  _  | |  __/ | | | |_) | |  __/ | |\n${RED}"\
  " \____| |_|     \___/   \__,_| | .__/  |_| |_|  \___| |_| | .__/   \___| |_|\n"\
  "                               |_|                        |_|\n${NC}"
}

sudo cp /usr/share/zoneinfo/Asia/Tehran /etc/localtime

install() {
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
    sudo apt install g++-4.7 -y c++-4.7 -y
    sudo apt update
    sudo apt upgrade
    sudo apt install libreadline-dev libconfig-dev libconfig++-dev libssl-dev lua5.2 liblua5.2-dev lua-socket lua-sec lua-expat libevent-dev redis-server autoconf g++ libjansson-dev libpython-dev expat libexpat1-dev libstdc++6 lua-lgi libconfig++9v5
    wget -O luarocks.tar.gz "http://luarocks.org/releases/luarocks-2.2.2.tar.gz"
    tar zxpf luarocks.tar.gz; rm luarocks.tar.gz
    cd luarocks-2.2.2
    ./configure; sudo make bootstrap
    sudo luarocks install serpent
    sudo luarocks install redis-lua
    cd ..; rm -rf luarocks-2.2.2
    if [ ! -f td ]; then
      wget -O td "https://valtman.name/files/telegram-bot-180330-nightly-linux"
      chmod +x td
    fi
    clear
    echo -e "${GREEN}Done.${NC}"
}
logincli() {
    echo -e "${GREEN}Enter Phone Number:${NC}"
    read phone
    ./td -p cli --login --phone=${phone}
}
loginapi() {
  echo -e "${GREEN}Enter Bot Token:${NC}"
  read token
  ./td -p api --login --bot=${token}
}
cli(){
  ./td -p cli -s $THIS_DIR/bot/bot.lua
}
api(){
  ./td -p api -s $THIS_DIR/bot/bot.lua
}
autocli(){
  while true; do
    screen ./td -p cli -s $THIS_DIR/bot/bot.lua
  done
}
autoapi(){
  while true; do
    screen ./td -p api -s $THIS_DIR/bot/bot.lua
  done
}
clear; print_logo
if [[ $1 == "install" ]]; then
    install
elif [[ $1 == "login-cli" ]]; then
    logincli
elif [[ $1 == "login-api" ]]; then
    loginapi
elif [[ $1 == "cli" ]]; then
    if [[ -d "${HOME}/.telegram-bot/cli" && ! -L "${HOME}/.telegram-bot/cli" ]]; then
        cli
    else
        echo -e "${RED}First Use Login Command [login-cli]${NC}"
    fi
elif [[ $1 == "auto-cli" ]]; then
    if [[ -d "${HOME}/.telegram-bot/cli" && ! -L "${HOME}/.telegram-bot/cli" ]]; then
        autocli
    else
        echo -e "${RED}First Use Login Command [login-cli]${NC}"
    fi
elif [[ $1 == "api" ]]; then
    if [[ -d "${HOME}/.telegram-bot/api" && ! -L "${HOME}/.telegram-bot/api" ]]; then
        api
    else
        echo -e "${RED}First Use Login Command [login-api]${NC}"
    fi
elif [[ $1 == "auto-api" ]]; then
    if [[ -d "${HOME}/.telegram-bot/api" && ! -L "${HOME}/.telegram-bot/api" ]]; then
        autoapi
    else
        echo -e "${RED}First Use Login Command [login-api]${NC}"
      fi
else
    echo -e "${RED}Use: ${GREEN}./bot.sh {install|login-cli|login-api|cli|api|auto-cli|auto-api}${NC}"
fi

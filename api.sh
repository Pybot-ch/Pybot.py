RED="\033[1;31m"
GREEN="\033[1;32m"
CYAN="\033[1;36m"
NC="\033[0m"
print_logo() {
  echo -e "${GREEN}   ____                                  _   _          _\n"\
  " / ___|  _ __    ___    _   _   _ __   | | | |   ___  | |  _ __     ___   _ __\n${NC}"\
  "| |  _  | '__|  / _ \  | | | | | '_ \  | |_| |  / _ \ | | | '_ \   / _ \ | '__|\n"\
  "| |_| | | |    | (_) | | |_| | | |_) | |  _  | |  __/ | | | |_) | |  __/ | |\n${RED}"\
  " \____| |_|     \___/   \__,_| | .__/  |_| |_|  \___| |_| | .__/   \___| |_|\n"\
  "                               |_|                        |_|\n${NC}"
}

install() {
    sudo apt update
    sudo apt upgrade
    sudo apt install software-properties-common python-software-properties
    sudo apt update
    sudo apt install python3.6
    sudo apt install python3-pip
    sudo pip3 install redis
    sudo pip3 install pyTelegramBotApi
}

run(){
    python3.6 api/bot.py
}

auto(){
    while true; do
        screen python3.6 api/bot.py
    done
}
clear
print_logo

if [[ $1 == "install" ]]; then
    install
elif [[ $1 == "run" ]]; then
    run
elif [[ $1 == "auto-run" ]]; then
    auto
else
    echo -e "${RED}Use: ${GREEN}./api.sh {install|run|auto-run}${NC}"
fi

#!/bin/bash

[[ $(id -u) != 0 ]] && echo -e "哎呀......请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1
clear

apttt(){
	apt-get update -y
	apt-get upgrade -y
	apt-get install sudo -y
	apt-get install imagemagick -y
	apt-get install software-properties-common -y
	add-apt-repository ppa:dawidd0811/neofetch -y
	apt-get install neofetch -y
	apt install tesseract-ocr-all -y
	apt-get install libzbar-dev -y
	apt install git -y

	apt install tesseract-ocr -y
}

logint(){
	
	if [ "$1" != "cnum" ]; then
	
	read -p "请输入您的 Telegram 手机号码: " phonenum

	screen -x -S userbot -p 0 -X stuff "$phonenum"
	screen -x -S userbot -p 0 -X stuff $'\n'
	
	fi
	
	read -p "请输入您的登录验证码: " checknum

	screen -x -S userbot -p 0 -X stuff "$checknum"
	screen -x -S userbot -p 0 -X stuff $'\n'
	
	if [ ! -f "/var/lib/PagerMaid-Modify/pagermaid.session-journal" ]; then
		read -p "您是否有二次登录验证码(y或n & 不知道二次登录验证码是什么请回车): " choi

		if [ "$choi" == "y" ]; then
			read -p "请输入您的二次登录验证码: " twotimepwd
			screen -x -S userbot -p 0 -X stuff "$twotimepwd"
			screen -x -S userbot -p 0 -X stuff $'\n'
		elif [ "$choi" == "n" ] || [ "$choi" == "" ]; then
			echo "验证码输入错误！"
			sleep 3
			logint cnum
		fi
	fi
}

install_by_source(){
	apttt
	if command -v python3.6;then
		echo 'Python 3.6 存在...'
	else
		wget https://www.python.org/ftp/python/3.6.5/Python-3.6.5.tgz
		tar xvzf Python-3.6.5.tgz
		gzip -dv Python-3.6.5.tgz
		tar xvf Python-3.6.5.tar
		cd Python-3.6.5
		./configure --enable-optimizations
		make && make altinstall
		python3 -V
		cd ../
		rm -rf Python-3.6.5.tgz
		
	fi
	if command -v pip3;
	then
	echo 'pip3 存在...'
	else
		apt-get install python3-pip -y
	fi
	pip3 install email_validator
	pip3 install zbar
	pip3 install --upgrade pip
	sudo -H pip3 install --ignore-installed PyYAML
	sudo -H pip3 install sentry-sdk==0.16.0
	apt-get install screen -y

	if command -v git;then
		echo 'Git 存在...'
	else
		apt-get install git -y
	fi

	cd /var/lib
	git clone https://github.com/xtaodada/PagerMaid-Modify.git
	cd PagerMaid-Modify

	pip3 install -r requirements.txt
	mv config.gen.yml config.yml

	clear

	read -p "请输入您的 API_KEY: " api_key
	sed -i "s/ID_HERE/$api_key/g" /var/lib/PagerMaid-Modify/config.yml
	read -p "请输入您的 API_HASH: " api_hash
	sed -i "s/HASH_HERE/$api_hash/g" /var/lib/PagerMaid-Modify/config.yml
	screen -dmS userbot

	screen -x -S userbot -p 0 -X stuff "cd /var/lib/PagerMaid-Modify && python3.6 -m pagermaid"

	screen -x -S userbot -p 0 -X stuff $'\n'

	clear

	logint

	apt remove screen -y
	cd /etc/systemd/system/
	wget https://pastebin.com/raw/jcWjFDT6
	mv ./jcWjFDT6 ./pagermaid.service
	systemctl daemon-reload
	systemctl start pagermaid
	systemctl enable pagermaid

	echo "PagerMaid 已经安装完毕 在 Telegram 对话框中输入 -help 并发送查看帮助列表"
}

install_by_docker(){
	apttt
	if [ -w /var/run/docker.sock ]
	  then
		echo "Docker 存在...."
	  else
		curl -sSL get.docker.com | sh
	  fi
	
	docker rm -f "pagermaid" > /dev/null 2>&1
    docker pull mrwangzhe/pagermaid_modify
	echo "正在启动 Docker 容器 . . ."
	echo "在登录后，请按 Ctrl + C 使容器在后台模式下重新启动。"
	docker run -it --restart=always --name="pagermaid" --hostname="pagermaid" mrwangzhe/pagermaid_modify <&1

}

echo "------PagerMaid Auto Install------"
echo "1. 通过源代码安装 PagerMaid"
echo "2. 通过 Docker 安装 PagerMaid (配置低的机器不推荐)"
echo "3. 结束"
echo "----------------------------------"
echo 
read startr
case $startr in
  1)
  install_by_source
  ;;
  2)
  install_by_docker
  ;;
  3)
  exit
  ;;
  *)
  exit
  ;;
esac

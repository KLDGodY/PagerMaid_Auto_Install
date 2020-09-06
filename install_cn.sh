#!/bin/bash

clear

# 验证码失败次数
ftime = 0

# 系统判断
if [[ -f /etc/redhat-release ]]; then
  echo "淦 暂时不支持 CentOS 系统（" && exit 1
elif cat /etc/issue | grep -q -E -i "debian"; then
  echo "淦 暂时不支持 CentOS 系统（" && exit 1
elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
  echo "淦 暂时不支持 CentOS 系统（" && exit 1
elif cat /proc/version | grep -q -E -i "debian"; then
  echo "淦 暂时不支持 Debian 系统（" && exit 1
elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
  echo "淦 暂时不支持 CentOS 系统（" && exit 1
elif cat /etc/issue | grep -q -E -i "Ubuntu 16"; then
  echo "淦 暂时不支持 Ubuntu 16（" && exit 1
elif cat /etc/issue | grep -q -E -i "Ubuntu 14"; then
  echo "淦 暂时不支持 Ubuntu 14（" && exit 1
elif cat /etc/issue | grep -q -E -i "Ubuntu 12"; then
  echo "淦 暂时不支持 Ubuntu 12（" && exit 1
fi

# Root
[[ $(id -u) != 0 ]] && echo -e "哎呀......请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1

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
	apt-get install redis-server -y
}

logint(){

	#失败次数
	if [ "$ftime" == "0111" ]; then
		echo "失败次数过多！" && exit
	fi

	#普通进入登录（通过源代码安装时）
	if [ "$1" != "cnum" ] && [ "$1" != "fix" ]; then
	
	read -p "请输入您的 Telegram 手机号码: " phonenum

	if [ "$phonenum" == "" ]; then
		echo "¿连手机号都不知道¿" && logint
	fi

	screen -x -S userbot -p 0 -X stuff "$phonenum"
	screen -x -S userbot -p 0 -X stuff $'\n'

	# 没带区号
	if [ "$(ps aux|grep [p]agermaid)" == "" ]; then
		echo "手机号输入错误！请确认您是否带了区号（中国号码为 +86 如 +8613301237756）" 
		logint phonenumwrong
	fi
	
	elif [ "$1" == "fix" ]; then
	
	apt-get install screen -y 
	screen -dmS userbot

	screen -x -S userbot -p 0 -X stuff "cd /var/lib/PagerMaid-Modify && python3.6 -m pagermaid"

	screen -x -S userbot -p 0 -X stuff $'\n'
	
	read -p "请输入您的 Telegram 手机号码: " phonenum

	if [ "$phonenum" == "" ]; then
		echo "¿连手机号都不知道¿" && logint
	fi

	screen -x -S userbot -p 0 -X stuff "$phonenum"
	screen -x -S userbot -p 0 -X stuff $'\n'

	#没带区号
	if [ "$(ps aux|grep [p]agermaid)" == "" ];then
		echo "手机号输入错误！请确认您是否带了区号（中国号码为 +86 如 +8613301237756）" 
		logint phonenumwrong
	fi

	elif [ "$1" == "phonenumwrong" ]; then
		screen -x -S userbot -p 0 -X stuff "cd /var/lib/PagerMaid-Modify && python3.6 -m pagermaid"

		screen -x -S userbot -p 0 -X stuff $'\n'

		read -p "请输入您的 Telegram 手机号码: " phonenum

		if [ "$phonenum" == "" ]; then
			echo "¿连手机号都不知道¿" && logint
		fi

		screen -x -S userbot -p 0 -X stuff "$phonenum"
		screen -x -S userbot -p 0 -X stuff $'\n'
	
		# 没带区号
		if [ "$(ps aux|grep [p]agermaid)" == "" ];then
			echo "手机号输入错误！请确认您是否带了区号（中国号码为 +86 如 +8613301237756）" 
			logint phonenumwrong
		fi
	fi
	
	read -p "请输入您的登录验证码: " checknum

	screen -x -S userbot -p 0 -X stuff "$checknum"
	screen -x -S userbot -p 0 -X stuff $'\n'
	
	# 如果没有二次验证码，pagermaid.session-journal 不存在，是因为登录验证码错误 如果有那就输入
	if [ ! -f "/var/lib/PagerMaid-Modify/pagermaid.session-journal" ]; then
		read -p "您是否有二次登录验证码(y或n & 不知道二次登录验证码是什么请回车): " choi

		if [ "$choi" == "y" ]; then
			read -p "请输入您的二次登录验证码: " twotimepwd
			screen -x -S userbot -p 0 -X stuff "$twotimepwd"
			screen -x -S userbot -p 0 -X stuff $'\n'
		elif [ "$choi" == "n" ] || [ "$choi" == "" ]; then
			echo "登录验证码错误！"
			sleep 3
			ftime+=1
			logint cnum
		fi
	fi
}

install_by_source(){
	# 目录检测 防止 clone 错误
	if [ -d "/var/lib/PagerMaid-Modify" ]; then
		echo "目录存在,是否删除目录?(/var/lib/PagerMaid-Modify) (y或n):"
		read coidel
		if [ "$coidel" == "y" ]; then
			rm -rf /var/lib/PagerMaid-Modify
		else
			exit 1
		fi
	fi

	apttt
	
	# 检测 Python 3.6 (其实没什么用 Ubuntu 18.04 自带)
	if command -v python3.6; then
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
		rm -rf Python-3.6.5.tar
		
	fi

	if command -v pip3; then
		echo 'pip3 存在...'
	else
		apt-get install python3-pip -y
	fi

	pip3 install --upgrade pip
	sudo -H pip3 install --ignore-installed PyYAML
	apt-get remove screen -y
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

	random_STring=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
	sed -i "s/RANDOM_STRING_HERE/$random_STring/g" /var/lib/PagerMaid-Modify/config.yml

	sed -i "s/proxy_addr: \"\"/proxy_addr: \"socks5.nbss.icu\"/g" /var/lib/PagerMaid-Modify/config.yml
	sed -i "s/proxy_port: \"\"/proxy_port: \"1081\"/g" /var/lib/PagerMaid-Modify/config.yml

	screen -dmS userbot

	screen -x -S userbot -p 0 -X stuff "cd /var/lib/PagerMaid-Modify && python3.6 -m pagermaid"

	screen -x -S userbot -p 0 -X stuff $'\n'

	clear

	logint

	# 删除 screen & 守护进程
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

	# 检测 docker 因为 root 不可能不能访问（吧）
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

fix_by_source(){

	# 检测目录
	if [ ! -d "/var/lib/PagerMaid-Modify" ] || [ ! -f "/var/lib/PagerMaid-Modify/config.yml" ]; then
		echo "¿都没安装修复什么?" && exit 1
	fi

	# 守护进程
	if [ ! -f "/etc/systemd/system/pagermaid.service" ]; then
		systemctl stop pagermaid
		rm -rf /etc/systemd/system/pagermaid.service
		systemctl daemon-reload
		cd /etc/systemd/system/
		wget https://pastebin.com/raw/jcWjFDT6
		mv ./jcWjFDT6 ./pagermaid.service
		systemctl daemon-reload
		systemctl start pagermaid
		systemctl enable pagermaid
	else
		cd /etc/systemd/system/
		wget https://pastebin.com/raw/jcWjFDT6
		mv ./jcWjFDT6 ./pagermaid.service
		systemctl daemon-reload
		systemctl start pagermaid
		systemctl enable pagermaid
	fi
	
	read -p "问题是否解决？(y或n):" se1
	
	# 账号失效
	if [ "$se1" == "y" ]; then
		exit
	elif [ "$se1" == "n" ];then
		rm -rf /var/lib/PagerMaid-Modify/pagermaid.session
		rm -rf /var/lib/PagerMaid-Modify/pagermaid.session-journal
		systemctl stop pagermaid
		logint fix
		apt-get remove screen -y
		systemctl start pagermaid
	else
		echo "¿"
		exit
	fi
	
	read -p "问题是否解决？(y或n):" se2

	#依赖
	if [ "$se2" == "y" ]; then
		exit
	elif [ "$se2" == "n" ];then
		apttt
		pip3 install email_validator
		pip3 install zbar
		pip3 install --upgrade pip
		sudo -H pip3 install --ignore-installed PyYAML
	else
		echo "¿"
		exit
	fi
	
	read -p "问题是否解决？(y或n):" se3

	#重装
	if [ "$se3" == "y" ]; then
		exit
	elif [ "$se3" == "n" ];then
		echo "正在尝试重新安装 PagerMaid"
		echo "如果您要取消重装，请在 3秒 内按下 Ctrl + C"
		sleep 3
		mv -r /var/lib/PagerMaid-Modify/plugins /root
		systemctl stop pagermaid
		rm -rf /etc/systemd/system/pagermaid.service
		systemctl daemon-reload
		rm -rf /var/lib/PagerMaid-Modify
		install_by_source
		mv -r /root/plugins /var/lib/PagerMaid-Modify
		rm -rf /root/plugins
		systemctl restart pagermaid
	else
		echo "¿"
		exit
	fi
	
	read -p "问题是否解决？(y或n):" se4
	if [ "$se4" == "y" ]; then
		exit
	elif [ "$se4" == "n" ];then
		echo "换台机器吧... 我实在想不出怎么修复了..."
	else
		echo "¿"
		exit
	fi
}

fix_by_docker(){
	if command -v docker; then
		echo "Docker 存在..."
	else
		echo "Docker 都没了...重新安装吧..." && exit 1
	fi

	if [[ "$(docker images -q pagermaid:latest 2> /dev/null)" == "" ]]; then
		echo "镜像没了？重装吧"
	fi

	if [ ! -w /var/run/docker.sock ]; then
			systemctl enable docker
			systemctl start docker
	fi

	read -p "问题是否解决？(y或n):" se1
	if [ "$se1" == "y" ]; then
		exit
	elif [ "$se1" == "n" ];then
		apttt
	else
		echo "¿"
		exit
	fi
	read -p "问题是否解决？(y或n):" se2
	if [ "$se2" == "y" ]; then
		exit
	elif [ "$se2" == "n" ];then
		echo "正在尝试重新安装 PagerMaid"
		docker rm -f "pagermaid" > /dev/null 2>&1
   		docker pull mrwangzhe/pagermaid_modify
		echo "正在启动 Docker 容器 . . ."
		echo "在登录后，请按 Ctrl + C 使容器在后台模式下重新启动。"
		docker run -it --restart=always --name="pagermaid" --hostname="pagermaid" mrwangzhe/pagermaid_modify <&1
	else
		echo "¿"
		exit
	fi
	read -p "问题是否解决？(y或n):" se3
	if [ "$se3" == "y" ]; then
		exit
	elif [ "$se3" == "n" ];then
		echo "换台机器吧... 我实在想不出怎么修复了..."
	else
		echo "¿"
		exit
	fi
}

echo "------PagerMaid Auto Install------"
echo "1. 通过源代码安装 PagerMaid"
echo "2. 通过 Docker 安装 PagerMaid (配置低的机器不推荐)"
echo "3. 修复 PagerMaid (通过源代码安装)"
echo "4. 修复 PagerMaid (通过 Docker 安装)"
echo "5. 结束"
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
		fix_by_source
	;;
	4)
		fix_by_docker
	;;
	5)
	exit
	;;
	*)
	exit
	;;
esac

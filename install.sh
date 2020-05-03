cd /var/lib

update_and_install(){
	apt-get update -y
	apt-get upgrade -y
	apt-get install sudo -y
	apt-get install imagemagick -y
	apt-get install software-properties-common -y
	add-apt-repository ppa:dawidd0811/neofetch
	apt-get install neofetch -y
	apt-get install libzbar-dev -y
	
	apt install tesseract-ocr -y
	if command -v python3.6;then
		echo 'Python 3.6 存在...'
		update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 100000000000
		update-alternatives --config python3
	else
		wget https://www.python.org/ftp/python/3.6.5/Python-3.6.5.tgz
		tar xvzf Python-3.6.5.tgz
		gzip -dv Python-3.6.5.tgz
		tar xvf Python-3.6.5.tar
		cd Python-3.6.5
		./configure --enable-optimizations
		make && make altinstall
		update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 100000000000
		update-alternatives --config python3
		python3 -V
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
	apt-get install screen -y
	
	if command -v git;then
		echo 'Git 存在...'
	else
		apt-get install git -y
	fi
}

update_and_install

cd /var/lib
git clone https://github.com/xtaodada/PagerMaid-Modify.git
cd PagerMaid-Modify

pip3 install -r requirements.txt
mv config.gen.yml config.yml

read -p "请输入您的API_KEY: " api_key
sed -i "s/ID_HERE/$api_key/g" /var/lib/PagerMaid-Modify/config.yml
read -p "请输入您的API_HASH: " api_hash
sed -i "s/HASH_HERE/$api_hash/g" /var/lib/PagerMaid-Modify/config.yml
screen -dmS userbot

echo "请在接下来的窗口登录您的 Telegram 账号，登录完成后 按 Ctrl + A + D 退出Screen后台运行 10 秒后安装程序继续..."
sleep 10

cd /var/lib

screen -x -S userbot -p 0 -X stuff "cd /var/lib/PagerMaid-Modify && python3 -m pagermaid"

screen -x -S userbot -p 0 -X stuff $'\n'

cd /etc/systemd/system/
wget https://pastebin.com/raw/jcWjFDT6
mv ./jcWjFDT6 ./pagermaid.service
sudo systemctl daemon-reload
sudo systemctl start pagermaid

screen -r userbot

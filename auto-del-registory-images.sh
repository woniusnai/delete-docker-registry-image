#!/usr/bin/env bash
#repo_address=
#repo_passwd=
#repo_name=
#repo_path=
read -p "请输入仓库地址：" repo_address
read -p "请输入仓库用户名：" repo_name
read -p "请输入仓库密码：" repo_passwd
read -p "请输入仓库的物理地址，例：/root/volumes/registry/data/docker/registry/v2/ ：" repo_path
echo ""
echo -e "============================================================================="
echo -e	"=                重要提醒：本脚本将查找出仓库中所有的镜像并“全部”删除                 ="
echo -e "============================================================================="
echo ""
if [ -d "${repo_path}" ];then
	export REGISTRY_DATA_DIR=${repo_path}
	else
	echo 仓库路径未找到，请确认路径正确后在此运行脚本.
	exit
fi
	while [ -z "`cat /opt/del_registry_images.py`" ]; do
		wget https://raw.githubusercontent.com/burnettk/delete-docker-registry-image/master/delete_docker_registry_image.py -O /opt/del_registry_images.py && sleep 1
	done
	chmod 711 /opt/del_registry_images.py
while true; do
read -p "请确认是否继续[Yn]:" choose
	case "${choose}" in
		[Yy]* )
		authentication=`curl -s -u${repo_name}:${repo_passwd} ${repo_address}/v2/_catalog | grep "authentication required"`
		if [ -z "${authentication}" ]; then
		num1=2
		num2=2
		for i in $(seq ${num1} 2 1000); do
		    num2=$((${num2}+2));
		    app_name=`curl -s -u${repo_name}:${repo_passwd} ${repo_address}/v2/_catalog | cut -d '"' -f ${num2}`
		    if [ -n "${app_name}" ]; then
		    	echo -e "==========================3秒钟后开始删除${app_name}库==============================="
			echo -e "=========================在此期间您可以按Ctrl-C终止操作=============================="
			sleep 3
			cd /opt/ && ./del_registry_images.py --image ${app_name}
		    else
    			echo -e "============================已全部清理，啥都没有了;=================================="
			exit;
    		    fi
		done
	else
	echo 用户验证失败！
	exit;
	fi
	break;;
	[Nn]* )
	echo "未执行删除，已退出"
	exit;;
	* )
	echo "Please enter y or n ";;
	esac
done

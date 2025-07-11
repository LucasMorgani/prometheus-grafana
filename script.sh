#!/usr/bin/env bash
#
# --------------------------------HEADER---------------------------------- #
# Script inicial para preparo de servidor de monitoramento.
#
# Autor:      Lucas Morgani
# Site:       -
# GitHub:     https://github.com/LucasMorgani
# Manutenção:
# Contato:    11 985168748         
# ------------------------------------------------------------------------ #
# TESTADO EM:
#   bash 5.2.21
# ------------------------------------------------------------------------ #


# ------------------------------ VARIÁVEIS ------------------------------- #

#--------------------------------TEST
TESTE_REALIZADO=0
IP_EXECUTADO=0
SSH_EXECUTADO=0
ANSIBLE_EXECUTADO=0
SSH_ANSIBLE_EXECUTADO=0
IP_APLICADO=0
KEY_SSH=0
#--------------------------------NETWORK
NETWORK_INTERFACE=$(ip -o -4 addr show | awk '$2 ~ /^enp/ {print $2; exit}')
IP_FIXO="192.168.0.10/24"
GATEWAY="192.168.0.1"
DNS1="192.168.0.1"
DNS2="1.1.1.1"
#--------------------------------SSH
PATH_NETWORK="//192.168.0.240/energec/Scripts/"
PATH_LOCAL="/home/$USER/mount"
mkdir $PATH_LOCAL
# ------------------------------------------------------------------------ #


# ------------------------------- FUNÇÕES -------------------------------- #

#--------------------------------AtualizarMaquina
Att () {
	sudo apt update -y >/dev/null 2>&1
	sudo apt upgrade -y >/dev/null 2>&1
}

#--------------------------------SetarIP
SetarIP () {
	sudo mkdir -p /etc/netplan/01-netcfg.yaml
	sudo chmod 600 /etc/netplan/01-netcfg.yaml
	cat <<EOF | sudo tee /etc/netplan/01-netcfg.yaml > /dev/null
network:
  version: 2
  renderer: networkd
  ethernets:
    $NETWORK_INTERFACE:
      dhcp4: no
      addresses:
        - $IP_FIXO
      routes:
        - to: 0.0.0.0/0
          via: $GATEWAY
      nameservers:
        addresses: [$DNS1, $DNS2]
EOF
}
#--------------------------------AplicarIP
AplicarIP () {
	sudo netplan apply
}
#--------------------------------InstalarSSH
InstalarSSH () {
	sudo apt install openssh-server
	sudo systemctl start sshd
	sudo systemctl enable sshd
}
#--------------------------------InstalarAnsible
InstalarAnsible () {
	sudo apt install ansible -y
}
#--------------------------------ConfigurarAnsibleSSH
ConfigurarAnsibleSSH () {
	sudo apt install cifs-utils -y
 	sudo apt install git -y
	sudo mount -t cifs $PATH_NETWORK $PATH_LOCAL -o username=$USERNAME,password=$PASSWORD,iocharset=utf8,file_mode=0777,dir_mode=0777
	cat /home/$USER/mount/id_rsa.pub >> /home/$USER/.ssh/authorized_keys
}
#--------------------------------ExecScript
ExecScript () {
	SetarIP
	[[ $? != 0 ]] && IP_EXECUTADO=1
	AplicarIP
	[[ $? != 0 ]] && IP_APLICADO=1
       	InstalarAnsible
	[[ $? != 0 ]] && ANSIBLE_EXECUTADO=1
	ConfigurarAnsibleSSH
	[[ $? != 0 ]] && SSH_ANSIBLE_EXECUTADO=1
}

#--------------------------------CloseScript
CloseScript () {
	echo "Script encerrado."
	exit 0
}

#--------------------------------ReadManual
ReadManual () {
	echo -e " \
\n Para começar, digite /"test/" para verificar se todos os componentes estao corretamente configurados \
\n Após o teste realizado, digite /"start/" para iniciar a execução do script de preparo de máquina \
\n Para atualizar a máquina, digite /"att/"
\n Para sair, digite /"exit/"
 "
}

#--------------------------------ExecTest
ExecTest () {
	if command -v ansible >/dev/null 2>&1; then
		ANSIBLE_EXECUTADO=1
	fi
	if command -v ssh >/dev/null 2>&1; then
		SSH_EXECUTADO=1
	fi
	if ip a | grep 192.168.0.10 >/dev/null 2>&1; then
		IP_APLICADO=1
	fi
	if cat /home/$USER/mount/id_rsa.pub >/dev/null 2>&1; then
		KEY_SSH=1
	fi

	if [ $ANSIBLE_EXECUTADO -eq 1 ]; then
		echo "Ansible está instalado corretamente"
	else
		echo "Ansible não foi instalado corretamente"
	fi

	if [ $SSH_EXECUTADO -eq 1 ]; then
		echo "SSH está instalado corretamente"
	else
		echo "SSH não foi instalado corretamente"
	fi
	
	if [ $IP_APLICADO -eq 1 ]; then
		echo "O IP fixo está aplicado corretamente"
	else
		echo "O IP fixo não está aplicado corretamente"
	fi

	if [ $KEY_SSH -eq 1 ]; then
		echo "A chave pública SSH foi localizada corretamente"
	else
		echo "A chave pública SSH não foi localizada -- \\DC01\energec\Scripts\id_rsa.pub"
	fi
 	
}

ExecTest2 () {
	declare -a names=("Ansible" "SSH" "IP" "SSH_Key")
 	declare -a commads=(
  		"command -v ansible"
    	"command -v ssh"
      	"ip a | grep -q 192.168.0.10"
		"cat /home/$USER/mount/id_rsa.pub"
	)
 	declare -a success_msgs=(
  		"Ansible esta instalado corretamente"
    	"SSH esta instalado corretamente"
      	"O IP fixo esta aplicado corretamente"
		"A chave publica SSH foi localizada corretamente"
	)
	declare -a fail_msgs=(
		"Ansible nao esta instalado corretamente"
		"SSH nao está instalado corretamente"
		"O IP fixo nao esta aplicado corretamente"
		"A chave publica SSH nao foi localizada corretamente"
	)

	for i in "${!commands[@]}"; do
		if eval "${commands[$i]} > /dev/null 2>&1"; then
			echo "${success_msgs[$i]}"
		else
			echo "${fail_msgs[$i]}"
		fi
	done
}

# ------------------------------------------------------------------------ #


# ------------------------------- EXECUÇÃO ------------------------------- #
echo -e "\n  Script de preparo de máquina para monitoramento interno."

while true; do
	echo -e "Digite uma opção para iniciar ou encerrar.. \n  start\n  exit\n  help\n  test\n  status\n  att\n"
	read -p "> " INIT

	case $INIT in
		start)
			echo -e "\nDigite usuário e senha..\n"
			read -p "> USER:  " USERNAME
			read -s -p "> PASSWORD  " PASSWORD
			if [ $TESTE_REALIZADO -eq 0 ]; then
				echo -e "\n  Execute um teste antes de executar o script!"
			else
				ExecScript; SCRIPT_EXECUTADO=1
			fi
			;;
		exit)
			CloseScript
			;;
		help)
			ReadManual
			;;
		test)
			ExecTest2
			;;
   
		att)
			Att
			;;
		*)
			echo "Código inválido! Digite "help" para ler o manual."
	esac

done
# ------------------------------------------------------------------------ #

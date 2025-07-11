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
#-------------------------------------------------ExecScript
ExecScript () {
	SetarIP
       	InstalarAnsible
	ConfigurarAnsibleSSH
}
#-------------------------------------------------CommandMenu
#--------------------------------StartCommand
StartCommand () {
	echo -e "\nDigite usuário e senha..\n"
	read -p "> USER:  " USERNAME
	read -s -p "> PASSWORD  " PASSWORD
	if [ $TESTE_REALIZADO -eq 0 ]; then
		echo -e "\n  Execute um teste antes de executar o script!"
	else
		ExecScript; SCRIPT_EXECUTADO=1
	fi
}
#--------------------------------CloseScript
CloseScript () {
	echo "Script encerrado."
	exit 0
}
#--------------------------------ReadManual
ReadManual () {
	echo -e " \
\n test) 	Para verificar se todos os componentes estao corretamente configurados \
\n start)	Para executar o script de preparo de máquina \
\n att) 	Para atualizar a maquina \
\n exit) 	Para sair"
}
#--------------------------------ExecTest
ExecTest () {
	declare -a names=("Ansible" "SSH" "IP" "SSH_Key")
 	declare -a commands=(
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
#--------------------------------AtualizarMaquina
Att () {
	echo "Atualizando repositórios.."
	sudo apt update -y >/dev/null 2>&1 && sudo apt upgrade -y >/dev/null 2>&1
 	echo "Atualização concluida."
}
#-------------------------------------------------NetworkConfig
#--------------------------------SetarIP
SetarIP () {
	sudo mkdir -p /etc/netplan/01-netcfg.yaml && sudo chmod 600 /etc/netplan/01-netcfg.yaml
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
	sudo netplan apply
}
#-------------------------------------------------Install&Config
#--------------------------------InstalarSSH
InstalarSSH () {
	sudo apt install openssh-server && sudo systemctl start sshd && sudo systemctl enable sshd
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
# ------------------------------------------------------------------------ #



# ------------------------------- EXECUÇÃO ------------------------------- #
echo -e "\n\n---------------------------------------------------------"
echo -e "Script de preparo de máquina para monitoramento interno."
echo "---------------------------------------------------------"

while true; do
	echo -e "Digite uma opção para iniciar ou encerrar.. \n  start\n  exit\n  help\n  test\n  att\n"
	read -p "> " INIT

	case $INIT in
		start)
			StartCommand
   			echo "---------------------------------------------------------"
			;;
		exit)
			CloseScript
   			echo "---------------------------------------------------------"
			;;
		help)
			ReadManual
   			echo "---------------------------------------------------------"
			;;
		test)
			ExecTest
   			echo "---------------------------------------------------------"
			;;
		att)
			Att
   			echo "---------------------------------------------------------"
			;;
		*)
			echo "Código inválido! Digite "help" para ler o manual."
   			echo "---------------------------------------------------------"
	esac
done
# ------------------------------------------------------------------------ #

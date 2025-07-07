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
# Exemplos:
#      $ ./criar_arquivos.sh
#       $ Digite o nome padrão para criar os arquivos    <nome>
#       $ Digite a quatidade de arquivos para criar      <qtde>
#       $ Digite a extensão desejada para os arquivos    <extensão>
#
#      Preencha os requisitos para criar a quantidade solicitada de arquivos padronizados
# ------------------------------------------------------------------------ #
# TESTADO EM:
#   bash 5.2.21
# ------------------------------------------------------------------------ #


# ------------------------------ VARIÁVEIS ------------------------------- #

#--------------------------------TEST
export TESTE_REALIZADO=0
IP_EXECUTADO=0
SSH_EXECUTADO=0
ANSIBLE_EXECUTADO=0
SSH_ANSIBLE_EXECUTADO=0
IP_APLICADO=0
KEY_SSH=0
#--------------------------------NETWORK
NETWORK_INTERFACE=$(ip -o -4 addr show | awk '$2 ~ /^enp/ {print $2; exit}')
IP_FIXO="192.168.0.11/24"
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
	CAT <<EOF | sudo tee /etc/netplan/01-netcfg.yaml > /dev/null
network:
	version: 2
	renderer: networkd
	ethernets:
		$NETWORK_INTERFACE:
			dhcp4: no
			addresses:
				- $IP_FIXO
			gateway4: $GATEWAY
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
	sudo apt install ansible
}
#--------------------------------ConfigurarAnsibleSSH
ConfigurarAnsibleSSH () {
	sudo apt install cifs-utils
 	sudo apt install git
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
	export IP_EXECUTADO
	export ANSIBLE_EXECUTADO
	export SSH_ANSIBLE_EXECUTADO
}

#--------------------------------CloseScript
CloseScript () {
	echo "Script encerrado."
	exit 0
}

#--------------------------------ReadManual
ReadManual () {
	echo "executou o manual"
}

#--------------------------------ExecTest
ExecTest () {
	if command -v ansible >/dev/null 2>&1; then
		ANSIBLE_EXECUTADO=1
	fi
	if command -v ssh >/dev/null 2>&1; then
		SSH_EXECUTADO=1
	fi
	if ip a | grep 192.168.0.11 >/dev/null 2>&1; then
		IP_APLICADO=1
	fi
	if cat /home/$USER/mount/id_rsa.pub >/dev/null 2>&1; then
		KEY_SSH=1
	fi

	SOMA_TESTE=($ANSIBLE_EXECUTADO+$SSH_EXECUTADO+$IP_APLICADO+$KEY_SSH)
}

# ------------------------------------------------------------------------ #


# ------------------------------- EXECUÇÃO ------------------------------- #
echo "Script de preparo de máquina para monitoramento interno."

while true; do
	echo -e "Digite uma opção para iniciar ou encerrar.. \n  start\n  stop\n  help\n  test\n  status\n  att\n"
	read -p "> " INIT

	case $INIT in
		start)
			echo "Digite usuário e senha.."
			read -p "> USER:	" USERNAME
			read -p "> PASSWORD		" PASSWORD
			if [ $TESTE_REALIZADO -eq 0 ]; then
				echo "Execute o teste antes de executar o script"
			else
				ExecScript; export SCRIPT_EXECUTADO=1
			fi
			;;
		stop)
			CloseScript
			;;
		help)
			ReadManual
			;;
		test)
			ExecTest
			if [ $ANSIBLE_EXECUTADO -eq 1 ]; then
				echo "Ansible está instalado corretamente"
				export ANSIBLE_EXECUTADO
			else
				echo "Ansible não foi instalado corretamente"
			fi

			if [ $SSH_EXECUTADO -eq 1 ]; then
				echo "SSH está instalado corretamente"
				export SSH_EXECUTADO
			else
				echo "SSH não foi instalado corretamente"
			fi
			
			if [ $IP_APLICADO -eq 1 ]; then
				echo "O IP fixo está aplicado corretamente"
				export IP_APLICADO
			else
				echo "O IP fixo não está aplicado corretamente"
			fi

			if [ $KEY_SSH -eq 1 ]; then
				echo "A chave pública SSH foi localizada corretamente"
				export KEY_SSH
			else
				echo "A chave pública SSH não foi localizada"
			fi
	
			export TESTE_REALIZADO=1
			;;
		status)
			StatusScript
			;;
		att)
			Att
			;;
		*)
			echo "Código inválido! Digite '5' para ler o manual."
	esac

done
# ------------------------------------------------------------------------ #






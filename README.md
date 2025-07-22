# prometheus-grafana
Automação para Prometheus, Grafana e vscode (container) com Ansible

Modo de uso:
  Passo 1 - Shell Script
    O primeiro passo é preparar um servidor baseado em Ubuntu. salve bem o usuário e senha que foi configurado!
    Passe o shell script (script.sh) para o servidor na pasta home do usuário.
    Habilite a execução do script com o comando: "sudo chmod +x script_inicial.sh".
    E depois execute com o comando "./script.sh".
    Esse script realizará a instalação do Ansible e do SSH. Também copiará alguns arquivos do servidor local (onde está sendo realizado o backup).
  Passo 2 - Ansible
    O Playbook do Ansible instalará o Docker e executará o dockerfile automaticamente, já configurando tudo o que for necessário para os servidores executarem.

    Comandos do Ansible - ansible-playbook 

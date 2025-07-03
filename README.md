# prometheus-grafana
Automação para Prometheus, Grafana e vscode (container) com Ansible

Modo de uso:
  Passo 1 - Shell Script
    O primeiro passo é preparar um servidor baseado em Ubuntu, salve bem o usuário e senha que foi configurado!
    Passe o shell script (script_inicial.sh) para o servidor na pasta home do usuário (~/)
    Habilite a execução do script com o comando: "sudo chmod +x script_inicial.sh"
    E depois execute com o comando "./script_inicial.sh".
    Esse script realizará a instalação do Ansible e do SSH. Também executará o Playbook do Ansible, e conpiará alguns arquivos do servidor local (onde está sendo realizado o backup) no caminho "\\DC01\ENERGEC\BACKUP\".
  Passo 2 - Ansible
    O Playbook do Ansible instalará o Docker e executará o dockerfile automaticamente, já configurando tudo o que for necessário para os servidores executarem. A configuração dos servidores e os logs foram salvos no backup mensionado no passo anterior.

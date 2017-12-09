installation des roles ansible :
`ansible-galaxy install -r requirements.yml -p roles/`

get modules :

`terraform get`

plan modifications :

`terraform plan`

`terraform apply`

`terraform destroy`

`terraform taint -module=bastion scaleway_server.node`

`terraform taint -module=docker_workers scaleway_server.node`

test playbook :

`ansible-galaxy --check playbook.yml`


connexion ssh avec Jump host :

scw ps renvoie :
```
SERVER ID           IMAGE               ZONE                CREATED             STATUS              PORTS               NAME                    COMMERCIAL TYPE
45b3226b            ansible_image       par1                4 minutes           running             212.47.226.25       swarm-first_manager-1   C2S
97c95208            ansible_image       par1                5 minutes           running             51.15.138.150       bastion-1               C2S
```
`scw inspect 45b3226b|grep private`
renvoie
` "private_ip": "10.5.64.201" `

connexion au serveur via proxy :

`ssh -J user@51.15.138.150:988 -p 988 user@10.5.64.201`

contenu de `~/.ssh/config` :

```
Host bastion
    HostName b.dummy.net
    Port 988
    User user
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes
    ForwardAgent yes

Host manager
    Hostname m.dummy.net
    Port 988
    User user
    IdentityFile ~/.ssh/id_rsa
    ProxyCommand ssh -p 988 user@b.dummy.net -W %h:%p
```

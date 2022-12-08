


# Prerequisitos

- 4 máquinas virtuais com 2/4 processadores e 6/8 gb de memória ram
- 1 domínio
- Sistema operacional Ubuntu 18 LTS
- Domínio usado pelo instrutor do curso é: dev-ops-ninja.com



https://github.com/jonathanbaraldi/devops

# Aula 1 - Introdução
	- Apresentação
	- Agenda

# Aula 2 - Containers
	- Containers Docker
	
	
# Aula 3 - Kubernetes
	- Arquitetura do Rancher e Documentação do kubernetes na documentação oficial do Rancher.

# Aula 4 - Rancher


# Aula 5 - DevOps
	- Práticas DevOps



# Aula 6 - Ambiente
	
	Nesta aula, iremos verificar a instalação do Docker, e também iremos revisar a arquitetura do ambiente.

	É preciso entrar em todas as máquinas e instalar o Docker.

```sh

$ ssh -i devops-ninja.pem ubuntu@<ip>  - RancherSerber - HOST A
$ ssh -i devops-ninja.pem ubuntu@<ip>  - k8s-1         - HOST B
$ ssh -i devops-ninja.pem ubuntu@<ip>  - k8s-2         - HOST C
$ ssh -i devops-ninja.pem ubuntu@<ip>  - k8s-3         - HOST D

# Entrar das máquinas e instalar o docker. Fazer de acordo conforme iremos usando.

sudo su
curl https://releases.rancher.com/install-docker/20.10.sh | sh
net.bridge.bridge-nf-call-iptables=1
usermod -aG docker ubuntu
```






# Aula 7 - Construindo sua aplicação

### Fazer build das imagens, rodar docker-compose.

Nesse exercício iremos construir as imagens dos containers que iremos usar, colocar elas para rodar em conjunto com o docker-compose. 

Sempre que aparecer <dockerhub-user>, você precisa substituir pelo seu usuário no DockerHub.

Entrar no host A, e instalar os pacotes abaixo, que incluem Git, Python, Pip e o Docker-compose.



```sh

$ sudo su
$ apt-get install git -y
$ curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ chmod +x /usr/local/bin/docker-compose
$ ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```
Com os pacotes instalados, agora iremos baixar o código fonte e começaremos a fazer os build's e rodar os containers.
```sh
$ cd /home/ubuntu
$ git clone https://github.com/jonathanbaraldi/devopsforlife-devops
$ cd devopsforlife-devops/exercicios/app
```


#### Container=REDIS
Iremos fazer o build da imagem do Redis para a nossa aplicação.
```sh
$ cd redis
$ docker build -t <dockerhub-user>/redis:devops .
$ docker run -d --name redis -p 6379:6379 <dockerhub-user>/redis:devops
$ docker ps
$ docker logs redis
```
Com isso temos o container do Redis rodando na porta 6379.



#### Container=NODE
Iremos fazer o build do container do NodeJs, que contém a nossa aplicação.
```sh
$ cd ../node
$ docker build -t <dockerhub-user>/node:devops .
```
Agora iremos rodar a imagem do node, fazendo a ligação dela com o container do Redis.
```sh
$ docker run -d --name node -p 8080:8080 --link redis <dockerhub-user>/node:devops
$ docker ps 
$ docker logs node
```
Com isso temos nossa aplicação rodando, e conectada no Redis. A api para verificação pode ser acessada em /redis.



#### Container=NGINX
Iremos fazer o build do container do nginx, que será nosso balanceador de carga.
```sh
$ cd ../nginx
$ docker build -t <dockerhub-user>/nginx:devops .
```
Criando o container do nginx a partir da imagem e fazendo a ligação com o container do Node
```sh
$ docker run -d --name nginx -p 80:80 --link node <dockerhub-user>/nginx:devops
$ docker ps
```
Podemos acessar então nossa aplicação nas portas 80 e 8080 no ip da nossa instância.

Iremos acessar a api em /redis para nos certificar que está tudo ok, e depois iremos limpar todos os containers e volumes.
```sh
$ docker rm -f $(docker ps -a -q)
$ docker volume rm $(docker volume ls)
```


#### DOCKER-COMPOSE
Nesse exercício que fizemos agora, colocamos os containers para rodar, e interligando eles, foi possível observar  como funciona nossa aplicação que tem um contador de acessos.
Para rodar nosso docker-compose, precisamos remover todos os containers que estão rodando e ir na raiz do diretório para rodar.

É preciso editar o arquivo docker-compose.yml, onde estão os nomes das imagens e colocar o seu nome de usuário.

- Linha 8 = <dockerhub-user>/nginx:devops
- Linha 18 = image: <dockerhub-user>/redis:devops
- Linha 37 = image: <dockerhub-user>/node:devops

Após alterar e colocar o nome correto das imagens, rodar o comando de up -d para subir a stack toda.

```sh
$ cd ..
$ vi docker-compose.yml
$ docker-compose -f docker-compose.yml up -d
$ curl <ip>:80 
	----------------------------------
	This page has been viewed 29 times
	----------------------------------
```
Se acessarmos o IP:80, iremos acessar a nossa aplicação. Olhar os logs pelo docker logs, e fazer o carregamento do banco em /load

Para terminar nossa aplicação temos que rodar o comando do docker-compose abaixo:
```sh
$ docker-compose down
```











# Aula 8 - Rancher - Single Node

### Instalar Rancher - Single Node

Nesse exercício iremos instalar o Rancher 2.2.5 versão single node. Isso significa que o Rancher e todos seus componentes estão em um container. 

Entrar no host A, que será usado para hospedar o Rancher Server. Iremos verficar se não tem nenhum container rodando ou parado, e depois iremos instalar o Rancher.
```sh
$ docker ps -a
$ docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  --privileged \
  rancher/rancher:v2.6.9
```
Com o Rancher já rodando, irei adicionar a entrada de cada DNS para o IP de cada máquina.

```sh
$ rancher.<dominio> = IP do host A
```









# Aula 9 - Kubernetes

### Criar cluster Kubernetes

Nesse exercício iremos criar um cluster Kubernetes. Após criar o cluster, iremos instalar o kubectl no host A, e iremos usar para interagir com o cluster.

Seguir as instruções na aula para fazer o deployment do cluster.
Após fazer a configuração, o Rancher irá exibir um comando de docker run, para adicionar os host's.

Adicionar o host B e host C. 

Pegar o seu comando no seu rancher.
```sh
docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run rancher/rancher-agent:v2.4.3 --server https://rancher.dev-ops-ninja.com --token 8xf5r2ttrvvqcxdhwsbx9cvb7s9wgwdmgfbmzr4mt7smjbg4jgj292 --ca-checksum 61ac25d1c389b26c5c9acd98a1c167dbfb394c6c1c3019d855901704d8bae282 --node-name k8s-1 --etcd --controlplane --worker
```
Será um cluster com 3 nós.
Navegar pelo Rancher e ver os painéis e funcionalidades.












# Aula 10 - Kubectl

### Instalar kubectl no host A

Agora iremos instalar o kubectl, que é a CLI do kubernetes. Através do kubectl é que iremos interagir com o cluster.
```sh

sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

Com o kubectl instalado, pegar as credenciais de acesso no Rancher e configurar o kubectl.

```sh
$ vi ~/.kube/config
$ kubectl get nodes
```






# Aula 11 - DNS

### NGINX - Prometheus

Deployment de aplicação



# Aula 12 - Volume

### Volumes

Para fazermos os exercícios do volume, iremos fazer o deployment do pod com o volume, que estará apontando para um caminho no host.

Fazer o deployment do Longhorn.


```sh
$ kubectl apply -f mariadb-longhorn-volume.yml
```


# Aula 13 - Logs

# Falar sobre o módulo específico sobre Elastic Search






# Aula 13 - Monitoramento

### Grafana - MONITORAMENTO

O Grafana/Prometheus é a stack que iremos usar para monitoramento. O Deployment dela será feito pelo Catálogo de Apps.
Iremos configurar seguindo as informações do instrutor, e fazer o deployment.

Será preciso altear os DNS das aplicações para que elas fiquem acessíveis.

Após o deploymnet, entrar no Grafana e Prometheus e mostrar seu funcionamento.









# Aula 15 - CronJob

### CronJob

O tipo de serviço como CronJob é um serviço igual a uma cron, porém é executado no cluster kubernetes. Você agenda um pod que irá rodar em uma frequência determinada de tempo. Pode ser usado para diversas funções, como executar backup's dos bancos de dados.

Nesse exemplo, iremos executar um pod, com um comando para retornar uma mensagem de tempos em tempos, a mensagem é "Hello from the Kubernetes cluster"

```sh
$ kubectl apply -f cronjob.yml
	cronjob "hello" created
```
Depois de criada a cron, pegamos o estado dela usando:
```sh
$ kubectl get cronjob hello
NAME      SCHEDULE      SUSPEND   ACTIVE    LAST-SCHEDULE
hello     */1 * * * *   False     0         <none>
```
Ainda não existe um job ativo, e nenhum agendado também.
Vamos esperar por 1 minutos ate o job ser criado:
```sh
$ kubectl  get jobs --watch
```
Entrar no Rancher para ver os logs e a sequencia de execucao.









# Aula 16 - ConfigMap

### ConfigMap

O ConfigMap é um tipo de componente muito usado, principalmente quando precisamos colocar configurações dos nossos serviços externas aos contâiners que estão rodando a aplicação. 

Nesse exemplo, iremos criar um ConfigMap, e iremos acessar as informações dentro do container que está a aplicação.
```sh
$ kubectl apply -f configmap.yml
```
Agora iremos entrar dentro do container e verificar as configurações definidas no ConfigMap.













# Aula 17 - Secrets

### Secrets

Os secrets são usados para salvar dados sensitivos dentro do cluster, como por exemplo senhas de bancos de dados. Os dados que ficam dentro do secrets não são visíveis a outros usuários, e também podem ser criptografados por padrão no banco.

Iremos criar os segredos.

```sh
$ echo -n "<nome-aluno>" | base64
am9uYXRoYW5iYXJhbGRp
$ echo -n "<senha>" | base64
am9uam9u
```

Agora vamos escrever o secret com esses objetos. Após colocar os valores no arquivo secrets.yml, aplicar ele no cluster.
```sh
$ kubectl apply -f secrets.yml
```
Agora com os secrets aplicados, iremos entrar dentro do container e ver como podemos recuperar seus valores.














# Aula 18 - Liveness

### Liveness

Nesse exercício do liveness, iremos testar como fazer para dizer ao kubernetes, quando recuperar a nossa aplicação, caso alguma coisa aconteça a ela.
```js
http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) { 
	duration := time.Now().Sub(started) 
	if duration.Seconds() > 10 { 
		w.WriteHeader(500) 
		w.Write([]byte(fmt.Sprintf("error: %v", duration.Seconds()))) 
	} else { 
		w.WriteHeader(200) 
		w.Write([]byte("ok")) 
	} 
})
```
O código acima, está dentro do container que iremos rodar. Nesse código, vocês podem perceber que tem um IF, que irá fazer que de vez em quando a aplicação responda dando erro. 

Como a aplicação irá retornar um erro, o serviço de liveness que iremos usar no Kubernetes, ficará verificando se a nossa aplicação está bem, e como ela irá falhar de tempos em tempos, o kubernetes irá reiniciar o nosso serviço.

```sh
$ kubectl apply -f liveness.yml 
	Depois de 10 segundos, verificamos que o container reiniciou. 
$ kubectl describe pod liveness-http 
$ kubectl get pod liveness-http 
```











# Aula 19 - SetImage

### SetImage


Nesse exercício de rolling-update, iremos fazer o deployment do nginx na versão 1.7.9. Sendo 5 pods rodando a aplicação.

Iremos rodar o comando de rolling update, para atualizar para a versão 1.9.1. Dessa forma o Kubernetes irá rodar 1 container com a nova versão, e para um container com a antiga versão. Ele irá fazer isso para cada um dos containers, substituindo todos eles, e não havendo parada de serviço.

```sh
$ kubectl apply -f rolling-update.yml
```
Nesse arquivo o nginx está na versão 1.7.9
Para atualizar a imagem do container para 1.9.1 iremos usar o kubectl rolling-update e especificar a nova imagem.
```sh
$ kubectl set image deployments/my-nginx nginx=nginx:1.9.1
	
```
Em outra janela, você pode ver que o kubectl adicionou o label do deployment para os pods, que o valor é um hash da configuração, para distinguir os pods novos dos velhos
```sh
$ kubectl get pods -l app=nginx -L deployment
```













# Aula 20 - Autoscaling

### Autoscaling

Iremos executar o tutorial oficial para autoscaling.

https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#before-you-begin

Para isso iremos rodar e expor o php-apache server

Desabilitar o monitoramento com prometheus e Grafana para o Autoscaling poder funcionar.


```sh
$ kubectl apply -f php-apache.yml
```

Agora iremos fazer a criação do Pod Autoscaler

```sh
$ kubectl apply -f hpa.yml
```

Iremos pegar o HPA

```sh
$ kubectl get hpa
```

### Autoscaling - Aumentar a carga

Agora iremos aumentar a carga no pod contendo o apache em php.

```sh
$ kubectl run -i --tty load-generator --image=busybox /bin/sh
# Hit enter for command prompt
$ while true; do wget -q -O- http://php-apache.default.svc.cluster.local; done
```

Agora iremos em outro terminal, com o kubectl, verificar como está o HPA, e também no painel do Rancher. 

```sh 
$ kubectl get hpa
$ kubectl get deployment php-apache
```











# Aula 21 - Scheduling

### LABEL E SELETORES

Nesse exercício iremos colocar o label disktype, com valor igual a "ssd" no nó B do nosso cluster. 
Esse exercício serve para demonstrar como podemos usar o kubernetes para organizar onde irão rodar os containers. Neste exemplo estamos usando disco SSD em 1 máquina, poderia ser ambiente diferente, recursos de rede diferentes também, etc.

```sh
$ kubectl get nodes 
$ kubectl label nodes <your-node-name> disktype=ssd

$ kubectl apply -f node-selector.yml

# remover o Label do node
$ kubectl label nodes k8s-1 disktype-
```








# Aula 22 - Helm


### HELM


```sh 
$ curl -LO https://git.io/get_helm.sh
$ chmod 700 get_helm.sh
$ ./get_helm.sh
$ helm init
$ helm init --upgrade


$ kubectl create serviceaccount --namespace kube-system tiller
$ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
$ kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'


$ helm search

$ helm repo update

$ helm install stable/redis
```

As aplicações no catálogo do Rancher são feitas pelo Helm.










# Aula 23 - Políticas de Rede

### Declarar políticas de rede

https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/

https://github.com/ahmetb/kubernetes-network-policy-recipes/

https://ahmet.im/blog/kubernetes-network-policy/

Para ver como funciona as policies de rede do kubernetes, iremos criar um deployment do nginx e expor ele via serviço.

```sh
$ kubectl create deployment nginx --image=nginx

$ kubectl expose deployment nginx --port=80

$ kubectl get svc,pod

```

Iremos ter 2 pods no namespace default rodando o nginx e expondo atraves do serviço chamado nginx.


#### Testando o serviço

Iremos agora testar o acesso do nosso pod no nginx para os outros pods. Para acessar o serviço iremos rodar um prompt de dentro de um container busybox e iremos acessar o nginx

```sh
$ kubectl run busybox --rm -ti --image=busybox /bin/sh
	Waiting for pod default/busybox-472357175-y0m47 to be running, status is Pending, pod ready: false

	Hit enter for command prompt

$ wget --spider --timeout=1 nginx
	Connecting to nginx (10.100.0.16:80)
$ exit
```

Vendo o IP do POD do nginx respondendo, conseguimos ver que existe a conexão.

Agora iremos aplicar as regras no arquivo **nginx-policy.yml**.

```sh
$ kubectl create -f nginx-policy.yml
```

Após as regras aplicadas, iremos testar novamente a conexão do pod busybox com o nginx.

```sh
$ kubectl run busybox --rm -ti --image=busybox /bin/sh
	Waiting for pod default/busybox-472357175-y0m47 to be running, status is Pending, pod ready: false

	Hit enter for command prompt

$ wget --spider --timeout=1 nginx
	Connecting to nginx (10.100.0.16:80)
	wget: download timed out
$ exit
```

Podemos perceber que está dando timeout na conexão, o container do busybox não consegue conectar no nginx

Agora iremos criar novamente o container do busybox , mas iremos colocar o label de access=true para que o POD possa se conectar.

```sh
$ kubectl run busybox --rm -ti --labels="access=true" --image=busybox /bin/sh
	Waiting for pod default/busybox-472357175-y0m47 to be running, status is Pending, pod ready: false

	Hit enter for command prompt

$ wget --spider --timeout=1 nginx
	Connecting to nginx (10.100.0.16:80)
$ exit
```














# Aula 24 -  Configuração de CPU por namespace

## Configure Minimum and Maximum CPU Constraints for a Namespace

https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/cpu-constraint-namespace/

### Criar Namespace com configuração

```sh
$ kubectl create namespace constraints-cpu-example

$ kubectl apply -f cpu-constraints.yml

# Ver as informações detalhadas
$ kubectl get limitrange cpu-min-max-demo-lr --output=yaml --namespace=constraints-cpu-example
```

Agora, sempre que um container é criado no namespace constraints-cpu-example, o Kubernetes irá executar esses passos:

SE não for especificado CPU request e limit para o container, irá definir o padrão de CPU request e limit para o container.

Verificar que o container especificou CPU request que é maior ou igual a 200 milicpu.

Verificar que o container especificou um limit de CPU que é menor ou igual a 800 milicpu.


### Criar POD

```sh

$ kubectl apply -f cpu-constraints-pod.yml

$ kubectl get pod constraints-cpu-demo --namespace=constraints-cpu-example
# Ver as informações detalhadas
$ kubectl get limitrange cpu-min-max-demo-lr --output=yaml --namespace=constraints-cpu-example

$ kubectl get pod constraints-cpu-demo --output=yaml --namespace=constraints-cpu-example

resources:
  limits:
    cpu: 800m
  requests:
    cpu: 500m


```
### Deletar POD

```sh
$ kubectl delete pod constraints-cpu-demo --namespace=constraints-cpu-example
```

### Criar um POD que ultrapasse o limite de CPU

```sh

$ kubectl apply -f cpu-constraints-pod-2.yml

Error from server (Forbidden): error when creating "examples/admin/resource/cpu-constraints-pod-2.yaml":
pods "constraints-cpu-demo-2" is forbidden: maximum cpu usage per Container is 800m, but limit is 1500m.

```



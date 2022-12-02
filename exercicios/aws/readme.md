
Este repositório é usado na comunidade DevOps for Life.

# Kubernetes Logs - ElasticSearch em produção

1) Introdução, explicar o que iremos fazer.
2) Infraestrutura, qual a infraestrutura que iremos criar e trabalhar
3) DNS - Sobre o dominio que iremos usar no nosso deploy
4) Deploy do rancher
5) K8S-infra - Deployment do cluster
6) Deploy do longhorn - Cluster Infra
7) Deploy do nginx configuração do dns
8) Deploy do ElasticSearch
9) Deploy do Kibana
10) Infra-fluentd
11) K8S-dev
12) Dev-fluentd
13) K8S-QA
14) QA-fluentd
15) K8S-prod
16) PROD-fluentd
17) Revisão

# Parte 4 - Deployment do RancherServer

## 4.1 - Criação de usuário do IAM e permissões e configuração da AWS-CLI

https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

## 4.2 - Criação da instância do RancherServer pela aws-cli.

Estou usando Região de Ohio. US-EAST-2

UBUNTU 18 LTS
Docker 19.03
Rancher 2.6.9
Kubernetes 1.24
ElasticSearch 7.17
Kibana 8.5.0

```sh 
# RANCHER SERVER

# --image-id              ami-0a59f0e26c55590e9 - ubuntu 18 LTS
# --instance-type         t3.medium 
# --key-name              elasticsearch 
# --security-group-ids    sg-0b0e8363b215900f0 
# --subnet-id             subnet-4f5e7705

aws ec2 run-instances --image-id ami-0a59f0e26c55590e9 --count 1 --instance-type t3.medium --key-name elasticsearch --security-group-ids sg-0b0e8363b215900f0 --subnet-id subnet-67c83f0e --user-data file://rancher.sh --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=rancherserver}]' 'ResourceType=volume,Tags=[{Key=Name,Value=rancherserver}]' 

```

## 4.3 - Configuração do Rancher
Acessar o Rancher e configurar

https://3.134.108.244

# Parte 5 - Deployment Cluster Infra

## 5.1 - Deployment do cluster pela aws-cli

```sh
# --image-id ami-0a59f0e26c55590e9
# --count 3 
# --instance-type t3.large 
# --key-name elasticsearch 
# --security-group-ids sg-0b0e8363b215900f0 
# --subnet-id subnet-09c5a4961e6056757 
# --user-data file://k8s.sh

# ETCD-CONTROL-PLANE
aws ec2 run-instances --image-id ami-0a59f0e26c55590e9 --count 3 --instance-type t3.small --key-name elasticsearch --security-group-ids sg-0b0e8363b215900f0 --subnet-id subnet-67c83f0e --user-data file://k8s-infra-etcd.sh   --block-device-mapping "[ { \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": 30 } } ]" --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=k8s}]' 'ResourceType=volume,Tags=[{Key=Name,Value=k8s-infra}]'  


# WORKERS
aws ec2 run-instances --image-id ami-0a59f0e26c55590e9 --count 2 --instance-type t3.large --key-name elasticsearch --security-group-ids sg-0b0e8363b215900f0 --subnet-id subnet-67c83f0e --user-data file://k8s-infra-worker.sh   --block-device-mapping "[ { \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": 100 } } ]" --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=k8s}]' 'ResourceType=volume,Tags=[{Key=Name,Value=k8s-infra}]'    


```

Instalar o kubectl 

https://kubernetes.io/docs/tasks/tools/


# Parte 6 - Deploy Longhorn
Acompanhar no vídeo

# Parte 7 - DNS e nginx
Acompanhar no vídeo



# Parte 8 - Deploy ElastiSearch

Criar o secret que é o usuário e a senha que ele vai usar.

Instalar o Helm

```sh
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```


```sh
kubectl create namespace logging

echo -n "elastic" | base64
echo -n "1qazXSW@3edc" | base64

kubectl apply -f elastic-credentials.yaml

helm repo add elastic https://helm.elastic.co
helm repo update

helm install elk-elasticsearch elastic/elasticsearch -f elastic-no-cert.yaml --namespace logging 

helm upgrade elk-elasticsearch elastic/elasticsearch -f elastic-no-cert.yaml --namespace logging 

# helm upgrade elk-elasticsearch elastic/elasticsearch -f elastic.yaml --namespace logging 

# 8RgywcrHTvK0X47fF6Um
# elastic


helm delete elk-elasticsearch --namespace logging 
```


# Parte 9 - Deploy Kibana


```sh 
helm install elk-kibana elastic/kibana -f kibana-no-cert.yaml -n logging

helm upgrade elk-kibana elastic/kibana -f kibana-no-cert.yaml -n logging

helm delete elk-kibana -n logging
```

# Parte 10 - fluentd-infra

```sh
kubectl apply -f fluentd-infra.yaml
```



# Parte 11 - K8S-dev

```sh
aws ec2 run-instances --image-id ami-0a59f0e26c55590e9 --count 3 --instance-type t3.2xlarge --key-name elasticsearch --security-group-ids sg-0b0e8363b215900f0 --subnet-id subnet-67c83f0e --user-data file://k8s-dev.sh   --block-device-mapping "[ { \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": 100 } } ]" --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=k8s-dev}]' 'ResourceType=volume,Tags=[{Key=Name,Value=k8s-dev}]'  
```

# Parte 12 - fluentd-dev
```sh
kubectl apply -f fluentd-dev.yaml
```

# Parte 13 - K8S-QA

```sh
aws ec2 run-instances --image-id ami-0a59f0e26c55590e9 --count 3 --instance-type t3.2xlarge --key-name elasticsearch --security-group-ids sg-0b0e8363b215900f0 --subnet-id subnet-67c83f0e --user-data file://k8s-qa.sh   --block-device-mapping "[ { \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": 100 } } ]" --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=k8s-qa}]' 'ResourceType=volume,Tags=[{Key=Name,Value=k8s-qa}]'  
```

# Parte 14 - fluentd-qa
```sh
kubectl apply -f fluentd-qa.yaml
```

Deploy de aplicação log generator para enviar os logs e testar.
```sh
kubectl apply -f log-generator-dev.yaml
```

# Parte 15 - K8S-prod

```sh
aws ec2 run-instances --image-id ami-0a59f0e26c55590e9 --count 3 --instance-type t3.2xlarge --key-name elasticsearch --security-group-ids sg-0b0e8363b215900f0 --subnet-id subnet-67c83f0e --user-data file://k8s-prod.sh   --block-device-mapping "[ { \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": 100 } } ]" --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=k8s-prod}]' 'ResourceType=volume,Tags=[{Key=Name,Value=k8s-prod}]'  
```


# Parte 16 - fluentd-prod
```sh
kubectl apply -f fluentd-prod.yaml
```
Deploy de aplicação log generator para enviar os logs e testar.
```sh
kubectl apply -f log-generator-dev.yaml
```

# Parte 17 - Revisão



# Roadmap:
## Certificado no ambiente
## Machine learning para análise de Logs


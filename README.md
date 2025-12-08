#   Cloud Infrasture set up Bastion Host or Systerm manager
This document outlines the architecture and configuration of a secure, scalable AWS environment hosting [Application Name]. The infrastructure leverages public/private subnets, a bastion host for secure access, and encrypted S3 storage for data persistence.

2. Architecture Overview
Diagram
(Include a diagram here using AWS VPC Flow or Draw.io. Example structure below)

[Internet]  
│  
├── Internet Gateway (IGW)  
│   │  
│   └── Public Subnet (10.0.1.0/24)  
│       ├── Bastion Host (t3.medium)  
│       └── NAT Gateway  
│  
└── Private Subnet (10.0.2.0/24)  
    └── Application Server (c5.xlarge)  
        └── S3 Bucket (Mounted via IAM Role)  

Components
Component	Details
VPC	CIDR: 10.0.0.0/16
Public Subnet	CIDR: 10.0.1.0/24 (Hosts Bastion Host + NAT Gateway)
Private Subnet	CIDR: 10.0.2.0/24 (Hosts Application Server)
EC2 Instances	- Bastion: t3.medium (Public IP)
- Application: c5.xlarge (No Public IP)
NAT Gateway	Deployed in Public Subnet; EIP: [Elastic_IP_1]
Internet Gateway	Attached to VPC for public traffic.


3. Network Configuration
Route Tables
Route Table	Destination	Target
Public Route Table	0.0.0.0/0	Internet Gateway (IGW)
Private Route Table	0.0.0.0/0	NAT Gateway
Elastic IPs (EIPs)
Bastion Host: [Elastic_IP_1] (Public SSH access).

NAT Gateway: [Elastic_IP_2] (Outbound internet for private subnet).

bash
# Test SSH access to Bastion:  
ssh -i key.pem ec2-user@[Bastion_Elastic_IP]  

# Test SSH from Bastion to Private Instance:  
ssh -i key.pem ec2-user@[Private_Instance_Private_IP]  


# USE Terrafomr to create the cloud cnfiguration enivronment

Generate your access key from setting

![Alt text]<img width="1866" height="507" alt="Screenshot 2025-12-05 024102" src="https://github.com/user-attachments/assets/258cbd09-cb77-4ba4-986e-c3dd126fb47f" />

Download aws cli  

Download terraform  and add it to the enivronment variabale
 create a main.tf and write your variables 

run this 
terrafirm init

![Alt text]<img width="1839" height="919" alt="Screenshot 2025-12-05 045434" src="https://github.com/user-attachments/assets/87fdd70d-a1dc-4b18-95fd-559aafa470b0" />

terraform fmt 
terraform plan

![Alt text]<img width="1873" height="880" alt="Screenshot 2025-12-05 050449" src="https://github.com/user-attachments/assets/aede3b53-0daf-4acd-9ef2-5062010be74c" />

terraform apply 

![Alt text]<img width="1590" height="447" alt="Screenshot 2025-12-05 053035" src="https://github.com/user-attachments/assets/915feeb3-418d-45b7-9e55-374a576b6782" />

![Alt text]<img width="1590" height="447" alt="Screenshot 2025-12-05 053035" src="https://github.com/user-attachments/assets/e7b5509b-d8ef-4cb8-a222-5b5d0b11f26d" />

![Alt text]<img width="1908" height="540" alt="Screenshot 2025-12-05 053156" src="https://github.com/user-attachments/assets/8577d636-b68c-4632-8383-79502a9da775" />

![Alt text]<img width="957" height="272" alt="Screenshot 2025-12-05 053255" src="https://github.com/user-attachments/assets/d7fac09e-2861-4c94-a553-8640d5798885" />



1.  # Set Up environment
 
 **install all the tools with a bashscript called tools.sh** 

   ### use this command  to excute the script
   vim tools.sh
   chmod +x tools.sh
   sudo ./tools.sh

   ![Alt text]<img width="1631" height="860" alt="Screenshot 2025-12-05 075811" src="https://github.com/user-attachments/assets/c78dd21f-0c6c-45e9-bcd3-7c39b2d78b7d" />


### Confufgure Vault ready for production . 

 Make sure Vault is running and unsealed

Run:

vault status

#vault operator unseal

(Use your 3 unseal keys one by one.)

### Enable the AppRole Authentication Method

Run this:

vault auth enable approle

### Create an AppRole

Create a policy file:

policy.hcl

path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}


Apply it:

vault policy write app-policy policy.hcl


Now create the AppRole linked to this policy:

vault write auth/approle/role/my-approle \
    token_policies="app-policy" \
    token_ttl=1h \
    token_max_ttl=4h

 Get the ROLE_ID

This is your AppRole ID:

vault read auth/approle/role/my-approle/role-id

role_id   1234abcd-5678-ef00-9900-221133445566


Copy it.

STEP 5 — Generate the SECRET_ID

This is like your password for the AppRole.

vault write -f auth/approle/role/my-approle/secret-id

Output:
secret_id      aabbccdd-eeff-4455-9988-11223344
secret_id_ttl  0s


Copy the secret_id.
 Now you have what you need:
VAULT_ROLE_ID=<role_id from step 4>
VAULT_SECRET_ID=<secret_id from step 5>


You can export them:

export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_ROLE_ID= 765c03e9-b0e4-8737-e3f8-ff2ce468ddd2
export VAULT_SECRET_ID=c4a6cf62-4eb5-d917-a4ae-f7d97a7e2ab5
🎯 Test the AppRole Login

Run:

vault write auth/approle/login \
    role_id="$VAULT_ROLE_ID" \
    secret_id="$VAULT_SECRET_ID"

    secret_id="$VAULT_SECRET_ID"
Key                     Value
---                     -----
token                   hvs.CAESINRdgxl9LzwptrjYbLZ_5sSByoiZa6D-E8sRijeOnd9BGh4KHGh2cy5JUVZZeFFveU83YlhveE43UjVja0dhcWQ
token_accessor          6oREDIPtLaaB5HlYacIMI7D


### Conifgure docker  

docker login  #enter ur docker cred.
docker build -t davixs/student-tracker:latest .

![Alt text]<img width="1860" height="926" alt="Screenshot 2025-12-07 053838" src="https://github.com/user-attachments/assets/e125673e-d1ed-4191-873f-6e9099184ea3" />

![Alt text]<img width="1077" height="120" alt="Screenshot 2025-12-07 054813" src="https://github.com/user-attachments/assets/1a8a0ffc-0d88-4656-a705-1cbf744bbc90" />

### Configure trivy and use it to scan the images and codes 
install trivy
run this
trivy --version 
trivy image davixs4u/student-tracker:latest
trivy image -f table -o trivy-report.txt student-app:latest

![Alt text]<img width="1917" height="780" alt="Screenshot 2025-12-07 055811" src="https://github.com/user-attachments/assets/a74218a8-42f2-4a34-9bad-ea84ea91f4d9" />

![Alt text]<img width="1907" height="919" alt="Screenshot 2025-12-07 055840" src="https://github.com/user-attachments/assets/75ca2c24-fd4c-4806-8526-8bd2689d206a" />

<![Alt text]img width="953" height="460" alt="Screenshot 2025-12-07 055845" src="https://github.com/user-attachments/assets/c0ce5cdb-4334-42ae-b681-b98eaba5d2a7" />

![Alt text]<img width="1919" height="935" alt="Screenshot 2025-12-07 055919" src="https://github.com/user-attachments/assets/4f9caef6-e428-47ee-9cc2-dc970c5297ca" />



### on your current terminal where u exported vault env  or you export them again
docker run -d -p 8000:8000 -e VAULT_ADDR -e VAULT_ROLE_ID  -e VAULT_SECRET_ID davixs4u/student-tracker:latest

docker push yourdockerhubusername/student-tracker: latest

![Alt text]<img width="1470" height="586" alt="Screenshot 2025-12-07 062213" src="https://github.com/user-attachments/assets/f74f8891-1ea1-44fc-a1b5-06e1e63ad51f" />

# Configure kubectl and set it up

### Update System

sudo apt update && sudo apt upgrade -y
sudo apt install -y curl apt-transport-https ca-certificates gnupg lsb-release


 ## nstall kubectl
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

##  Install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

Create a file named devsecops-config.yaml with the following:

### Example
kind create cluster --name muna-cluster --config devsecops-config.yaml --image kindest/node:v1.30.0

![Alt text]<img width="951" height="418" alt="Screenshot 2025-12-07 063554" src="https://github.com/user-attachments/assets/93723c5a-97ba-43d5-bba7-0ac450268d55" />

Create a Pod YAML File called myapp.yaml and enter this

![Alt text]<img width="1786" height="851" alt="Screenshot 2025-12-07 064632" src="https://github.com/user-attachments/assets/694a9f54-a77b-46c6-a68c-4f2f41f18868" />

Apply the file ---> kubectl apply -f myapp.yaml

then kind delete cluster --name davsecops-config.yaml

Create a new cluster with an ingresss

![Alt text]<img width="943" height="559" alt="Screenshot 2025-12-07 065447" src="https://github.com/user-attachments/assets/e26b8f65-2541-41fe-94c0-75cd789a1609" />


#create your cluster
kind create cluster --name my-cluster --config devsecops-config.yaml

Set Up Ingress Controller for Kind

create ingress-controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

### Patch the ingress service to use host ports:
kubectl patch svc ingress-nginx-controller -n ingress-nginx \
  --type='merge' \
  -p '{"spec":{"type":"LoadBalancer"}}'

Create a Secret
### create a file vault-secret.yaml

![Alt text]<img width="1278" height="685" alt="Screenshot 2025-12-07 070347" src="https://github.com/user-attachments/assets/ebae5b90-0c02-4640-8fbc-ffeb29fdf6fb" />

Create a Deployment file  tracker.yaml. This contains your deployment and your service. I created mine in a namespace- my-app. 
You can choose to create a namespace or remove this from all your manifest

tracker-ingress.yml
![Alt text]<img width="1497" height="724" alt="Screenshot 2025-12-07 070637" src="https://github.com/user-attachments/assets/5b48b4c9-f6aa-4814-bbc1-eaf2018e3d91" />

### Scan all K8s files in folder
trivy config ./k8s-manifest

![Alt text]<img width="1895" height="947" alt="Screenshot 2025-12-07 071823" src="https://github.com/user-attachments/assets/5f85d705-0ee3-44a5-917d-33fff482bbd1" />


![Alt text]<img width="1574" height="950" alt="Screenshot 2025-12-07 071933" src="https://github.com/user-attachments/assets/73eef2a7-bd3f-4d47-a79a-c3a980be8e3d" />

![Alt text]<img width="941" height="443" alt="Screenshot 2025-12-07 071959" src="https://github.com/user-attachments/assets/4a02539e-1600-4c69-8df6-d865157401a6" />


![Alt text]<img width="941" height="443" alt="Screenshot 2025-12-07 071959" src="https://github.com/user-attachments/assets/58a3b0bf-5204-445e-81cb-fff64b7b8383" />


<i![Alt text]mg width="1660" height="897" alt="Screenshot 2025-12-07 072413" src="https://github.com/user-attachments/assets/c055f3f1-252a-40de-919f-e36e46c2482e" />


### Or with Checkov
checkov -d ./k8s-manifest

![Alt text]<img width="1911" height="932" alt="Screenshot 2025-12-07 073318" src="https://github.com/user-attachments/assets/0407fe95-ba9d-4de3-8291-d8a09697ffad" />


trivy config ./k8s-manifest -f json > k8s-scan-report.json

scan terraform with trivy and checkov

<i![Alt text]<img width="1911" height="923" alt="Screenshot 2025-12-07 073508" src="https://github.com/user-attachments/assets/6f2c6063-70aa-4615-afd2-cd7c9f4a62d3" />


<i![Alt text]<img width="1857" height="822" alt="Screenshot 2025-12-07 073613" src="https://github.com/user-attachments/assets/b51911dc-7435-4ad3-901d-7980bc82d8a1" />

still working on it





































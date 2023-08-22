# ucs-workshop
This repository contains all necessary material for UCS workshop

# Tasks

## Create Access Keys
1. Log in to [Huawei Cloud](https://www.huaweicloud.com/intl/en-us/) with provided credential
2. Click account name on the upper right corner of the console, and choose `My Credentials`
![MyCredentials](./images/001_CreateAKSK_001.png)
3. Choose `Access Keys` on the left panel of the console and Click `Create Access Key`
![CreateAccessKey](./images/001_CreateAKSK_002.png)
4. Save the credential safely on your laptop

## Environment Variables Setup
Before running terraform to create resources on Huawei Cloud, you need to setup credential provider for Terraform, hard-coded credential with Terraform is not recommended, we encourage you to provide credential through environment variables.

Depending on what kind of operating system you are using, You can choose one of the following methods to configure environment variables on your laptop for Terraform.

Get the credential from [Create Access Keys](#create-access-keys) task.

### Linux/MacOS

```
export HW_ACCESS_KEY="anaccesskey"
export HW_SECRET_KEY="asecretkey"
export HW_REGION_NAME="ap-southeast-3"
```

### Windows CMD
```
setx HW_ACCESS_KEY "anaccesskey"
setx HW_SECRET_KEY "asecretkey"
setx HW_REGION_NAME "ap-southeast-3"
```

### Windows Powershell
```
$Env:HW_ACCESS_KEY="anaccesskey"
$Env:HW_SECRET_KEY="asecretkey"
$Env:HW_REGION_NAME="ap-southeast-3"
```

## Apply Terraform Configuration
1. Execute the following command to clone `ucs-workshop` repository to your laptop or ECS
```
git clone https://github.com/Huawei-APAC-Professional-Services/ucs-workshop.git
```

2. Change directory to `ucs-workshop/infra`
3. Apply Terraform Configuration  

:bulb: Local state file is used for this Terraform configuration, but you can change it to remote state as well.
```
Terraform apply
```
Wait for the Terraform to finish, two CCE clusters will be created in Singapore and Hong Kong region.

4. Save the output
When the terraform applying completes, you will get the following three outputs, save it for future use or you can query it by using `terraform ouput` command in the future

* ecs_public_ip
* hk_elb_subnet_id
* singapore_elb_subnet_id 

![Saveoutput](./images/003_ApplyTerraform_001.png)

After the terraform applying, there is a `ecs.pem` file inside the `infra` directory, it will be used to login to ECS.

## Create UCS fleet
1. Log in to Huawei Cloud Console and Choose `Singapore` region using provided credential
2. On the upper left corner of the console, Choose `Service List` and search `ucs`
![searchucs](./images/002_CreateFleet_001.png)
3. Choose `Ubiquitous Cloud Native Service`
4. On the left side panel of the console, Choose `Permissions` under `Global Management`
![Permissions](./images/002_CreateFleet_002.png)
5. On the upper right corner of the console, Choose `Create Permission Policy` to allow current logged user `Admin` permission
![CreatePermissions](./images/002_CreateFleet_003.png)
![AlloAdminPermissions](./images/002_CreateFleet_004.png)
6. On the upper right corner of the console, Choose `Fleets` under `Infrastructure` and Choose `Create Fleet` on the same page
![RegisterCluster](./images/002_CreateFleet_005.png)
7. When creating the fleet, only the `name` parameter is needed
![CreateFleet](./images/002_CreateFleet_006.png)
8. On the `Fleets` page, Choose `Register Cluster`
![RegisterCluster2](./images/002_CreateFleet_007.png)
9. On the `Register Cluster` page, provide the following parameters:
* Fleet: Choose the one you created in last step
* Add Cluster: Choose the 2 CCE clusters created in [Apply Terraform Configuration](#apply-terraform-configuration) task
* Full Package: Don't choose, use `pay-per-use` billing model
![AddCluster01](./images/002_CreateFleet_008.png)
![AddCluster02](./images/002_CreateFleet_009.png)
10. On the `Fleets` page, at the right of the feet name, Choose `Enable` to enable unified orchestration of multiple clusters, cross-cluster auto scaling & service discovery, auto failover, etc.
![EnableFederation](./images/002_CreateFleet_010.png)
![EnableFederation1](./images/002_CreateFleet_011.png)
11. It will take some time to enable the federation
![EnabledFederation2](./images/002_CreateFleet_012.png)
12. Check UCS fleets status until the federation is enabled
![EnabledFederation2](./images/002_CreateFleet_013.png)

## Configure kubectl in ECS
1. Change directory to `ucs-workshop/infra`
2. If you don't have any ssh terminal installed on your laptop, you can use OpenSSH for Windows to log in to ECS, but first you may need to change the key permission when you are going to use OpenSSH for Windows, you can choose one of the two methods to change the key permission depends on which windows terminal you are using.

* Windows CMD
```
icacls ecs.pem /inheritance:r
icacls ecs.pem /grant:r "%username%":"(R)"
```
* Windows Powershell
```
icacls ecs.pem /inheritance:r
start-process "icacls.exe" -ArgumentList 'ecs.pem /grant:r "$env:USERNAME":"(R)"'
```
3. Log in to the ECS created in [Apply Terraform Configuration](#apply-terraform-configuration) with the following command on your terminal
```
ssh -i ecs.pem root@ecs_public_ip
```
4. Execute the following commands to install `kubectl`
```
apt-get update
apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubectl
```
5. Execute the following command to check if `kubectl` has been properly installed
```
kubectl version --client
```
6. Log in to Huawei Cloud console and choose `UCS` service
7. On the `Ubiquitous Cloud Native Service` page, Choose the fleet you created in [Create UCS fleet](#create-ucs-fleet) task.
![SelectFleet](./images/004_GetKubeConfig_001.png)
8. On the `Feet Info` part of the page, Click `kubectl` to download kubeconfig file
![ClickKubectl](./images/004_GetKubeConfig_002.png)
9. On the pop-up page, provide the following parameters:
* project name: `ap-southeast-3`
* VPC: `ucs_singapore`
* Master Node Subnet: `ucs_singapore_cce_master`
* Validity Period: any value will do

Click `Download` to save `kubeconfig.json` on your laptop

![kubeconfig-input](./images/004_GetKubeConfig_003.png)

10. Copy the content of the downloaded kubeconfig to `.kube/config` file in the ECS

11. Execute the following command to check if the kubeconfig is valid
```
kubectl get clusters
```
You will get the similar outputs like the following picture depicts
![Getclusters](./images/004_GetKubeConfig_005.png)


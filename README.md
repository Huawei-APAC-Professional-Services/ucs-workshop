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

Credentials are coming from [Create Access Keys](#create-access-keys) task.

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
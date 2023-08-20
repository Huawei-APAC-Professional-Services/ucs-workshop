terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">= 1.51.0"
    }
  }

  # Need to set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables for 
  # accessing OBS bucket

  # All the backend configuration will be saved in a separated file named obs.tfbackend
  # Change the bucket name and key according to customer environment
  backend "s3" {}
}

provider "huaweicloud" {
  region = "ap-southeast-3"
}

provider "huaweicloud" {
  alias = "hk"
  region = "ap-southeast-1"
}
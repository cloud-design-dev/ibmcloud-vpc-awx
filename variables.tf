##############################################
## Variables without defaults
##############################################

variable "project_prefix" {
  description = "Represents a name of the VPC that awx will be deployed into. Resources associated with awx will be prepended with this name."
  type        = string
}

variable "region" {
  description = "The region to create your VPC in, such as `us-south`. To get a list of all regions, run `ibmcloud is regions`."
  type        = string
}

variable "existing_resource_group" {
  description = "Name of an existing Resource Group to use for AWX deployment. If not set, a new Resource Group will be created. To list available resource groups, run `ibmcloud resource groups`."
  type        = string
}

variable "profile" {
  description = "The profile of compute CPU and memory resources that you want your VPC virtual servers to have. To list available profiles, run `ibmcloud is instance-profiles`."
  type        = string
  default     = "bx2-4x16"
}

variable "existing_ssh_key" {
  description = "Name of an existing SSH key in the targetted VPC region. If not set, a new SSH key will be created and added to the deployed AWX instance."
  type        = string
  default     = ""
}

variable "owner" {
  description = "Owner declaration for resource tags. e.g. 'ryantiffany'"
  type        = string
}

##############################################
## Variables with defaults
##############################################

variable "image" {
  description = "The name of the image that represents the operating system that you want to install on your VPC virtual server. To list available images, run `ibmcloud is images` The default image is for an `ibm-centos-7-6-minimal-amd64-1` OS."
  default     = "ibm-centos-7-9-minimal-amd64-10"
}

variable "classic_access" {
  description = "Allow classic access to the VPC."
  type        = bool
  default     = false
}

variable "default_address_prefix" {
  description = "The address prefix to use for the VPC. Default is set to auto."
  type        = string
  default     = "auto"
}

variable "number_of_addresses" {
  description = "Number of IPs to assign for each subnet."
  type        = number
  default     = 128
}


variable "frontend_rules" {
  description = "A list of security group rules to be added to the Frontend security group"
  type = list(
    object({
      name      = string
      direction = string
      remote    = string
      tcp = optional(
        object({
          port_max = optional(number)
          port_min = optional(number)
        })
      )
      udp = optional(
        object({
          port_max = optional(number)
          port_min = optional(number)
        })
      )
      icmp = optional(
        object({
          type = optional(number)
          code = optional(number)
        })
      )
    })
  )
  default = [
    {
      name       = "inbound-http"
      direction  = "inbound"
      remote     = "0.0.0.0/0"
      ip_version = "ipv4"
      tcp = {
        port_min = 80
        port_max = 80
      }
    },
    {
      name       = "inbound-https"
      direction  = "inbound"
      remote     = "0.0.0.0/0"
      ip_version = "ipv4"
      tcp = {
        port_min = 443
        port_max = 443
      }
    },
    {
      name       = "inbound-ssh"
      direction  = "inbound"
      remote     = "0.0.0.0/0"
      ip_version = "ipv4"
      tcp = {
        port_min = 22
        port_max = 22
      }
    },
    {
      name       = "inbound-icmp"
      direction  = "inbound"
      remote     = "0.0.0.0/0"
      ip_version = "ipv4"
      icmp = {
        code = 0
        type = 8
      }
    },
    {
      name       = "services-outbound"
      direction  = "outbound"
      remote     = "161.26.0.0/16"
      ip_version = "ipv4"
    },
    {
      name       = "all-outbound"
      direction  = "outbound"
      remote     = "0.0.0.0/0"
      ip_version = "ipv4"
    }
  ]
}

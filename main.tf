locals {
  # bits = {
  #   "18" = [4,4,4,4]
  #   "19" = [3,3,3,3]
  #   "20" = [2,2,2]
  #   "21" = [3,3,3,3,3,3,3,3]
  #   "22" = [2,2,2,2]
  #   "23" = [1,1]
  # }

  cidr = "10.0.0.0/12"
  divider = 22
  bitmask = split("/", local.cidr)[1]
  split = local.bitmask >= local.divider ? [] : [ for x in range(pow(2, (local.divider - local.bitmask))) : local.divider - local.bitmask]

  cidrs = length(local.split)  == 0 ? [local.cidr] : cidrsubnets(local.cidr, local.split...)

  ip_addresses = flatten([ for cidr in local.cidrs : [
    for i in range(pow(2, 32 - split("/", cidr)[1] )) : cidrhost(cidr, i)
    ]
  ])

}

output "ip_addresses" {
  value = length(local.ip_addresses)
}

output "test" {
  value = pow(2, (local.divider - local.bitmask))
}

# output "bitmask" {
#   value = local.bitmask
# }

# output "split" {
#   value = local.split
# }

output "cidrs" {
  value = length(local.cidrs)
}



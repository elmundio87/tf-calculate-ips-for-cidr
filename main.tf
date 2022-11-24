locals {

  cidr = "10.0.0.0/7"
  bitmask = split("/", local.cidr)[1]

  bitmask_minimum = 22
  divider = local.bitmask < 10 ? 8 * (10 - local.bitmask) : 4
  parts = concat([ for x in range(local.divider) : x/local.divider], [1])

  split = local.bitmask >= local.bitmask_minimum ? [] : flatten([ for div in range(1,local.divider + 1) : [
    for x in range(pow(2, (local.bitmask_minimum - local.bitmask)) * local.parts[div], pow(2, (local.bitmask_minimum - local.bitmask)) * local.parts[div - 1]) : local.bitmask_minimum - local.bitmask
    ]
  ])

  cidrs = length(local.split)  == 0 ? [local.cidr] : cidrsubnets(local.cidr, local.split...)

  ip_addresses = flatten([ for cidr in local.cidrs : [
    for i in range(pow(2, 32 - split("/", cidr)[1] )) : cidrhost(cidr, i)
    ]
  ])

}

# output "parts" {
#   value = local.parts
# }

output "cidr" {
  value = local.cidr
}

output "ip_addresses" {
  value = length(local.ip_addresses)
}

# output "cidrs" {
#   value = length(local.cidrs)
# }

# output "test" {
#   value = pow(2, (local.bitmask_minimum - local.bitmask))
# }

# output "bitmask" {
#   value = local.bitmask
# }

# output "split" {
#   value = local.split
# }





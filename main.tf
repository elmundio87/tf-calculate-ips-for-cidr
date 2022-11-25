locals {

  bitmask = split("/", var.cidr)[1]

  # This value decides at what point to start working around the limits of range(). Any bitmask higher than this value will be treated as a simple calculation
  last_unoptimised_bitmask = 22
  # This value decides how much to breakdown calculating the list that gets passed into cidrsubnets()
  # If the bitmask is lower than 10, work out this value dynamically. Else, just use 4 as a default value. 4 is not sufficient for higher IP ranges.
  divider = local.bitmask < 10 ? pow(2, (10 - local.bitmask + 2)) : 4
  # Create a list containing the values of 1/divider, 2/divider etc. for the purpose of chunking range calculations
  parts = concat([ for x in range(local.divider) : x/local.divider], [1])

  # If the bitmask is lower than the , don't bother with any optimisation
  # else
  # work out the parameter list needed for cidrsubnet(), splitting up the calculations to avoid needing a range higher than 1024
  # This uses the "parts" list to provide a way of spacing out the
  cidrsubnets_param_list = local.bitmask >= local.last_unoptimised_bitmask ? [] : flatten([ for div in range(1,local.divider + 1) : [
    for x in range(pow(2, (local.last_unoptimised_bitmask - local.bitmask)) * local.parts[div], pow(2, (local.last_unoptimised_bitmask - local.bitmask)) * local.parts[div - 1]) : local.last_unoptimised_bitmask - local.bitmask
    ]
  ])

  # Split up the input CIDR into a list of sub-cidrs (if CIDR bitmask is less than the minimum)
  cidrs = length(local.cidrsubnets_param_list) == 0 ? [var.cidr] : cidrsubnets(var.cidr, local.cidrsubnets_param_list...)

  # For each of the CIDRs from the previous step, work out the full list of IP addresses for each, then flatten the list into one
  ip_addresses = flatten([ for cidr in local.cidrs : [
    for i in range(pow(2, 32 - split("/", cidr)[1] )) : cidrhost(cidr, i)
    ]
  ])

}

output "ip_addresses" {
  description = "The number of IP addresses generated"
  value = length(local.ip_addresses)
}

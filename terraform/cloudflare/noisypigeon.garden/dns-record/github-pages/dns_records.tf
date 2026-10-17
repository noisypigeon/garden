# DNS records to point noisypigeon.garden (apex + www) at GitHub Pages
# (noisypigeon.github.io), the site's home (DEV-0165). Both DNS-only
# (proxied = false): GitHub Pages issues its own Let's Encrypt certificate for the custom domain, which it
# cannot do while Cloudflare is proxying (and terminating TLS for) the apex,
# and it redirects www -> apex natively, so no redirect rule is needed here.
#
# One cloudflare/dns-record module call per record (LIB-0004).
locals {
  records = {
    root_cname = {
      name    = "@"
      type    = "CNAME"
      content = "noisypigeon.github.io"
      proxied = false
      ttl     = 1
      comment = "github pages root cname (apex, cloudflare-flattened)"
    }
    www_cname = {
      name    = "www"
      type    = "CNAME"
      content = "noisypigeon.github.io"
      proxied = false
      ttl     = 1
      comment = "github pages www cname"
    }
  }
}

module "dns_record" {
  source   = "https://noisypigeon.garden/terraform/cloudflare/dns-record/v1.0.0"
  for_each = local.records

  zone     = local.cloudflare_zone
  name     = each.value.name
  type     = each.value.type
  content  = each.value.content
  ttl      = each.value.ttl
  proxied  = try(each.value.proxied, null)
  priority = try(each.value.priority, null)
  comment  = each.value.comment
}

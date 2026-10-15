# The raw cloudflare_dns_record resources this leaf used to declare, moved
# under the cloudflare/dns-record module without touching the records
# themselves (LIB-0004 §3). Keep these until every state that might still hold
# the old addresses has been applied past them.
moved {
  from = cloudflare_dns_record.root_cname
  to   = module.dns_record["root_cname"].cloudflare_dns_record.this
}

moved {
  from = cloudflare_dns_record.www_cname
  to   = module.dns_record["www_cname"].cloudflare_dns_record.this
}

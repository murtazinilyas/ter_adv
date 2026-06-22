output "out" {

    value=concat(module.marketing.fqdn , module.analytics.fqdn)
}

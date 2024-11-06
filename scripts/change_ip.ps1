$dnsname = Resolve-DnsName geracorp.ru
$ipaddr = $dnsname.IpAddress
$domainName = "bareos"
$rplaceStr = "$ipaddr bareos"
$rHost = "C:\Windows\System32\drivers\etc\hosts"
$items = Get-Content $rHost | Select-String $domainName
Write-host $items
foreach( $item in $items)
{
(Get-Content $rHost) -replace $item, $rplaceStr| Set-Content $rHost
}
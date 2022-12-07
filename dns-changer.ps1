# ---------
# functions
# ---------

function PrintDnsIPs {
    param([Uint32] $InterfaceIndex)

    $dnsList = Get-DnsClientServerAddress -InterfaceIndex $InterfaceIndex | where {$_.AddressFamily -eq 2}
    if (!$dnsList -ne $null) {
        Write-Host "Current DNS Servers:" -ForegroundColor Gray
        foreach($item in $dnsList.ServerAddresses) {
            Write-Host ("   {0}" -f $item) -ForegroundColor Gray
        }
        Write-Host
    }    
}

function Retry {
    Write-Host
    Write-Host "Press [1] for continue or other key for exit ..." -ForegroundColor Yellow
    $key = Read-Host
    if ($key -ne 1) {
        return
    }

    Start-Script
}

function GetAdapters {
    clear
    $adaptors = Get-NetAdapter
    $adaptors | Format-Table "InterfaceIndex", "Name", "InterfaceDescription", "MacAddress", "Status" | Out-String | Write-Host

    #$adaptors | Select-Object State, Status, StatusDescriptions, StatusInfo, InterfaceDescription | Format-Table

    Write-Host "Enter the Interface index or [0] for exit ..." -ForegroundColor Yellow
    $index = Read-Host -Prompt "Index"
    if ($index -eq 0) {
        return 0
    }
    $selectedAdaptors = $adaptors | where {$_.InterfaceIndex -eq $index}
    if ($selectedAdaptors -eq $null)
    {
        Write-Host "Invalid Interface index" -BackgroundColor Red
        return 0
    }
    $selectedAdaptor = $selectedAdaptors[0]
    if ($selectedAdaptor.Status -eq "Disabled" -or $selectedAdaptor.Status -eq "Not Present")
    {
        Write-Host ("{0} is {1}" -f $selectedAdaptor.Name, $selectedAdaptor.Status) -BackgroundColor Red
        return 0
    }

    PrintDnsIPs -InterfaceIndex $index
    return $index
}

function ChangeDns {
    param([Uint32] $InterfaceIndex)

    $dnsList = @(
    ("Auto", "", ""),
    ("Shekan", "178.22.122.100", "185.51.200.2"), 
    ("Google", "8.8.8.8", "8.8.4.4"),
    ("Cloudflare", "1.1.1.1", "1.0.0.1"),
    ("Open Dns", "208.67.222.222", "208.67.220.220"),
    ("Comodo Secure DNS", "8.26.56.26", "8.20.247.20"),
    ("DNS watch", "84.200.69.80", "84.200.70.40"),
    ("DNS Advantage", "156.154.70.1", "156.154.71.1"),
    ("Quad9", "9.9.9.9", "149.112.112.112"),
    ("verisign", "64.6.64.6", "64.6.65.6"),
    ("for COD", "185.55.225.25", "185.55.225.26"),
    ("for FIFA", "178.22.122.100", "185.51.200.2"),
    ("by cdkeysell", "78.157.42.101", "78.157.42.100"),
    ("Mofid WiFi", "10.1.231.254", "")
    )

    Write-Host
    Write-Host ("{0,2}{1,30}{2,20}{3,20}" -f "#", "Name", "Primary", "Secondary")
    Write-Host "-------------------------------------------------------------------------"
    for (($i = 0),($j = 1); $i -lt $dnsList.Count; $i++, $j++)
    {
        Write-Host ("{0,2}{1,30}{2,20}{3,20}" -f $j, $dnsList[$i][0], $dnsList[$i][1], $dnsList[$i][2])
        Write-Host "-------------------------------------------------------------------------"
    }

    Write-Host
    Write-Host "Enter index of the DNS row or [0] for exit ..." -ForegroundColor Yellow
    [uint32]$dnsIndex = Read-Host -Prompt "Index"

    if ($dnsIndex -eq 0) {
        return
    }
    elseif ($dnsIndex -gt $dnsList.Count -or $dnsIndex -lt 1) {
        Write-Host "Invalid DNS index" -BackgroundColor Red
        return
    }
    elseif ($dnsIndex -eq 1) {
        Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ResetServerAddresses
    }
    else {
        Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ServerAddresses ($dnsList[$dnsIndex - 1][1],$dnsList[$dnsIndex - 1][2])
    }

    PrintDnsIPs -InterfaceIndex $InterfaceIndex
}

function Start-Script {
    $interfaceIndex = GetAdapters
    if ($interfaceIndex -ne 0) {
        ChangeDns -InterfaceIndex $interfaceIndex
    }    

    Retry
}

# -----------
# main script
# -----------

#Set-ExecutionPolicy RemoteSigned

Start-Script
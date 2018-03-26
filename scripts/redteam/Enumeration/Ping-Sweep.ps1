<#
Ping-Sweep.ps1
Author: Micah Martin
Date: 1/29/17

USAGE: Test-Hosts IPADDRESS[/CIDR]
#>
param (
    [string]$SweepIP = $( Read-Host "Enter host to scan with CIDR notation" )
 )
# Prints the usage message and exits
# Returns: None
function USAGE {
    Write-Host "USAGE: Ping-Sweep -SweepIP [IP-ADDRESS]/[CIDR]"
    exit
}

# Prints the specified error message and exits
# Returns: None
function ERROR($msg) {
    Write-Warning -Message "$msg";
    exit

}

# Converts an IP address to a binary string
# Returns: String: A binary string
function ipToBinary($ip) {
    $octets = $ip.split(".") # Split the ip address into octets
    if ($octets.Length -ne 4) { # Check for 4 octets
        ERROR "An IP address consists of four octets..."
    }
    foreach ($oct in $octets) {
        $oct = [convert]::ToInt32($oct)
        if ($oct -gt 255 -Or $oct -lt 0) { # Check for numbers greater than 255
            ERROR "Octets must be between 0 and 255..." 
        }
        $octet = [convert]::ToString($oct,2) # Convert the string to binary
        $bitString += "0"*(8-$octet.length)+$octet # Pad the numbers to 8 digits and add it to the bitString
    }
    return $bitString
}

# Converts a binary string into an IP address
# Returns: String: An IP address
function binaryToIP($binary) {
    $ip = ""
    $binary = "0"*(32-$binary.length)+$binary
    if ($binary.Length -ne 32) { # Check there are 32 bits
        ERROR "An IP address consists of 32 bits..."
    }
    $binary = $binary.Insert(8," ").Insert(17," ").Insert(26," ") # Split the octets with spaces
    foreach ($oct in $binary.split(" ")) {
        $oct = [convert]::ToString([convert]::ToInt32($oct,2))
        $ip += "$oct"+" " # Pad the numbers to 8 digits and add it to the bitString
    }
    return $ip.Trim().Replace(" ",".") # Clear the whitespace at the end and change them to periods

}

# Given the IP address and CIDR notation, return the number of hosts in the subnet
# Returns: Int: Hosts in subnet
function getHosts($ip, $cidr) {
    return [math]::Pow(2,32-$cidr)-2
}

function forkScan($forkScanIp) {
    $networkInfoPing = New-Object System.Net.NetworkInformation.Ping;
    [Void](Register-ObjectEvent $networkInfoPing PingCompleted -Action {
        param($s, $e);
        $pingIp = $e.Reply.Address.ToString();
        if ($e.Reply.Status -eq "Success") {
            Write-Host "[+] $pingIp up";
        }
    })
    [Void]$networkInfoPing.SendPingAsync("$forkScanIp", 1500)
    $networkInfoPing.Dispose();

}
# Scans all the IPs between the two IP addresses (Assuming there the second is
# the same or greater and both are valid IPs

function scanRange($startIP, $endIP) {
    $startIpInt = [convert]::ToInt64($(ipToBinary($startIP)),2)
    $endIpInt = [convert]::ToInt64($(ipToBinary($endIP)),2)
    $hosts = 1+$endIpInt-$startIpInt
    
    for ($i = $startIpInt; $i -le $endIpInt; $i++) {
        $ip = [convert]::ToString($i,2)
        $ip = binaryToIP($ip)
        forkScan $ip
        $perc = "{0:N0}" -f ((1+$i-$startIpInt)/$hosts*100)
        Write-Progress -Activity “Scanning...” -status “[$perc%] Starting scan on [$ip]” -percentComplete $($perc)
    }
    Get-Job | Remove-Job -Force
    Write-Host "Scan finished!" -ForegroundColor Yellow
}

######################### TESTING WORKFLOW #########################


function main($string) {
    if ($string -eq "" -Or $string -eq $null) {
        USAGE
    }
    $ipBase, $cidr = $string.split('/')
    if ($cidr -gt 32) { # Error check the CIDR mask
        ERROR "CIDR mask cannot be greater than 32"
    } elseif ($cidr -eq $null -Or $cidr -eq "" -Or $cidr -eq 32) { # Single IP case
        Write-Host Testing $ipBase only...
        forkScan($ipBase)
        exit
    }
    $ipBaseB = ipToBinary $ipBase # Convert the IP address to binary

    <#
    NOTE: For the following commands, if the network address and broadcast are
    included in the pool, then change the commands below to the following:
    + "0"*(32-$cidr)
    This includes all cases.
    #>

    $ipLowB = $ipBaseB.Substring(0,$cidr) + "0"*(32-$cidr)# Get the lowest host address in binary
    $ipHighB = $ipBaseB.Substring(0,$cidr) + "1"*(32-$cidr) # Get the highest host address in binary
    $ipLow = binaryToIP $ipLowB # Get the lowest host address
    $ipHigh = binaryToIP $ipHighB # Get the highest host address
    $hostCount = getHosts $ip $cidr # Get the number of hosts
    Write-Host "Scanning $hostCount IPs between [$ipLow] and [$ipHigh]"
    scanRange $ipLow $ipHigh
}

main "$SweepIP"
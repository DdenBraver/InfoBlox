<#
Copyright 2016 Danny den Braver

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
#>

function Add-IBDelegationZone 
{
    <#
    .SYNOPSIS
    Adds a Delegation Zone to the Infoblox Gridserver

    .DESCRIPTION
    This cmdlet creates a new Delegation Zone on the Infoblox Gridserver.

    .PARAMETER FQDN
    The Fully Qualified DNS Name of the new Delegation Zone.
    
    .PARAMETER GridServer
    The name of the infoblox appliance.

    .PARAMETER Credential
    Add a Powershell credential object (created with for example Get-Credential).  
    
    .PARAMETER NameServers
    The Names of the Nameservers. 

    .PARAMETER NameServerIPs
    The IP Addresses of the Nameservers.

    .EXAMPLE
    Add-IBDelegationZone -FQDN 'newZone.domain.com' -NameServers 'dns1','dns2' -NameServerIPs '1.1.1.1','2.2.2.2' -GridServer infobloxserver.domain.com -Credential $Credential
    Creates the new Delegation Zone 'Zone' in 'domain.com'
    #>

    [cmdletbinding(SupportsShouldProcess = $true)]

    param(
        [Parameter(Mandatory = $true)]
        [string]$FQDN,

        [Parameter(Mandatory = $true)]
        [string]$GridServer,

        [Parameter(Mandatory = $true)]
        [string[]]$NameServers,

        [Parameter(Mandatory = $true)]
        [string[]]$NameServerIPs,

        [Parameter(Mandatory = $true)]
        [pscredential]$Credential
    )

    begin 
    {
        $i = 0
        $Nameserverarray = @()
        foreach ($Nameserver in $NameServers)
        {
            $Nameserverarray += @{name = $Nameserver; address = $NameServerIPs[$i]}
            $i++
        }
    }

    process 
    {
        $apiVersion = $script:apiVersion
        $uri = "https://$GridServer/wapi/v$apiVersion/zone_delegated"

        $data = @{
            fqdn = $FQDN
            delegate_to = $Nameserverarray
        }
        $json = $data | ConvertTo-Json

        if ($PSCmdlet.ShouldProcess($FQDN, 'Add InfoBlox Delegation Zone')) 
        {
            $request = Invoke-RestMethod -Uri $uri -Method Post -Body $json -ContentType 'application/json' -Credential $Credential
            return $request
        }
    }

    end {}
}

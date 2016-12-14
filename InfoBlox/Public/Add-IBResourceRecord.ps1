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

function Add-IBResourceRecord
{
    <#
    .SYNOPSIS
    Adds a Record on the Infoblox Gridserver

    .DESCRIPTION
    This cmdlet creates a record on the Infoblox Gridserver.

    .PARAMETER Type
    The Type of record you wish to add to the Infoblox Gridserver.
    
    .PARAMETER HostName
    The hostname for the record. Allows pipeline input.

    .PARAMETER IPv4address
    The IPv4 address for the record. Allows pipeline input.

    .PARAMETER Canonical
    The canonical name for the record. Allows pipeline input.

    .PARAMETER GridServer
    The name of the infoblox appliance. Allows pipeline input.

    .PARAMETER Credential
    Add a Powershell credential object (created with for example Get-Credential). Allows pipeline input.

    .EXAMPLE
    Add-IBResourceRecord -Type CName -HostName server.domain.com -GridServer infobloxserver.domain.com -Credential $Credential
    Adds a C Name to Infoblox

    .EXAMPLE
    Add-IBResourceRecord -Type A -IPv4Address '192.168.9.99' -HostName 'server.domain.com' -GridServer infobloxserver.domain.com -Credential $Credential
    Adds a A Record to Infoblox

    .EXAMPLE
    Add-IBResourceRecord -Type Host -IPv4Address '192.168.9.99' -HostName 'server.domain.com' -GridServer infobloxserver.domain.com -Credential $Credential
    Adds a Host Record to Infoblox
    #>

    [cmdletbinding()]

    param(
    [Parameter(Mandatory=$True)]
    [ValidateSet('A','CName','Host')]
    [String]$Type,

    [Parameter(Mandatory=$True, 
               ValueFromPipeline=$true, 
               ValueFromPipelineByPropertyName=$true)]
    [String]$HostName,

    [Parameter(Mandatory=$True, 
               ValueFromPipeline, 
               ValueFromPipelineByPropertyName,
               ParameterSetName=('A','Host'))]
    [string]$IPv4Address,

    [Parameter(Mandatory=$True, 
               ValueFromPipeline=$true, 
               ValueFromPipelineByPropertyName=$true,
               ParameterSetName='CName')]
    [String]$Canonical,

    [AllowNull()]
    [string]$Comment,

    [Parameter(Mandatory=$True, 
               ValueFromPipeline=$true, 
               ValueFromPipelineByPropertyName=$true)]
    [string] $GridServer,

    [Parameter(Mandatory=$True, 
               ValueFromPipeline=$true, 
               ValueFromPipelineByPropertyName=$true)]
    [PSCredential] $Credential
    )
    
    begin { 
        $data = @{
            name = "$HostName"
        }
        
        switch ($Type)
        {
            A 
            { 
                $data.Add('ipv4addr',$IPv4Address)
                $object = 'record:a'
            }
            CName   
            { 
                $data.add('canonical', $Canonical) 
                $object = 'record:cname'
            }
            Host    
            { 
                $data.add('ipv4addrs',@(@{ipv4addr = $IPv4Address})) 
                $object = 'record:host'
            }
        }

        if ($Comment)
        {
            $data.Add('comment', $($Comment.Trim()))
        }
    }

    process {
        $apiVersion = $script:apiVersion
        $uri = "https://$GridServer/wapi/v$apiVersion/$object"

        $json = $data | ConvertTo-Json

        if ($PSCmdlet.ShouldProcess($Hostname, "Add InfoBlox $Type Record")) 
        {
            $request = Invoke-RestMethod -Uri $uri -Method Post -Body $json -ContentType 'application/json' -Credential $Credential
            return $request
        }
    }

    end {}
}

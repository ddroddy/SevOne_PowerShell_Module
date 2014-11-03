#requires -version 3.0
$SevOne = $null

$TimeZones = Get-Content -Path $PSScriptRoot\timezones.txt
# Indicators, Objects

# Group > Device > object > indicator

# Device Groups and Object Groups

# Group membership can be explicit or rule based

# for object group the device group is required

function get-sevoneobject {} # accept a device throught the pipeline

function __TestReturn__ {
    param (
        #
        [parameter(Mandatory,
        ParameterSetName='Default',
        ValueFromPipeline,
        ValueFromPipelineByPropertyName)]
        $return      
      )
    switch ($return)
      {
        0 { throw 'Failed operation'}
        1 {Write-Verbose 'Successfully completed set operation'}
        default {throw "Unexpected return code: $return"}
      }
    }


function __TestSevOneConnection__ {
  Write-Debug 'Begin test'
  try {[bool]$Global:SevOne.returnthis(1)} catch {$false}
}

Function __fromUNIXTime__ {
Param
  (
    [Parameter(Mandatory=$true,
    Position=0,
    ValueFromPipeline=$true)]
    [int]$inputobject
  )
Process
  {
    [datetime]$origin = '1970-01-01 00:00:00'
    $origin.AddSeconds($inputobject)
  }
}

function __SevOneType__ {
[cmdletbinding()]
param(
    [parameter(Mandatory,
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [ValidateNotNullorEmpty()]
    [psobject]$InputObject
  )
process {
    Write-Verbose "`$InputObject contains $(($InputObject | measure ).count) items"
    Write-Debug 'Begin typename test'
    switch ($InputObject.psobject.TypeNames[0])
      {
        'SevOne.Device.DeviceInfo' {'device';continue}
        'SevOne.Threshold.ThresholdInfo' {'threshold';continue}
        'SevOne.Class.DeviceClass' {'DeviceClass';continue}
        'SevOne.Class.ObjectClass' {'ObjectClass';continue}
        'SevOne.Group.DeviceGroup' {'DeviceGroup';continue}
        'SevOne.Group.ObjectGroup' {'ObjectGroup';continue}
        'SevOne.Peer.PeerObject' {'Peer';continue}
        default {throw 'No type defined'} 
      }
  }
}

filter __PluginObject__ {
    $obj = [pscustomobject]@{
      Name = $_.name
      Id = $_.id
      Type = $_.objectString
    }
  $obj.PSObject.TypeNames.Insert(0,'SevOne.Plugin.PluginClass')
  $obj
  }

filter __DeviceObject__ {
  $base = $_
  $obj = [pscustomobject]@{
        ID = $base.id
        Name = $base.name
        AlternateName = $base.alternateName
        Description = $base.description
        IPAddress = $base.ip
        SNMPCapable = $base.snmpCapable -as [bool]
        SNMPPort = $base.snmpPort
        SNMPVersion = $base.snmpVersion
        SNMPROCommunity = $base.snmpRoCommunity
        snmpRwCommunity = $base.snmpRwCommunity
        synchronizeInterfaces = $base.synchronizeInterfaces
        synchronizeObjectsAdminStatus = $base.synchronizeObjectsAdminStatus
        synchronizeObjectsOperStatus = $base.synchronizeObjectsOperStatus
        peer = $base.peer
        pollFrequency = $base.pollFrequency
        elementCount = $base.elementCount
        discoverStatus = $base.discoverStatus
        discoverPriority = $base.discoverPriority
        brokenStatus = $base.brokenStatus -as [bool]
        isNew = $base.isNew -as [bool]
        isDeleted = $base.isDeleted -as [bool]
        allowAutomaticDiscovery = $base.allowAutomaticDiscovery -as [bool]
        allowManualDiscovery = $base.allowManualDiscovery -as [bool]
        osId = $base.osId
        lastDiscovery = $base.lastDiscovery -as [datetime]
        snmpStatus = $base.snmpStatus
        icmpStatus = $base.icmpStatus
        disableDiscovery = $base.disableDiscovery -as [bool]
        disableThresholding = $base.disableThresholding -as [bool]
        disablePolling = $base.disablePolling -as [bool]
      }
  $obj.PSObject.TypeNames.Insert(0,'SevOne.Device.DeviceInfo')
  $obj
}
 
filter __ThresholdObject__ {
  $obj = [pscustomobject]@{
      id = $_.id  
      name = $_.name
      description = $_.description 
      deviceId = $_.deviceId 
      policyId = $_.policyId 
      severity = $_.severity
      groupId  = $_.groupId 
      isDeviceGroup = $_.isDeviceGroup
      triggerExpression = $_.triggerExpression
      clearExpression = $_.clearExpression
      userEnabled = $_.userEnabled -as [bool]
      policyEnabled = $_.policyEnabled -as [bool]
      timeEnabled = $_.timeEnabled -as [bool]
      mailTo = $_.mailTo 
      mailOnce = $_.mailOnce 
      mailPeriod = $_.mailPeriod 
      lastUpdated = $_.lastUpdated 
      useDefaultTraps = $_.useDefaultTraps
      useDeviceTraps = $_.useDeviceTraps
      useCustomTraps = $_.useCustomTraps
      triggerMessage = $_.triggerMessage
      clearMessage = $_.clearMessage
      appendConditionMessages = $_.appendConditionMessages
    }
  $obj.PSObject.TypeNames.Insert(0,'SevOne.Threshold.ThresholdInfo')
  $obj
}

filter __AlertObject__ {
  $obj = [pscustomobject]@{
      id = $_.id 
      severity = $_.severity
      isCleared = $_.isCleared -as [bool]
      origin = $_.origin 
      deviceId = $_.deviceId
      pluginName = $_. pluginName
      objectId = $_.objectId 
      pollId = $_.pollId
      thresholdId = $_.thresholdId
      startTime = $_.Starttime | __fromUNIXTime__
      endTime = $_.endTime | __fromUNIXTime__
      message = $_.message 
      assignedTo = $_.assignedTo
      comments = $_.comments
      clearMessage = $_.clearMessage 
      acknowledgedBy = $_.acknowledgedBy
      number = $_.number
      automaticallyProcessed = $_.automaticallyProcessed
    }
  $obj.PSObject.TypeNames.Insert(0,'SevOne.Alert.AlertInfo')
  $obj
}

filter __ObjectClass__ {
  $obj = [pscustomobject]@{
      Name = $_.name
      Id = $_.id
    }
  $obj.PSObject.TypeNames.Insert(0,'SevOne.Class.ObjectClass')
  $obj
}

filter __DeviceGroupObject__ {
  $base = $_ 
  $obj = [pscustomobject]@{
      ID = $base.id
      ParentGroupID = $base.parentid
      Name = $base.name
    }
  $obj.PSObject.TypeNames.Insert(0,'SevOne.Group.DeviceGroup')
  $obj
}

filter __ObjectGroupObject__ {
  $base = $_ 
  $obj = [pscustomobject]@{
      ID = $base.id
      ParentGroupID = $base.parentid
      Name = $base.name
    }
  $obj.PSObject.TypeNames.Insert(0,'SevOne.Group.ObjectGroup')
  $obj
}

filter __PeerObject__ {
  $obj = [pscustomobject]@{
      serverId = $_.ServerId 
      name = $_.name 
      ip = $_.ip
      is64bit = $_.is64bit
      memory = $_.memory
      isMaster = $_.isMaster 
      username = $_.username 
      password = $_.password 
      capacity = $_.capacity
      serverLoad = $_.serverLoad
      flowLoad = $_.flowLoad 
      model = $_.model
    }
  $obj.PSObject.TypeNames.Insert(0,'SevOne.Peer.PeerObject')
  $obj
}

function Connect-SevOne {
<#
  .SYNOPSIS
     Create a connection to a SevOne Instance 
  .DESCRIPTION
     Creates a SOAP API connection to the specified SevOne Management instance.

     Only one sevone connection is available at any time.  Creating a new connection will overwrite the existing connection.
  .EXAMPLE
     Connect-SevOne -ComputerName 192.168.0.10 -credential (get-credential)

     Establishes a new connection to the SevOne Management server at 192.168.0.10

  .EXAMPLE
    $Cred = get-credential

    # Stores credentials inside the Variable Cred

    $SevOneName = 'MySevOneAppliance'

    # Stores the hostname

    Connect-SevOne $SevOneName $Cred

    # Connects to the SevOne Appliance MySevOneAppliance.  In this example the parameters are called positionally.

    # if you're unsure about your credentials you can check the username and password with the following commands:
    $Cred.UserName
    $Cred.GetNetworkCredential().password
#>
  [CmdletBinding()]
  param
  (
    # Set the Computername or IP address of the SevOneinstance you wish to connect to
    [Parameter(Mandatory,
    Position=0,
    ParameterSetName='Default')]
    [string]
    $ComputerName,
    
    # Specify the Credentials for the SevOne Connection
    [Parameter(Mandatory,
    Position=1,
    ParameterSetName='Default')]
    [PSCredential]
    $Credential,

    # Set this option if you are connecting via SSL
    [Parameter(ParameterSetName='Default')]
    [switch]$UseSSL
  )
Write-Debug 'starting connection process'
Write-Debug "`$UseSSL is $UseSSL"
if ($UseSSL) { $SoapUrl = "https://$ComputerName/soap3/api.wsdl" }
else { $SoapUrl = "http://$ComputerName/soap3/api.wsdl" }
Write-Debug 'URL is complete and stored in $SoapURL'
Write-Verbose "Beginning connection to $SoapUrl"
$Client = try {New-WebServiceProxy -Uri $SoapUrl -ErrorAction Stop} 
catch {throw "unable to reach the SevOne Appliance @ $SoapUrl"}
Write-Debug 'WebConnection stored in $Client'
Write-Verbose 'Creating cookie container'
try {$Client.CookieContainer = New-Object System.Net.CookieContainer}
catch {
    Write-Debug 'Failed to build system.net.cookiecontainer for $Client'
    throw 'unable to build cookie container'
  }
try {
    $return = $Client.authenticate($Credential.UserName, $Credential.GetNetworkCredential().Password)
    if ($return -lt 1)
      {
        throw 'Authentication failure'
      }
  } 
catch {
    Write-Warning $_.exception.message
    Write-Debug 'In failure block for $client.authenticate()'
    Throw 'Unable to authenticate with the SevOne Appliance'
  }
    $Global:SevOne = $Client
    Write-Verbose 'Successfully connected to SevOne Appliance'
}

function Get-SevOnePeer {
<#
  .SYNOPSIS
    Gathers one or more SevOne Peers.

  .DESCRIPTION
    This function will gather Peer objects for one or more peers in the SevOne environment. By default it will return a peer object for every peer connected.  if you specify the -ID parameter only the Peer with the corresponding ID will be returned.

  .EXAMPLE
    Get-SevOnePeer

    returns all Sevone Peers in the connected environment

  .EXAMPLE 
    Get-SevOnePeer -ID 26

    returns the SevOne peer with an ID of 26

  .NOTES

#>
[cmdletbinding(DefaultParameterSetName='default')]
param (
    #
    [Parameter(Mandatory,
    ParameterSetName='ID')]
    [int]$ID
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    switch ($PSCmdlet.ParameterSetName)
      {
        'default' {
            $return = $Global:SevOne.core_getPeers()
            continue
          }
        'id' {
            $return = $Global:SevOne.core_getPeerById($id)
            continue
          }
      }
    $return | __PeerObject__
  }
}

function Get-SevOneDevice {
<#
  .SYNOPSIS
    Gathers SevOne devices

  .DESCRIPTION
    Gather one or more SevOne devices from the SevOne API

  .EXAMPLE
    Get-SevOneDevice

    Gathers all SevOne devices

  .EXAMPLE
    Get-SevOneDevice -Name MyServer

    Returns a device object for the device named MyServer

  .EXAMPLE
    Get-SevOne -IPAddress 192.168.0.100

    Returns a device object for the device with an IP of 192.168.0.100

  .NOTES
    At this point there is no support for wildcards.
#>
[cmdletbinding(DefaultParameterSetName='default')]
param
  (
    #
    [parameter(Mandatory,
    ParameterSetName='Name',
    ValueFromPipelineByPropertyName)]
    [string]$Name,
    
    #
    [parameter(Mandatory,
    ParameterSetName='ID',
    ValueFromPipelineByPropertyName)]
    [int]$ID,
    
    #
    [parameter(Mandatory,
    ParameterSetName='IPAddress',
    ValueFromPipelineByPropertyName)]
    [IPAddress]$IPAddress
  )
begin {
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
  }
process {
    switch ($PSCmdlet.ParameterSetName)
      {
        'default' { 
            Write-Debug 'in default block'
            try {$return = $Global:SevOne.core_getDevices()} catch {
                $return = $null
                Write-Error $_.exception.message
              }
            continue
          }
        'Name' { 
            Write-Debug 'in name block'
            try {
                $return =  $Global:SevOne.core_getDeviceByName($Name)
                Write-Debug 'Test $return to ensure object is not blank'
                if (-not $return.id)
                  {throw "Empty object returned for $Name"}
              } 
            catch {
                $return = $null
                Write-Error "No device found with name: $Name"
                Write-Error $_.exception.message
              }
            continue
          }
        'ID' { 
            Write-Debug 'in id block'
            try {$return = $Global:SevOne.core_getDeviceById($ID)} catch {
                $return = $null
                Write-Error "No device found with id: $id"
                Write-Error $_.exception.message
              }
            continue
          }
        'IPAddress' { 
            Write-Debug 'in IPAddress block'
            try {
                $return = $Global:SevOne.core_getDeviceById(($Global:SevOne.core_getDeviceIdByIp($IPAddress.IPAddressToString)))
              } 
            catch {
                $return = $null
                Write-Error "No device found with IPAddress: $($IPAddress.IPAddressToString)"
                Write-Error $_.exception.message
              }
            continue
        }
      }
    if ($return)
      {
        $return | __DeviceObject__
      }
  }
}

function Get-SevOneAlert {
<#
  .SYNOPSIS
    Gather open alerts in the SevOne environment.

  .DESCRIPTION
    This function is able to gather alerts generally or on a by device basis.  You can also use -StartTime to filter return data by starttime.  Only open alerts are gathered with this function.

  .EXAMPLE
    Get-SevOneAlert

    returns all active alerts

  .EXAMPLE
    Get-SevOneDevice -Name MyServer | Get-SevOneAlert

    returns all active alerts for the device, MyServer

  .NOTES
    Only gathers open alerts
    Starttime filters on the client side and not the Server side

#>
[cmdletbinding(DefaultParameterSetName='default')]
param
  (
    # The Device that will be associated with Alarms pulled
    [parameter(Mandatory,
    Position=0,
    ValueFromPipelineByPropertyName,
    ValueFromPipeline,
    ParameterSetName='Device')]
    [PSObject]$Device,

    # The time to start pulling alerts
    [parameter(ParameterSetName='Device')]
    [parameter(ParameterSetName='Default')]    
    [datetime]$StartTime # not sure I'm happy with the way this parameter is implemented. The filtering occurs on the client side which is pretty wasteful.  Need to explore the API's filtering capabilities.
  )
begin {
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
  }
process 
  {
    switch ($PSCmdlet.ParameterSetName)
      {
        'default' {
            $return = $Global:SevOne.alert_getAlerts(0)
          }
        'device' {
            $return = $Global:SevOne.alert_getAlertsByDeviceId($Device.id,0)
          }
      }
    foreach ($a in ($return | __AlertObject__))
      {
        if ($StartTime)
          {
            if ($a.startTime -ge $StartTime)
              {$a}
          }
        else {$a}
      }
  }
end {}
}

function Close-SevOneAlert {
<#
  .SYNOPSIS
    Closes a SevOne Alert 

  .DESCRIPTION
    This function will close one or more SevOne Alerts

  .EXAMPLE
    Get-SevOneAlert | Close-SevOneAlert -message "clearing all alerts"

    Closes all open alerts and appends a message saying, "clearing all alerts"

  .EXAMPLE
    $Device = Get-SevOneDevice -Name MyServer

    $Alert = Get-SevOneAlert -Device $Device

    Close-SevOneAlert -Alert $Alert

  .NOTES
    This one is working really well, the default message may change over time.
#>
[cmdletbinding()]
param 
  (
    [Parameter(Mandatory,
    position=0,
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    $Alert,
    [string]$Message = 'Closed via API'
  )
begin {
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
  }
process{
    try {
        $return = $Global:SevOne.alert_clearByAlertId($Alert.ID,$Message) 
      }
    catch {}
  }
end {}
}

function Get-SevOnePlugin {
<#
  .SYNOPSIS
    Gather SevOne plugins
  .DESCRIPTION
    This function will gather all SevOne plugin objects
  .NOTES
#>
[cmdletBinding(DefaultParameterSetName='default')]
param (
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    switch ($PSCmdlet.ParameterSetName)
      {
        'default' {
            $return = $Global:SevOne.core_getPlugins()
          }
      }
    $return | __PluginObject__
  }
end {}
  }
 
function Get-SevOneDeviceGroup { # 
<#
  .SYNOPSIS
    returns device groups

  .DESCRIPTION
    This function will return one or more device groups

  .EXAMPLE
    Get-SevOneDeviceGroup

  .NOTES
    not failing when group doesn't exist, we can probably copy the functionality out of the Device function.

    It's likely that we can combine this with the Object Group function

    Additionally it looks like the API uses Device Group and Device Class interchangeably.  We may be able to eliminate the DeviceClass functions.
#>
[cmdletbinding(DefaultParameterSetName='default')]
param (
    #
    [Parameter(Mandatory,
    ParameterSetName='Name')]
    [string]$Name,

    #
    [Parameter(Mandatory,
    ParameterSetName='ID')]
    [int]$ID
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    Write-Debug 'opened process block'
    switch ($PSCmdlet.ParameterSetName)
      {
        'Default' {
            Write-Debug 'in Default block'
            $return = $Global:SevOne.group_getDeviceGroups()
            Write-Debug "`$return has $($return.Count) members"
            continue
          }
        'Name' {
            Write-Debug 'in Name block'
            $return = $Global:SevOne.group_getDeviceGroupById($Global:SevOne.group_getDeviceGroupIdByName($Name,$null)) # only returning one result
            Write-Debug "`$return has $($return.Count) members"
            continue
          }
        'ID' {
            Write-Debug 'in ID block'
            $return = $Global:SevOne.group_getDeviceGroupById($ID)
            Write-Debug "`$return has $($return.Count) members"
            continue
          }
      }
    Write-Debug 'Sending $return to object creation'
    $return | __DeviceGroupObject__
  }
end {}
}

function Set-SevOneDeviceGroup {}

function New-SevOneDeviceGroup {
<#
  .SYNOPSIS
    Create a new SevOne Device group
  .DESCRIPTION
    This function will create a new SevOne Device group, the new ID will be generated by the system.  The Parent group and Name are required.
#>
[cmdletBinding(DefaultParameterSetName='group')]
param (
    # ID of the parent group
    [Parameter(Mandatory,
    ValueFromPipelineByPropertyName,
    ParameterSetName='id')]
    [int]$ParentID,

    # Group object for parent group
    [Parameter(Mandatory,
    ValueFromPipelineByPropertyName,
    ParameterSetName='group')]
    $ParentGroup,
    
    # The name for the new group
    [Parameter(Mandatory,
    ValueFromPipelineByPropertyName,
    ParameterSetName='group')]
    [Parameter(Mandatory,
    ValueFromPipelineByPropertyName,
    ParameterSetName='id')]
    [string]$Name,

    # Set if you would like the new group to be output to the pipeline
    [Parameter(
    ValueFromPipelineByPropertyName,
    ParameterSetName='group')]
    [Parameter(
    ValueFromPipelineByPropertyName,
    ParameterSetName='id')]
    [switch]$PassThrough
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    switch ($PSCmdlet.ParameterSetName)
      {
        'group' {
            $return = $Global:SevOne.group_createDeviceGroup($Name,$ParentGroup.ID)
            Write-Debug 'Finished generating $return'
          }
        'id' {
             $return = $Global:SevOne.group_createDeviceGroup($Name,$ParentID)
             Write-Debug 'Finished generating $return'
          }
      }
    switch ($return)
      {
        -1 {Write-Error "Could not create group: $Name" ; continue}
        default {
            Write-Verbose "Successfully created group $Name" 
            if ($PassThrough) {Get-SevoneDeviceGroup -ID $return}
            continue
          }
      }
  }
end {}
}

function Remove-SevOneItem {
<#
  .SYNOPSIS
    Deletes a SevOne Item
  .DESCRIPTION
    This function will remove any SevOne item specified to the target parameter.  Works against all SevOne types.
  .EXAMPLE
    Get-SevOneDevice 'OldDevice' | Remove-SevOneItem

    Deletes the device named OldDevice
  .EXAMPLE
    Get-SevOneThreshold StaleThreshold | Remove-SevOneItem

    Deletes the Threshold named StaleThreshold
  .NOTES
    Deleted items are actually just marked for deletion by the API.  Items are removed later when the SevOne appliance goes through it's deletion process.
#>
[cmdletbinding(SupportsShouldProcess=$true,DefaultParameterSetName='default',ConfirmImpact='high')]
param (
    #
    [parameter(Mandatory,
    ValueFromPipeline,
    ValueFromPipelineByPropertyName,
    ParameterSetName='default')]
    $Target
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    Write-Verbose "Opening process block for $($Target.name)"
    if ($PSCmdlet.ShouldProcess("$($Target.name)","Remove SevOne Item"))
      {
        Write-Debug 'Passed confirm point, about to test object type'
        switch ($Target | __SevOneType__)
          {
            'deviceGroup' {
                $return = $Global:SevOne.group_deleteDeviceGroup($Target.id)
                Write-Debug 'finished generating $return'
                if ($return -ne 1) {
                    Write-Debug 'in failure block'
                    Write-Error "failed to delete $($Target.name)"
                  }
                continue
              }
            'ObjectGroup' {
                $return = $Global:SevOne.group_deleteObjectGroup($Target.id)
                Write-Debug 'finished generating $return'
                if ($return -ne 1) {
                    Write-Debug 'in failure block'
                    Write-Error "failed to delete $($Target.name)"
                  }
                continue
              }
            'deviceClass' {
                $return = $Global:SevOne.group_deleteDeviceClass($target.id)
                if ($return -ne 1) {
                    Write-Error "failed to delete $($Target.name)"
                  }
                continue
              }
            'ObjectClass' {
                $return = $Global:SevOne.group_deleteObjectClass($Target.id)
                Write-Debug 'finished generating $return'
                if ($return -ne 1) {
                    Write-Debug 'in failure block'
                    Write-Error "failed to delete $($Target.name)"
                  }
                continue
              }
            'device' {
                $return = $Global:SevOne.core_deleteDevice($Target.id)
                Write-Debug 'finished generating $return'
                if ($return -ne 1) {
                    Write-Debug 'in failure block'
                    Write-Error "failed to delete $($Target.name)"
                  }
                continue
              }
            default {throw 'Deletion activities not defined'}
          }
      }
  }
}

function New-SevOneDevice {
<##>
[cmdletBinding(DefaultParameterSetName='group')]
param (    
    #
    [Parameter(Mandatory,
    ValueFromPipelineByPropertyName,
    ParameterSetName='group')]
    [string]$Name,
    
    #
    [Parameter(Mandatory,
    ValueFromPipelineByPropertyName,
    ParameterSetName='group')]
    [ipaddress]$IPAddress,
    
    #
    [Parameter(
    ValueFromPipelineByPropertyName,
    ParameterSetName='group')]
    $Peer = (Get-SevOnePeer)[0], # this is actually pretty hokey, will need to find a better way to do this.
    
    #
    [Parameter(
    ValueFromPipelineByPropertyName,
    ParameterSetName='group')]
    $Group = (Get-SevOneDeviceGroup -Name 'All Device Groups'),

    #
    [Parameter(
    ValueFromPipelineByPropertyName,
    ParameterSetName='group')]
    [string]$Description = '',

    #
    [Parameter(
    ValueFromPipelineByPropertyName,
    ParameterSetName='group')]
    [switch]$PassThrough
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    switch ($PSCmdlet.ParameterSetName)
      {
        'group' {
            Write-Debug 'In group block'
            $return = $Global:SevOne.core_createDeviceInGroup($Name,$IPAddress.IPAddressToString,$Peer.id,$Description,$Group.id)
            Write-Verbose 'finished create operation, testing $return'
            Write-Debug "`$return = $return"
            switch ($return)
              {
                -1 {Write-Error "Could not add device: $Name" ; continue}
                -2 {Write-Error "Could not find peer: $($Peer.Name)" ; continue}
                -3 {Write-Error "$($Peer.Name) does not support adding devices" ; continue}
                0 {Write-Error "failed creating device $name" ; continue}
                default {
                    Write-Verbose "Successfully created device $Name"
                    if ($PassThrough) {Get-SevOneDevice -ID $return}
                  }
              }
          }
      }
  }
end {}
}

function Set-SevOneDevice {
<##>
[cmdletBinding(DefaultParameterSetName='default')]
param ( 
    #
    [Parameter(Mandatory,
    ValueFromPipeline,
    ValueFromPipelineByPropertyName,
    ParameterSetName='default')]
    $Device,
       
    #
    [Parameter(
    ValueFromPipelineByPropertyName,
    ParameterSetName='default')]
    [string]$Name,

    #
    [Parameter(
    ValueFromPipelineByPropertyName,
    ParameterSetName='default')]
    [string]$AlternateName,

    #
    [Parameter(
    ValueFromPipelineByPropertyName,
    ParameterSetName='default')]
    [ipaddress]$IPAddress,

    #
    [Parameter(
    ValueFromPipelineByPropertyName,
    ParameterSetName='default')]
    [string]$Description = '',

    #
    [Parameter(
    ValueFromPipelineByPropertyName,
    ParameterSetName='default')]
    #[validateSet({$TimeZones})] # try and imporve this to support tab completion
    [string]$TimeZone,

    #
    [Parameter(
    ValueFromPipelineByPropertyName,
    ParameterSetName='default')]
    [timespan]$PollingInterval,

    #
    [Parameter(
    ValueFromPipelineByPropertyName,
    ParameterSetName='default')]
    [bool]$Polling
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    Write-Verbose "Opening Process block for $($Device.name)"
    $xml = $global:SevOne.core_getDeviceById($device.id)
    Write-Debug 'loaded $xml'
    #region SetValues
    if ($Name) {$xml.name = $Name}
    if ($AlternateName) {$xml.alternateName = $AlternateName}
    if ($IPAddress) {$xml.ip = $IPAddress.IPAddressToString}
    if ($Description) {$xml.description = $Description}
    if ($TimeZone) {$xml.timezone = $TimeZone}
    if ($PollingInterval) {$xml.pollFrequency = $PollingInterval.TotalSeconds}
    #if ($PollingConcurrency) {$xml.p}
    if ($Polling) {$xml.disablePolling = [int](-not $Polling) }
    #if ($DiscoveryLevel) {$xml.discoverPriority = }
    Write-Debug 'Finished modifying XML'
    #endregion SetValues
    $return = $global:SevOne.core_setDeviceInformation($xml)
    Write-Debug 'Finished setting device, $return is about to be tested'
    $return | __TestReturn__
    Write-Verbose "Succesfully modified $($device.name)"
  }
}

function Get-SevOneThreshold {
<##>
[cmdletbinding(DefaultParameterSetName='device')]
param (
    #
    [Parameter(Mandatory,
    ParameterSetName='Name')]
    [string]$Name,

    #
    [Parameter(Mandatory,
    ParameterSetName='Name')]
    [Parameter(Mandatory,
    ParameterSetName='ID')]
    [Parameter(Mandatory,
    ParameterSetName='Device',
    ValueFromPipeline,
    ValueFromPipelinebyPropertyName)]
    $Device,

    #
    [Parameter(ParameterSetName='Device')]
    $Object,

    #
    [Parameter(ParameterSetName='Device')]
    $Pluggin,

    #
    [Parameter(ParameterSetName='Device')]
    $Indicator,

    #
    [Parameter(Mandatory,
    ParameterSetName='ID')]
    [int]$ID
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    switch ($PSCmdlet.ParameterSetName)
      {
        'Name' {
            $return = $Global:SevOne.threshold_getThresholdByName($Device.id,$Name)
            continue
          }
        'Device' {
            $return = $Global:SevOne.threshold_getThresholdsByDevice($Device.id,$Pluggin.id,$Object.id,$Indicator.id)
            continue
          }
        'ID' {
            $return = $Global:SevOne.threshold_getThresholdById($Device.id,$ID)
            continue
          }
      }
    $return | __ThresholdObject__
  }
}

function New-SevOneThreshold {}

function Set-SevOneThreshold {}

function Get-SevOneObjectGroup {
<##>
[cmdletbinding(DefaultParameterSetName='default')]
param (
    #
    [Parameter(Mandatory,
    ParameterSetName='ID')]
    [int]$ID
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    Write-Debug 'opened process block'
    switch ($PSCmdlet.ParameterSetName)
      {
        'Default' {
            Write-Debug 'in Default block'
            $return = $Global:SevOne.group_getObjectGroups()
            Write-Debug "`$return has $($return.Count) members"
            continue
          }
        'ID' {
            Write-Debug 'in ID block'
            $return = $Global:SevOne.group_getObjectGroupById($ID)
            Write-Debug "`$return has $($return.Count) members"
            continue
          }
      }
    Write-Debug 'Sending $return to object creation'
    $return | __ObjectGroupObject__
  }
end {}
}

function Get-SevOneObjectClass {
<#

#>
[cmdletbinding(DefaultParameterSetName='default')]
param (
    #
    [Parameter(Mandatory,
    ParameterSetName='Name')]
    [string]$Name,

    #
    [Parameter(Mandatory,
    ParameterSetName='ID')]
    [int]$ID
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    switch ($PSCmdlet.ParameterSetName)
      {
        'Default' {
            $return = $Global:SevOne.group_getObjectClasses()
            continue
          }
        'Name' {
            $return = $Global:SevOne.group_getObjectClassByName($Name)
            continue
          }
        'ID' {
            $return = $Global:SevOne.group_getObjectClassById($ID)
            continue
          }
      }
    $return | __ObjectClass__
  }
} 

function Add-SevOneDeviceToGroup {
<##>
[cmdletbinding(DefaultParameterSetName='default')]
param (
    [parameter(Mandatory,
    ValueFromPipeline,
    ValueFromPipelineByPropertyName,
    ParameterSetName='default')]
    [PSObject]$Device,
    [parameter(Mandatory,
    ValueFromPipelineByPropertyName,
    ParameterSetName='default')]
    [PSObject]$Group,
    [parameter(Mandatory,
    ValueFromPipeline,
    ValueFromPipelineByPropertyName,
    ParameterSetName='ID')]
    [int]$DeviceID,
    [parameter(Mandatory,
    ValueFromPipelineByPropertyName,
    ParameterSetName='ID')]
    [int]$GroupID
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    switch ($PSCmdlet.ParameterSetName)
      {
        'default' {
            $return = $Global:SevOne.group_addDeviceToGroup($Device.ID,$Group.ID)
          }
        'ID' {
            $return = $Global:SevOne.group_addDeviceToGroup($DeviceID,$GroupID)
          }
      }
    switch ($return)
      {
        0 {Write-Error 'Could not add device to group' ; continue}
        default {
            Write-Verbose 'Successfully created added device to group'
            continue
          }
      }
  }
end {}
}

function Add-SevOneObjectToGroup {
<##>
[cmdletbinding(DefaultParameterSetName='default')]
param (
    #
    [parameter(Mandatory,
    ValueFromPipeline,
    ValueFromPipelineByPropertyName,
    ParameterSetName='default')]
    [PSObject]$Device,
    #
    [parameter(Mandatory,
    ValueFromPipelineByPropertyName,
    ParameterSetName='default')]
    [PSObject]$Group,
    #
    [parameter(Mandatory,
    ValueFromPipelineByPropertyName,
    ParameterSetName='default')]
    [PSObject]$Object,
    #
    [parameter(Mandatory,
    ValueFromPipelineByPropertyName,
    ParameterSetName='default')]
    [PSObject]$Plugin
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    switch ($PSCmdlet.ParameterSetName)
      {
        'default' {
            $return = $Global:SevOne.group_addObjectToGroup($Device.id,$Object.id,$Group.id,$Plugin.id)
          }
      }
    switch ($return)
      {
        0 {Write-Error "Could not add object, $($Object.name) to group" ; continue}
        default {
            Write-Verbose 'Successfully created added device to group'
            continue
          }
      }
  }
end {}
}

function Get-SevOneWMIProxy {
<#
  .SYNOPSIS

  .DESCRIPTION

  .EXAMPLE
    

  .EXAMPLE
    

  .EXAMPLE
    

  .NOTES
    At this point there is no support for wildcards.
#>
[cmdletbinding(DefaultParameterSetName='default')]
param
  (
  )
begin {
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
  }
process {
    Write-Verbose 'Opening process block'
    Write-Debug "Switch on parameter set name, current value: $($PSCmdlet.ParameterSetName)"
    switch ($PSCmdlet.ParameterSetName)
      {
        'default' { $Global:SevOne.plugin_wmi_findProxy('') ; continue}
        'filter' {
            $filter = 'somevalue' #Build filter in jagged array 
            #filter = ,@('Name',$name),@('ip',$ip)         
          }
      }
  }
}

function New-SevOneWMIProxy {
<#
  .SYNOPSIS

  .DESCRIPTION

  .EXAMPLE
    
  .EXAMPLE
    
  .EXAMPLE
    
  .NOTES
    
#>
[cmdletbinding(DefaultParameterSetName='default')]
param
  (
    #
    [parameter(Mandatory,
    ParameterSetName='default',
    ValueFromPipelineByPropertyName)]
    [string]$Name,
    
    #
    [parameter(Mandatory,
    ParameterSetName='default',
    ValueFromPipelineByPropertyName)]
    [int]$Port,
    
    #
    [parameter(Mandatory,
    ParameterSetName='default',
    ValueFromPipelineByPropertyName)]
    [IPAddress]$IPAddress
  )
begin {
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
  }
process {
    Write-Verbose 'begin process block'
    switch ($PSCmdlet.ParameterSetName)
      {
        'default' {$return = $Global:SevOne.plugin_wmi_createProxy($Name,$IPAddress.IPAddressToString,$Port.ToString()) }
      }
    switch ($return)
      {
        0 {Write-Error "Failed to create Proxy $Name"}
        default {Write-Verbose "Successfully created proxy: $Name"}
      }
  }
}

function Set-SevOneWMIProxy {
<#
  .SYNOPSIS

  .DESCRIPTION

  .EXAMPLE
    
  .EXAMPLE
    
  .EXAMPLE
    
  .NOTES
    
#>
[cmdletbinding(DefaultParameterSetName='default')]
param
  (
    #
    [parameter(Mandatory,
    position = 0,
    ParameterSetName='default',
    ValueFromPipelineByPropertyName)]
    $Device,

    #
    [parameter(Mandatory,
    position = 1,
    ParameterSetName='default',
    ValueFromPipelineByPropertyName)]
    [bool]$Enabled 
  )
begin {
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
  }
process {
    $return = $Global:SevOne.plugin_wmi_enablePluginForDevice($Device.id, [int]$Enabled)
    switch ($return)
      {
        0 {Write-Error "Failed to set WMI plugin on $($Device.name)" ; continue}
        1 {Write-Verbose "Successfully set plugin on $($Device.name)" ; continue}
        default {throw "unexpected return code: $return" }
      }
  }
}

function Add-SevOneWMIProxytoDevice {
<#
  .SYNOPSIS

  .DESCRIPTION

  .EXAMPLE
    
  .EXAMPLE
    
  .EXAMPLE
    
  .NOTES
    
#>
[cmdletbinding(DefaultParameterSetName='default')]
param
  (
    #
    [parameter(Mandatory,
    ParameterSetName='Default',
    ValueFromPipelineByPropertyName)]
    $Device,

    #
    [parameter(Mandatory,
    ParameterSetName='Default',
    ValueFromPipelineByPropertyName)]
    $Proxy,

    #
    [parameter(Mandatory,
    ParameterSetName='Default',
    ValueFromPipelineByPropertyName)]
    [bool]$UseNTLM,

    # Be sure to omit domain info
    [parameter(Mandatory,
    ParameterSetName='Default',
    ValueFromPipelineByPropertyName)]
    [pscredential]$Credential,

    #
    [parameter(Mandatory,
    ParameterSetName='Default',
    ValueFromPipelineByPropertyName)]
    [string]$Domain,

    #
    [parameter(Mandatory,
    ParameterSetName='Default',
    ValueFromPipelineByPropertyName)]
    [validateSet('Default','None','Connect','Call','Packet','PacketIntegrity','PacketPrivacy','Unchanged')]
    [string]$AuthenticationLevel = 'default',

    #
    [parameter(Mandatory,
    ParameterSetName='Default',
    ValueFromPipelineByPropertyName)]
    [validateSet('Default','Anonymous','Delegate','Identify','Impersonate')]
    [string]$ImpersonationLevel = 'default'
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    Set-SevOneWMIProxy -Enabled $true -Device $Device
    $return = $Global:SevOne.plugin_wmi_setProxy($Device.id,$Proxy.id)
    $return | __TestReturn__
    $return = $Global:SevOne.plugin_wmi_setUseNTLM($Device.id,([int]$UseNTLM).ToString())
    $return | __TestReturn__
    $return = $Global:SevOne.plugin_wmi_setWorkgroup($device.id, $Domain)
    $return | __TestReturn__
    $return = $Global:SevOne.plugin_wmi_setUsername($Device.id, $Credential.UserName)
    $return | __TestReturn__
    $return = $Global:SevOne.plugin_wmi_setPassword($Device.id, $Credential.GetNetworkCredential().Password)
    $return | __TestReturn__
    $return = $Global:SevOne.plugin_wmi_setAuthenticationLevel($Device.id, $AuthenticationLevel)
    $return | __TestReturn__
    $return = $Global:SevOne.plugin_wmi_setImpersonationLevel($Device.id, $ImpersonationLevel)
    $return | __TestReturn__
  }
}

function Enable-SevOneDiscovery {
param (
    #
    [parameter(Mandatory,
    ParameterSetName='Default',
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    $Device
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    $return = $Global:SevOne.core_setDeviceDiscovery($Device.id,'1')
    $return | __TestReturn__
  }
}

function Disable-SevOneDiscovery {
param (
    #
    [parameter(Mandatory,
    ParameterSetName='Default',
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    $Device
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    $return = $Global:SevOne.core_setDeviceDiscovery($Device.id,'0')
    $return | __TestReturn__
  }
}

function Start-SevOneDiscovery {
param (
    #
    [parameter(Mandatory,
    ParameterSetName='Default',
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    $Device
  )
begin {
    Write-Verbose 'Starting operation'
    if (-not (__TestSevOneConnection__)) {
        throw 'Not connected to a SevOne instance'
      }
    Write-Verbose 'Connection verified'
    Write-Debug 'finished begin block'
  }
process {
    $return = $Global:SevOne.core_rediscoverDevice($Device.id)
    $return | __TestReturn__
  }
}

function Set-SevOnePollingInterval {}

#function Set-SevOneDevice {}

Export-ModuleMember -Function *-* 
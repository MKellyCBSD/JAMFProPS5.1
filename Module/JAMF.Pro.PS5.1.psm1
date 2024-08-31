
Function Connect-JAMF {
[CmdletBinding(DefaultParameterSetName = 'UserAuth')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UserAuth', Position = 0)]
        [String]$User,

        [Parameter(Mandatory, ParameterSetName = 'UserAuth')]
        [String]$Password,

        [Parameter(Mandatory, ParameterSetName = 'ClientAuth')]
        [String]$Clientid,

        [Parameter(Mandatory, ParameterSetName = 'ClientAuth')]
        [String]$ClientSecret,

        [Parameter(Mandatory, ParameterSetName = 'ClientAuth')]
        [Parameter(Mandatory, ParameterSetName = 'UserAuth')]
        [String]$Url
    )
    #Create a unique global variable for the JAMF tenant url.
    $Global:c085b1eadaa7452eb77bbfb4fc0444cd = $Url
   #if Credentials Provided get token via User credentials
    if($User -and $Password){
    $creds = "$User" + ":" + "$Password"                                                                  

    $base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($creds))  

    $Header = @{
        Authorization = "Basic $base64AuthInfo"
    }
    $Parameters = $null
    $Parameters = @{
        Method      = "POST"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/api/v1/auth/token"
        Headers     = $Header
    }
    $TokenResponse = Invoke-WebRequest @Parameters
    if ($($TokenResponse).StatusCode -ne 200) {
        Write-Output ""
        Write-Output "Error generating token. Status code: $($($TokenResponse).StatusCode)."
        Pause
        exit
    }
    else {
    #Create a unique global variable for the JAMF Authtoken.
      $Global:27617236caba41e1a6c0067886e2458b = $TokenResponse | ConvertFrom-Json | Select-Object -ExpandProperty "token"
    #return $TokenResponse
    Write-Output "Welcome to JAMF Pro PS5.1! 
    "
    Write-Output "Readme: https://github.com/MKellyCBSD/JAMFProPS5.1
    "
    Write-Output "Connected via user credentials using account: $User
    "
    Write-Output "API https://developer.jamf.com/jamf-pro/reference/classic-api
    "
    }       
    }
    #if Credentials Provided get token via client credentials
    if($Clientid -and $ClientSecret){

    $Headers = @{
        "Content-Type" = "application/x-www-form-urlencoded"
    }
    $bodyContent = @{
        client_id = $Clientid
        client_secret = $ClientSecret
        grant_type = "client_credentials"
    }
    $Parameters = $null
    $Parameters = @{
        Method      = "POST"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/api/oauth/token"
        Headers     = $Header
        Body        = $bodyContent
    }
    $TokenResponse = Invoke-WebRequest @Parameters
    if ($($TokenResponse).StatusCode -ne 200) {
        Write-Output ""
        Write-Output "Error generating token. Status code: $($($TokenResponse).StatusCode)."
        Pause
        exit
    }
    else {
    #Create a unique global variable for the JAMF Authtoken.
      $Global:27617236caba41e1a6c0067886e2458b = $TokenResponse | ConvertFrom-Json | Select-Object -ExpandProperty "access_token"
    #return $TokenResponse
    Write-Output "Welcome to JAMF Pro PS5.1! 
    "
    Write-Output "Readme: https://github.com/MKellyCBSD/JAMFProPS5.1
    "
    Write-Output "Connected via client credentials using client id: $ClientId
    "
    Write-Output "API https://developer.jamf.com/jamf-pro/reference/classic-api
    "
    }       
    }
        
}

Function Get-JAMFContext {
$Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/api/v1/auth"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Details = Invoke-RestMethod @Parameters
    return $Details.account


}

Function Disconnect-JAMF {
    # Set up headers
    $Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }
    $Context = Get-JAMFContext
    $Parameters = $null
    $Parameters = @{
        Method      = "POST"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/api/v1/auth/invalidate-token"
        Headers     = $Header
    }
    
    
    # Invalidate the token
    $invalidateTokenResponse = Invoke-WebRequest @Parameters
    # Check the response code and see if it was not successful (IF) or if it was successful (ELSE)
    if ($($invalidateTokenResponse).StatusCode -ne 204) {
        Write-Output ""
        Write-Output "Error invalidating token. Status code: $($($invalidateTokenResponse).StatusCode)."
        #exit
    }
    # Check the response code and see if it was not successful (IF) or if it was successful (ELSE)
    else {
        return $Context
    }
}

Function Get-JAMFMobileDevice {
[CmdletBinding(DefaultParameterSetName = 'All')]
    param(
    [Parameter(Mandatory, ParameterSetName = 'SerialNumber', Position = 0)]
    [System.String]$SerialNumber,
    [Parameter(Mandatory, ParameterSetName = 'Id')]
    [Int]$Id,
    [Parameter(Mandatory, ParameterSetName = 'DeviceName')]
    [System.String]$DeviceName,
    [Parameter(Mandatory = $false, ParameterSetName = 'All')]
    [Switch]$All = $true
)
    #$token = get-JamfAuthToken -User $User -Password $Password -Url $Url
    $Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }
    if($id){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/mobiledevices/id/$Id"
        Headers     = $Header
        ContentType = "application/json"
    }
    $mobiledevice = Invoke-RestMethod @Parameters
    return $mobiledevice.mobile_device.general
    }
   if($SerialNumber){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/mobiledevices/serialnumber/$SerialNumber"
        Headers     = $Header
        ContentType = "application/json"
    }
    $mobiledevice = Invoke-RestMethod @Parameters
    return $mobiledevice.mobile_device.general
    }
    if($DeviceName){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/mobiledevices/name/$DeviceName"
        Headers     = $Header
        ContentType = "application/json"
    }
    $mobiledevice = Invoke-RestMethod @Parameters
    return $mobiledevice.mobile_device.general
    }
      if($All){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/mobiledevices"
        Headers     = $Header
        ContentType = "application/json"
    }
    $mobiledevice = Invoke-RestMethod @Parameters
    return $mobiledevice.mobile_devices.mobile_device
    }
}

Function Get-JAMFComputer {
[CmdletBinding(DefaultParameterSetName = 'All')]
    param(
    [Parameter(Mandatory, ParameterSetName = 'SerialNumber', Position = 0)]
    [System.String]$SerialNumber,
    [Parameter(Mandatory, ParameterSetName = 'Id')]
    [Int]$Id,
    [Parameter(Mandatory, ParameterSetName = 'ComputerName')]
    [System.String]$ComputerName,
    [Parameter(Mandatory = $false, ParameterSetName = 'All')]
    [Switch]$All = $true
)

   $Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }
    if($id){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/computers/id/$id"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Computer = Invoke-RestMethod @Parameters
    return $Computer.computer.general
    }
   if($SerialNumber){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/computers/serialnumber/$SerialNumber"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Computer = Invoke-RestMethod @Parameters
    return $Computer.computer.general
    }
    if($ComputerName){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/computers/name/$ComputerName"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Computer = Invoke-RestMethod @Parameters
    return $Computer.computer.general
    }
      if($All){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/computers"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Computer = Invoke-RestMethod @Parameters
    return $Computer.computers.computer
    }
}

Function Get-JAMFDepartments {
[CmdletBinding(DefaultParameterSetName = 'All')]
    param(
    [Parameter(Mandatory, ParameterSetName = 'Id')]
    [Int]$Id,
    [Parameter(Mandatory, ParameterSetName = 'DepartmentName')]
    [System.String]$DepartmentName,
    [Parameter(Mandatory = $false, ParameterSetName = 'All')]
    [Switch]$All = $true
)
#$token = get-JamfAuthToken -User $User -Password $Password -Url $Url
    $Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }
    if($id){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/departments/id/$id"
        Headers     = $Header
        ContentType = "application/json"
    }
    $department = Invoke-RestMethod @Parameters
    return $department.department.name
    }
    if($DepartmentName){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/departments/name/$DepartmentName"
        Headers     = $Header
        ContentType = "application/json"
    }
     $department = Invoke-RestMethod @Parameters
    return $department.department.id
    }
      if($All){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/departments"
        Headers     = $Header
        ContentType = "application/json"
    }
     
    $department = Invoke-RestMethod @Parameters
    return $department.departments.department | Sort-Object name
    }
}

Function Get-JAMFMobileDevicePreStage {
[CmdletBinding(DefaultParameterSetName = 'All')]
    param(
    [Parameter(Mandatory, ParameterSetName = 'Id')]
    [Int]$Id,
    [Parameter(Mandatory, ParameterSetName = 'Scopes')]
    [Switch]$Scopes,
    [Parameter(Mandatory = $false, ParameterSetName = 'All')]
    [Switch]$All = $true
)

$Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }
if($Id){
 
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/api/v2/mobile-device-prestages/$Id"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Prestage = Invoke-RestMethod @Parameters

    return $Prestage
    }
if($Scopes){
 
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/api/v2/mobile-device-prestages/scope"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Scope = Invoke-RestMethod @Parameters

    return $Scope.serialsByPrestageId
    }

if($All){
 
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/api/v2/mobile-device-prestages?page=0&page-size=1000&sort=id%3Adesc"
        Headers     = $Header
        ContentType = "application/json"
    }
    $PreStage = Invoke-RestMethod @Parameters
    
    return $PreStage.results #| Select-Object -ExpandProperty locationInformation | Sort-Object -Property displayName
    }
}

Function Get-JAMFLocalAccount {
[CmdletBinding(DefaultParameterSetName = 'All')]
    param(
    [Parameter(Mandatory, ParameterSetName = 'Id', Position = 0)]
    [Int]$Id,
    [Parameter(Mandatory, ParameterSetName = 'UserName')]
    [System.String]$UserName,
    [Parameter(Mandatory = $false, ParameterSetName = 'All')]
    [Switch]$All = $true
)
    #$token = get-JamfAuthToken -User $User -Password $Password -Url $Url
    $Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }
    if($id){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/accounts/userid/$Id"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Account = Invoke-RestMethod @Parameters
    return $Account.account
    }
    if($UserName){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/accounts/username/$UserName"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Account = Invoke-RestMethod @Parameters
    return $Account.account
    }
      if($All){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/accounts"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Account = Invoke-RestMethod @Parameters
    return $Account.accounts.users.user
    }
}

Function Get-JAMFUser {
[CmdletBinding(DefaultParameterSetName = 'All')]
    param(
    [Parameter(Mandatory, ParameterSetName = 'Email', Position = 0)]
    [System.String]$Email,
    [Parameter(Mandatory, ParameterSetName = 'Id')]
    [Int]$Id,
    [Parameter(Mandatory, ParameterSetName = 'UserName')]
    [System.String]$UserName,
    [Parameter(Mandatory = $false, ParameterSetName = 'All')]
    [Switch]$All = $true
)
    #$token = get-JamfAuthToken -User $User -Password $Password -Url $Url
    $Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }
    if($id){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/users/id/$id"
        Headers     = $Header
        ContentType = "application/json"
    }
    $user = Invoke-RestMethod @Parameters
    return $user.user
    }
    if($Email){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/users/email/$Email"
        Headers     = $Header
        ContentType = "application/json"
    }
    $user = Invoke-RestMethod @Parameters
    return $user.users.user
    }
    if($UserName){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/users/name/$UserName"
        Headers     = $Header
        ContentType = "application/json"
    }
    $user = Invoke-RestMethod @Parameters
    return $user.user
    }
      if($All){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/users"
        Headers     = $Header
        ContentType = "application/json"
    }
    $user = Invoke-RestMethod @Parameters
    return $user.users.user
    }
}

Function Get-JAMFUserGroup {
[CmdletBinding(DefaultParameterSetName = 'All')]
    param(
    [Parameter(Mandatory = $false, ParameterSetName = 'Id', Position = 0)]
    [Int]$Id,
    [Parameter(Mandatory = $false, ParameterSetName = 'GroupName')]
    [System.String]$GroupName,
    [Parameter(Mandatory = $false, ParameterSetName = 'All')]
    [Switch]$All = $true
)
    #$token = get-JamfAuthToken -User $User -Password $Password -Url $Url
    $Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }
    if($id){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/usergroups/id/$id"
        Headers     = $Header
        ContentType = "application/json"
    }
    $usergroup = Invoke-RestMethod @Parameters
    return $usergroup.user_group
    }
    if($GroupName){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/usergroups/name/$GroupName"
        Headers     = $Header
        ContentType = "application/json"
    }
    $usergroup = Invoke-RestMethod @Parameters
    return $usergroup.user_group
    }
      if($All){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/usergroups"
        Headers     = $Header
        ContentType = "application/json"
    }
    $usergroup = Invoke-RestMethod @Parameters
    return $usergroup.user_groups.user_group    
    }
}

Function Get-JAMFMobileDeviceGroup {
[CmdletBinding(DefaultParameterSetName = 'All')]
    param(
    [Parameter(Mandatory, ParameterSetName = 'Id', Position = 0)]
    [Int]$Id,
    [Parameter(Mandatory, ParameterSetName = 'GroupName')]
    [System.String]$GroupName,
    [Parameter(Mandatory = $false, ParameterSetName = 'All')]
    [Switch]$All = $true
)
    #$token = get-JamfAuthToken -User $User -Password $Password -Url $Url
    $Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }
    if($id){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/mobiledevicegroups/id/$id"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Mobiledevicegroup = Invoke-RestMethod @Parameters
    return $Mobiledevicegroup.mobile_device_group
    }
    if($GroupName){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/mobiledevicegroups/name/$GroupName"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Mobiledevicegroup = Invoke-RestMethod @Parameters
    return $Mobiledevicegroup.mobile_device_group
    }
      if($All){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/mobiledevicegroups"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Mobiledevicegroup = Invoke-RestMethod @Parameters
    return $Mobiledevicegroup.mobile_device_groups.mobile_device_group | Sort-Object name
    }
}

Function Get-JAMFComputerGroup {
[CmdletBinding(DefaultParameterSetName = 'All')]
    param(
    [Parameter(Mandatory, ParameterSetName = 'Id', Position = 0)]
    [Int]$Id,
    [Parameter(Mandatory, ParameterSetName = 'GroupName')]
    [System.String]$GroupName,
    [Parameter(Mandatory = $false, ParameterSetName = 'All')]
    [Switch]$All = $true
)
    #$token = get-JamfAuthToken -User $User -Password $Password -Url $Url
    $Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }
    if($id){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/computergroups/id/$id"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Computergroup = Invoke-RestMethod @Parameters
    return $Computergroup.computer_group
    }
    if($GroupName){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/computergroups/name/$GroupName"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Computergroup = Invoke-RestMethod @Parameters
    return $Computergroup.computer_group
    }
      if($All){
    $Parameters = $null
    $Parameters = @{
        Method      = "GET"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/computergroups"
        Headers     = $Header
        ContentType = "application/json"
    }
    $Computergroup = Invoke-RestMethod @Parameters
    return $Computergroup.computer_groups.computer_group
    }
}

Function Update-JAMFMobileDevice {
[CmdletBinding(DefaultParameterSetName = 'SerialNumber')]
    param(
    [Parameter(Mandatory, ParameterSetName = 'SerialNumber', Position = 0)]
    $SerialNumber,
    [Parameter(Mandatory, ParameterSetName = 'Id')]
    [Int]$Id,
    [Parameter(Mandatory, ParameterSetName = 'DeviceName')]
    $CurrentDeviceName,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'DeviceName')]
    $Username,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'DeviceName')]
    $Fullname,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'DeviceName')]
    $EmailAddress,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'DeviceName')]
    $Position,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'DeviceName')]
    $PhoneNumber,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'DeviceName')]
    $Department,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'DeviceName')]
    $Building,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'DeviceName')]
    $Room,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'DeviceName')]
    $NewDeviceName
)
    $Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }
    #build XML
    if($NewDeviceName){
    [String]$NewDeviceNameinfo = "<name>$NewDeviceName</name>"
    }
    if($Username){
    [String]$Usernameinfo = "<username>$Username</username>"}
    if($Fullname){
    [String]$FullnameInfo = "<real_name>$Fullname</real_name>"
    }
    if($EmailAddress){
    [String]$EmailAddressinfo = "<email_address>$EmailAddress</email_address>"
    }
    if($Position){
    [String]$Positioninfo = "<position>$Position</position>"
    }
    if($PhoneNumber){
    [String]$PhoneNumberinfo = "<phone>$PhoneNumber</phone>"
    }
    if($Department){
    [String]$Departmentinfo = "<department>$Department</department>"
    }
    if($building){
    [String]$Buildinginfo = "<building>$building</building>"
    }
    if($Room){
    [String]$Roominfo = "<room>$Room</room>"
    }

    [string]$GeneralInfo = "<general>
    $NewDeviceNameinfo    
	</general>"

    [String]$Locationinfo = "<location>
		$Usernameinfo
		$FullnameInfo
		$EmailAddressinfo
		$Positioninfo 
		$PhoneNumberinfo
		$Departmentinfo
		$Buildinginfo
		$Roominfo
	</location>"

    [xml]$MobileDeviceinfo = "<mobile_device>
	$GeneralInfo
	$Locationinfo
    </mobile_device>"

    if($id){
    $Parameters = $null
    $Parameters = @{
        Method      = "PUT"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/mobiledevices/id/$Id"
        Headers     = $Header
        Body        = $MobileDeviceinfo
        ContentType = 'application/xml'
    }
    $mobiledevice = Invoke-RestMethod @Parameters
    return $mobiledevice.mobile_device
    }
   if($SerialNumber){
    $Parameters = $null
    $Parameters = @{
        Method      = "PUT"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/mobiledevices/serialnumber/$SerialNumber"
        Headers     = $Header
        Body        = $MobileDeviceinfo
        ContentType = 'application/xml'
    }
    $mobiledevice = Invoke-RestMethod @Parameters
    #return $mobiledevice.mobile_device.general
    }
    if($CurrentDeviceName){
    $Parameters = $null
    $Parameters = @{
        Method      = "Put"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/mobiledevices/name/$CurrentDeviceName"
        Headers     = $Header
        Body        = $MobileDeviceinfo
        ContentType = 'application/xml'
    }
    $mobiledevice = Invoke-RestMethod @Parameters
    #return $mobiledevice.mobile_device.general
    }
}

Function Update-JAMFComputer {
[CmdletBinding(DefaultParameterSetName = 'SerialNumber')]
    param(
    [Parameter(Mandatory, ParameterSetName = 'SerialNumber', Position = 0)]
    $SerialNumber,
    [Parameter(Mandatory, ParameterSetName = 'Id')]
    [Int]$Id,
    [Parameter(Mandatory, ParameterSetName = 'ComputerName')]
    $CurrentComputerName,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'ComputerName')]
    $Username,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'ComputerName')]
    $Fullname,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'ComputerName')]
    $EmailAddress,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'ComputerName')]
    $Position,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'ComputerName')]
    $PhoneNumber,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'ComputerName')]
    $Department,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'ComputerName')]
    $Building,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'ComputerName')]
    $Room,
    [Parameter(Mandatory = $false, ParameterSetName = 'SerialNumber')]
    [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
    [Parameter(Mandatory = $false, ParameterSetName = 'ComputerName')]
    $NewDeviceName
)
    
    $Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }
    #build XML
    if($NewDeviceName){
    [String]$NewDeviceNameinfo = "<name>$NewDeviceName</name>"
    }
    if($Username){
    [String]$Usernameinfo = "<username>$Username</username>"}
    if($Fullname){
    [String]$FullnameInfo = "<real_name>$Fullname</real_name>"
    }
    if($EmailAddress){
    [String]$EmailAddressinfo = "<email_address>$EmailAddress</email_address>"
    }
    if($Position){
    [String]$Positioninfo = "<position>$Position</position>"
    }
    if($PhoneNumber){
    [String]$PhoneNumberinfo = "<phone>$PhoneNumber</phone>"
    }
    if($Department){
    [String]$Departmentinfo = "<department>$Department</department>"
    }
    if($building){
    [String]$Buildinginfo = "<building>$building</building>"
    }
    if($Room){
    [String]$Roominfo = "<room>$Room</room>"
    }

    [string]$GeneralInfo = "<general>
    $NewDeviceNameinfo    
	</general>"

    [String]$Locationinfo = "<location>
		$Usernameinfo
		$FullnameInfo
		$EmailAddressinfo
		$Positioninfo 
		$PhoneNumberinfo
		$Departmentinfo
		$Buildinginfo
		$Roominfo
	</location>"

    [xml]$MobileDeviceinfo = "<computer>
	$GeneralInfo
	$Locationinfo
    </computer>"

    if($id){
    $Parameters = $null
    $Parameters = @{
        Method      = "PUT"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/computers/id/$id"
        Headers     = $Header
        Body        = $UserLocationinfo
        ContentType = 'application/xml'
    }
    $mobiledevice = Invoke-RestMethod @Parameters
    #return $mobiledevice.mobile_device.general
    }
   if($SerialNumber){
    $Parameters = $null
    $Parameters = @{
        Method      = "PUT"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/computers/serialnumber/$SerialNumber"
        Headers     = $Header
        Body        = $UserLocationinfo 
        ContentType = 'application/xml'
    }
    $mobiledevice = Invoke-RestMethod @Parameters
    #return $mobiledevice.mobile_device.general
    }
    if($ComputerName){
    $Parameters = $null
    $Parameters = @{
        Method      = "Put"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/JSSResource/computers/name/$ComputerName"
        Headers     = $Header
        Body        = $UserLocationinfo
        ContentType = 'application/xml'
    }
    $mobiledevice = Invoke-RestMethod @Parameters
    #return $mobiledevice.mobile_device.general
    }
}

Function Set-JAMFMobileDevicePreStage {
[CmdletBinding(DefaultParameterSetName = 'SingleAdd')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'SingleAdd', Position = 0)]
        [Parameter(Mandatory, ParameterSetName = 'SingleRemove')]
        $SerialNumber,

        [Parameter(Mandatory, ParameterSetName = 'SingleAdd')]
        [Parameter(Mandatory, ParameterSetName = 'BulkAdd')]
        [Parameter(Mandatory, ParameterSetName = 'BulkRemove')]
        [Parameter(Mandatory, ParameterSetName = 'SingleRemove')]
        $PreStageId,

        [Parameter(Mandatory, ParameterSetName = 'BulkAdd')]
        [Parameter(Mandatory, ParameterSetName = 'BulkRemove')]
        $SerialNumbersCSVPath,


        [Parameter(Mandatory, ParameterSetName = 'SingleAdd')]
        [Parameter(Mandatory, ParameterSetName = 'BulkAdd')]
        [Switch]$Add,

        [Parameter(Mandatory, ParameterSetName = 'BulkRemove')]
        [Parameter(Mandatory, ParameterSetName = 'SingleRemove')]
        [Switch]$Remove

    )
$Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }

if($Remove){
$PreStage = Get-JAMFMobileDevicePreStage -Id $PreStageId
$PreStageVersonLock = $PreStage.versionLock
    if($SerialNumbersCSVPath){
    $SerialNumbers = (Import-Csv -Path $SerialNumbersCSVPath).SerialNumbers
    $Data = new-object object
    $Data | Add-Member -membertype noteproperty -name serialNumbers -Value $SerialNumbers
    $Data | Add-Member -membertype noteproperty -name versionLock -Value $PreStageVersonLock
    $bodyContent = $Data | ConvertTo-Json -Compress
    #$SerialNumbers.GetType();
    }else{
        $bodyContent = @"
    {
    "serialNumbers": [
      "$SerialNumber"
    ],
    "versionLock": $PreStageVersonLock
    }
"@
    }
    $Parameters = $null
    $Parameters = @{
        Method      = "Post"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/api/v2/mobile-device-prestages/$PrestageId/scope/delete-multiple"
        Headers     = $Header
        Body        = $bodyContent
        ContentType = "application/json"
    }
    $SetPreStage = Invoke-RestMethod @Parameters
    return $SetPreStage
    }
   
if($Add){
$PreStage = Get-JAMFMobileDevicePreStage -Id $PreStageId
$PreStageVersonLock = $PreStage.versionLock
    if($SerialNumbersCSVPath){
    $SerialNumbers = (Import-Csv -Path $SerialNumbersCSVPath).SerialNumbers
    $Data = new-object object
    $Data | Add-Member -membertype noteproperty -name serialNumbers -Value $SerialNumbers
    $Data | Add-Member -membertype noteproperty -name versionLock -Value $PreStageVersonLock
    $bodyContent = $Data | ConvertTo-Json -Compress
    #$SerialNumbers.GetType();
    }else{
        $bodyContent = @"
    {
    "serialNumbers": [
      "$SerialNumber"
    ],
    "versionLock": $PreStageVersonLock
    }
"@
    }
    $Parameters = $null
    $Parameters = @{
        Method      = "Post"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/api/v2/mobile-device-prestages/$PrestageId/scope"
        Headers     = $header
        Body        = $bodyContent
        ContentType = "application/json"
    }
    $SetPreStage = Invoke-RestMethod @Parameters
    return $SetPreStage
}
}

Function Set-JAMFComputerPreStage {
[CmdletBinding(DefaultParameterSetName = 'SingleAdd')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'SingleAdd', Position = 0)]
        [Parameter(Mandatory, ParameterSetName = 'SingleRemove')]
        $SerialNumber,

        [Parameter(Mandatory, ParameterSetName = 'SingleAdd')]
        [Parameter(Mandatory, ParameterSetName = 'BulkAdd')]
        [Parameter(Mandatory, ParameterSetName = 'BulkRemove')]
        [Parameter(Mandatory, ParameterSetName = 'SingleRemove')]
        $PreStageId,

        [Parameter(Mandatory, ParameterSetName = 'BulkAdd')]
        [Parameter(Mandatory, ParameterSetName = 'BulkRemove')]
        $SerialNumbersCSVPath,


        [Parameter(Mandatory, ParameterSetName = 'SingleAdd')]
        [Parameter(Mandatory, ParameterSetName = 'BulkAdd')]
        [Switch]$Add,

        [Parameter(Mandatory, ParameterSetName = 'BulkRemove')]
        [Parameter(Mandatory, ParameterSetName = 'SingleRemove')]
        [Switch]$Remove

    )
$Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }

if($Remove){
$PreStage = Get-JAMFMobileDevicePreStage -Id $PreStageId
$PreStageVersonLock = $PreStage.versionLock
    if($SerialNumbersCSVPath){
    $SerialNumbers = (Import-Csv -Path $SerialNumbersCSVPath).SerialNumbers
    $Data = new-object object
    $Data | Add-Member -membertype noteproperty -name serialNumbers -Value $SerialNumbers
    $Data | Add-Member -membertype noteproperty -name versionLock -Value $PreStageVersonLock
    $bodyContent = $Data | ConvertTo-Json -Compress
    #$SerialNumbers.GetType();
    }else{
        $bodyContent = @"
    {
    "serialNumbers": [
      "$SerialNumber"
    ],
    "versionLock": $PreStageVersonLock
    }
"@
    }
    $Parameters = $null
    $Parameters = @{
        Method      = "Post"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/api/v2/computer-prestages/$PrestageId/scope/delete-multiple"
        Headers     = $Header
        Body        = $bodyContent
        ContentType = "application/json"
    }
    $SetPreStage = Invoke-RestMethod @Parameters
    return $SetPreStage
    }
   
if($Add){
$PreStage = Get-JAMFMobileDevicePreStage -Id $PreStageId
$PreStageVersonLock = $PreStage.versionLock
    if($SerialNumbersCSVPath){
    $SerialNumbers = (Import-Csv -Path $SerialNumbersCSVPath).SerialNumbers
    $Data = new-object object
    $Data | Add-Member -membertype noteproperty -name serialNumbers -Value $SerialNumbers
    $Data | Add-Member -membertype noteproperty -name versionLock -Value $PreStageVersonLock
    $bodyContent = $Data | ConvertTo-Json -Compress
    #$SerialNumbers.GetType();
    }else{
        $bodyContent = @"
    {
    "serialNumbers": [
      "$SerialNumber"
    ],
    "versionLock": $PreStageVersonLock
    }
"@
    }
    $Parameters = $null
    $Parameters = @{
        Method      = "Post"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/api/v2/computer-prestages/$PrestageId/scope"
        Headers     = $header
        Body        = $bodyContent
        ContentType = "application/json"
    }
    $SetPreStage = Invoke-RestMethod @Parameters
    return $SetPreStage
}
}

Function Create-JAMFBuilding {
    param(
    [Parameter(Mandatory)]
    $BuildingName
)
$Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }

$bodyContent = @"
{
  "name": "$BuildingName"
}
"@
  $Parameters = $null
    $Parameters = @{
        Method      = "Post"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/api/v1/buildings"
        Headers     = $header
        Body        = $bodyContent
        ContentType = "application/json"
    }
    $JAMFBuilding = Invoke-RestMethod @Parameters
    return $JAMFBuilding 
    }

Function Get-JAMFBuilding {
[CmdletBinding(DefaultParameterSetName = 'All')]
    param(
    [Parameter(Mandatory, ParameterSetName = 'BuildingId', Position = 0)]
    [Int]$BuildingId,
    [Parameter(Mandatory = $false, ParameterSetName = 'All')]
    [Switch]$All = $true
)
    $Header = @{
        Authorization = "Bearer $27617236caba41e1a6c0067886e2458b"
    }
    if($BuildingId){
     $Parameters = $null
    $Parameters = @{
        Method      = "Get"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/api/v1/buildings/$BuildingId"
        Headers     = $header
        ContentType = "application/json"
    }
    $JAMFBuilding = Invoke-RestMethod @Parameters
    return $JAMFBuilding 
    }
    if($All){
     $Parameters = $null
    $Parameters = @{
        Method      = "Get"
        Uri         = "$c085b1eadaa7452eb77bbfb4fc0444cd/api/v1/buildings"
        Headers     = $header
        ContentType = "application/json"
    }
    $JAMFBuilding = Invoke-RestMethod @Parameters
    return $JAMFBuilding.results | Sort-Object name
    }
    }

Export-ModuleMember -Function '*'

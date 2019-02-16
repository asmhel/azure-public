configuration ADFSserver
{
    param
    (
      
        [Parameter(Mandatory)]
        [String]$DomainName,
 
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,
 
        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
    )
 
    Import-DscResource -ModuleName xComputerManagement,xActiveDirectory
 
    Node localhost
    {
        WindowsFeature ADFSInstall
        {
            Ensure = "Present"
            Name = "ADFS-Federation"
        } 
        WindowsFeature ADPS
        {
            Name = "RSAT-AD-PowerShell"
            Ensure = "Present"
 
        }
        xWaitForADDomain DscForestWait
        {
            DomainName = $DomainName
            DomainUserCredential= $Admincreds
            RetryCount = $RetryCount
            RetryIntervalSec = $RetryIntervalSec
            DependsOn = "[WindowsFeature]ADPS"     
        }
        xComputer DomainJoin
        {
            Name = $env:COMPUTERNAME
            DomainName = $DomainName
            Credential = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
 
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }
    }    
}

configuration WAPserver
{
    param
    (
 
        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
    )
 
    Import-DscResource -ModuleName xComputerManagement
 
    Node localhost
    {
        WindowsFeature ADFSInstall
        {
            Ensure = "Present"
            Name = "Web-Application-Proxy"
        } 
 
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }
    }    
}
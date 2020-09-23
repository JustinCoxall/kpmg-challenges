<#
  Basic PoshUD page running on an AWS EC2 instance
  
  Restarts every hour as I don't have a license

#>

if(![bool](get-module -ListAvailable | ? {$_.Name -like "universaldashboard*"})){
    Install-PackageProvider -Name NuGet -Scope AllUsers -Force
    Find-Module universaldashboard.community | Install-Module -Scope AllUsers -Force -Confirm:$false
}

Import-Module universaldashboard.community



$Theme = Get-UDTheme -Name "Azure"

$Page1 = New-UDPage -Name 'Home' -Content {
    New-UDHeading -Size 3 -Content { "Challenge 2" } -Color white
    
    New-UDMuTypography -Text "Summary" -IsParagraph
    New-UDMuTypography -Text  "We need to write code that will query the meta data of an instance within aws and provide a json formatted output. The choice of language and implementation is up to you." -IsParagraph
    New-UDMuTypography -Text "" -IsParagraph
    New-UDMuTypography -Text "" -IsParagraph
    New-UDMuTypography -Text "Bonus Points" -IsParagraph
    New-UDMuTypography -Text "The code allows for a particular data key to be retrieved individually" -IsParagraph

    New-UDHeading -Size 3 -Content { "How To Use" } -Color white
    New-UDMuTypography -Text "" -IsParagraph
    New-UDMuTypography -Text "If Everything is checked then all MetaData will be pulled" -IsParagraph
    New-UDMuTypography -Text "Specific Key Example: block-device-mapping/ami" -IsParagraph

    New-UDInput -Title "Get-KPMGMetaAsJson" -Content {
        New-UDInputField -Type 'checkbox' -Name "Everything" 
        New-UDInputField -Type 'textbox' -Name "SpecificKey" 
        
    } -Endpoint {
        param($Everything,$SpecificKey)
        Import-Module "C:\KPMG\kpmg.psm1"
        if($Everything){
            $Result = Get-KPMGMetaAsJson -Everything
        } Else {
            $Result = Get-KPMGMetaAsJson -SpecificKey $SpecificKey
        }
        Show-UDModal -Content {
            New-UDHeading -Text "$Result"
        }
    }
    New-UDLink -Text "Go back to the other challenges hosted in Azure" -Url "http://kpmg.mapledesk.com/Challenge-2"
    
}


$Dashboard = New-UDDashboard -Pages $page1 -Title 'KPMG Challenge 2 - Justin Coxall' -Theme $Theme


while($true){
    Get-UDDashboard | Stop-UDDashboard
    Start-UDDashboard -Port 80 -Name "KPMG" -Dashboard $Dashboard
    Get-UDDashboard
    Start-Sleep -Seconds 3599
}

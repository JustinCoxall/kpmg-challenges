<#
Basic PoshUD site using community edition for proof of concept

Confirmed working in PowerShell 5.1

Removed function keys from this

#>



if(![bool](get-module -ListAvailable | ? {$_.Name -like "universaldashboard*"})){
    Install-PackageProvider -Name NuGet -Scope AllUsers -Force
    Find-Module universaldashboard.community | Install-Module -Scope AllUsers -Force -Confirm:$false
}

Import-Module UniversalDashboard.community 




$Theme = Get-UDTheme -Name "Azure"

$Page1 = New-UDPage -Name 'Home' -Content {
    New-UDHeading -Size 3 -Content { "Welcome" } -Color white
    New-UDMuTypography -IsParagraph -Text "Thank you for checking out my challenges"
    New-UDMuTypography -IsParagraph -Text "Please use the sandwich menu bar to view the challenges" 
    New-UDMuTypography -IsParagraph -Text "Apologies for any slowness - all resources are basically on the lowest spec possible to save money :)" 
    New-UDMuTypography -IsParagraph -Text "Webpage services restart every hour as this not licensed" 
    New-UDLink -Text "GitHub link with all code - except for my keys" -Url "https://github.com/JustinCoxall/kpmg-challenges"
    New-UDMuTypography -IsParagraph -text ""
    New-UDMuTypography -IsParagraph -text ""
    New-UDLink -Text "LinkedIn" -Url "https://www.linkedin.com/in/justin-coxall-a2907a127/"
    
}

$Page2 = New-UDPage -Name 'Challenge 1' -Content {
    New-UDHeading -Size 3 -Content { "Challenge 1" } -Color white
    
    New-UDMuTypography -IsParagraph -Text "Challenge #1" 
    New-UDMuTypography -IsParagraph -Text "A 3 tier environment is a common setup. Use a tool of your choosing/familiarity create these resources. Please remember we will not be judged on the outcome but more focusing on the approach, style and reproducibility."

    New-UDMuTypography -Text "" -IsParagraph
    New-UDMuTypography -Text "" -IsParagraph
    New-UDMuTypography -Text "" -IsParagraph
    New-UDMuTypography -Text "Welcome to Challenge 1. Just basic 3 tier webapp" -IsParagraph
    New-UDMuTypography -Text "" -IsParagraph
    New-UDMuTypography -Text "Tier 1 - Frontend Web - PowerShell Universal Dashboard - I have been playing with it recently and can rapidly build decent enough looking sites with it"
    New-UDMuTypography -Text "" -IsParagraph
    New-UDMuTypography -Text "Tier 2 - Azure Functions - https://kpmg-jc.azurewebsites.net - sending API calls here to perform Challenge 3 and pull data from the Azure table to view on this page"
    New-UDMuTypography -Text "" -IsParagraph
    New-UDMuTypography -Text "Tier 3 - Azure Table/Cosmos DB - Simple Table storage, data from Challenge 3 gets logged here"
    New-UDMuTypography -Text "" -IsParagraph

    New-UDGrid -Title "Data from Challenge 3" -Endpoint {
        $code = 'Insert function code'
        $Rest = Invoke-RestMethod -Uri "https://kpmg-jc.azurewebsites.net/api/HttpTrigger1?code=$code"
        $Rest | sort -Property PartitionKey | select -Property Object,Key,Value,Time | Out-UDGridData
    }

}
$Page3 = New-UDPage -Name 'Challenge 2' -Content {
    New-UDHeading -Size 3 -Content { "Challenge 2" } -Color white
    New-UDMuTypography -Text "Challenge #2" -IsParagraph
    New-UDMuTypography -Text "Summary" -IsParagraph
    New-UDMuTypography -Text  "We need to write code that will query the meta data of an instance within AWS and provide a JSON formatted output. The choice of language and implementation is up to you." -IsParagraph
    New-UDMuTypography -Text "" -IsParagraph
    New-UDMuTypography -Text "" -IsParagraph
    New-UDMuTypography -Text "Bonus Points" -IsParagraph
    New-UDMuTypography -Text "The code allows for a particular data key to be retrieved individually" -IsParagraph
    New-UDLink -Text "Running live in AWS - just click here to go!" -Url "http://aws.mapledesk.com/"
    

}

$Page4 = New-UDPage -Name 'Challenge 3' -Content {
    New-UDHeading -Size 3 -Content { "Challenge 3" } -Color white
    New-UDMuTypography -Text 'Challenge #3 We have a nested object, we would like a function that you pass in the object and a key and get back the value. How this is implemented is up to you.'
    New-UDMuTypography -Text 'Example Inputs' -IsParagraph
    New-UDMuTypography -Text 'object = {"a":{"b":{"c":"d"}}}' -IsParagraph
    New-UDMuTypography -Text 'key = a/b/c' -IsParagraph

    New-UDMuTypography -Text 'object = {"x":{"y":{"z":"a"}}}' -IsParagraph
    New-UDMuTypography -Text 'key = x/y/z' -IsParagraph
    New-UDMuTypography -Text 'value = a' -IsParagraph
    
    New-UDMuTypography -Text '' -IsParagraph
    New-UDMuTypography -Text '' -IsParagraph
    New-UDMuTypography -Text '' -IsParagraph
    New-UDMuTypography -Text "Make sure Object and Key follow correct syntax, no error checking here :)"
    New-UDInput -Title "Get-KPMGValue" -Content {
        New-UDInputField -Type 'textbox' -Name "Object" 
        New-UDInputField -Type 'textbox' -Name "Key" 
        
    } -Endpoint {
        param($object,$key)
        $code = 'Insert function code'
        $URI = "https://kpmg-jc.azurewebsites.net/api/HttpTrigger2?code=$Code&TheKey=$key&TheObject=$object" 
        $Message = Invoke-RestMethod -Method POST -Uri $uri
        Show-UDModal -Content {
            New-UDHeading -Text "$message"
        }
    }

}

$Dashboard = New-UDDashboard -Pages @($page1,$page2,$page3,$page4) -Title 'KPMG Challenges - Justin Coxall' -Theme $Theme


while($true){
    Get-UDDashboard | Stop-UDDashboard
    Start-UDDashboard -Port 80 -Name "KPMG" -Dashboard $Dashboard
    Get-UDDashboard
    Start-Sleep -Seconds 3599
}

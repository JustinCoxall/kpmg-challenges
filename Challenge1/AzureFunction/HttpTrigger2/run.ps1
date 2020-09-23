using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata, $inputtable)

write-host $inputtable

Function New-KSGUID {
    Write-Output ([Guid]::NewGuid().ToString())
}#End of function Get-KSGUID

Function Get-KPMGValue{
    param( $obj, $key)
    Process{
        $hash = $obj | ConvertFrom-Json
        $key.split('/') | % {
            if($hash.($_)){
                $hash = $hash.($_)
            } Else {
                write-error "Invalid key, failed to find - $_"
            }
        }
        if($hash.GetType().name -eq "string"){
            $value = $hash
        } Else {
            $value = ($hash | gm | ? {$_.membertype -eq "NoteProperty"}).name
        }
        Write-Output $value
    }
}

$TheObject = $Request.Query.TheObject
$TheKey = $Request.Query.TheKey

$value = Get-KPMGValue -obj $TheObject -key $TheKey

$Runs = [INT](($inputtable | sort {[int]$_.PartitionKey} -Descending | select -first 1 | select -property partitionKey).PartitionKey) + 1

$Data = [PSCUSTOMOBJECT]@{
    partitionKey = $runs
    rowKey = New-KSGUID
    Key = $TheKey
    Object = $TheObject
    Value = $value
    Time = get-date -Format "yyyy-MM-dd HH:mm:ss"
}

Push-OutputBinding -Name outpuTtable -Value $Data

$body = "Object:$TheObject Key:$TheKey Value:$value Runs: $Runs"


Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})

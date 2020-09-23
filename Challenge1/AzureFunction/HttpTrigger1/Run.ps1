using namespace System.Net

param($Request, $TriggerMetadata,$inputtable)




Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $inputtable
})

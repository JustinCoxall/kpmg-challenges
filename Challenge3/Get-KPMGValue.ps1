
<#
Challenge #3
We have a nested object, we would like a function that you pass in the object and a key and get back the value. How this is implemented is up to you.

Example Inputs
object = {"a":{"b":{"c":"d"}}}
key = a/b/c

object = {"x":{"y":{"z":"a"}}}
key = x/y/z
value = a

Tested and confirmed working on PowerShell 5.1 and 7.0.3

Example Usage

$key = 'x/y/z'
$obj = '{"x":{"y":{"z":"a"}}}'

Get-KPMGValue -obj $obj -key $key

#>

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



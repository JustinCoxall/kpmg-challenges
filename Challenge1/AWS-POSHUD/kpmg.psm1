#Metadata function
Function Get-KPMGMetaAsJson {
    Param(
    [Switch]$Everything
    ,
    [String]$SpecificKey = $NULL
    )
    Begin{
        #Recursive Function to check if there are additional URIs below the specified one
        function Get-KPMGMetaURIs ($MetaURI) {
            Try {
                $RestMeth = (Invoke-RestMethod -uri $MetaURI).split()
                foreach($entry in $RestMeth){
                    If([string]$entry -like "*/"){
                        Get-KPMGMetaURIs -MetaURI ($MetaURI + $entry)
                    } Else {
                        Try{
                            $blank = Invoke-RestMethod -uri ($MetaURI + $entry)
                            ($MetaURI + $entry)
                        } Catch {
                            Try {
                               $blank = Invoke-RestMethod -uri ($MetaURI + '/' + $entry)
                                $MetaURI + '/' + $entry
                            } Catch {
                               $MetaURI
                            }
                        }
                    }
                }
            } Catch {
                Get-KPMGMetaURIs -MetaURI ($MetaURI + '/' + $entry)
            }  
        }
    }#End of Begin
    Process {
        if($Everything){
            $uri = 'http://169.254.169.254/latest/meta-data/'
            $allURIs = Get-KPMGMetaURIs -MetaURI $uri
            $array = @()

            #Extract values from all available URIs and save to an array of objects
            foreach($uri in $allURIs){
                $rest = Invoke-RestMethod -Uri $uri
                $array += [PSCUSTOMOBJECT]@{
                    URI = $uri
                    Value = $Rest
                }
            }
            
            #Create a hashtable and go through the array of objects and place them in the hashtable following the required structure
            $Hashtable = @{}
            foreach($test in $array){
                $string = ""
                $Structure = ($test.uri).replace('http://169.254.169.254/latest/','')
                If($Structure.Substring($Structure.Length -1) -eq '/'){$Structure = $Structure -replace ".$"}
                $Count = $Structure.Split('/').count
                $i = 1
                #Do a foreach on the object in the array
                $Structure.Split('/') | % {
                    $string += '"' + ("$_") + '"'
                    $text = "`$hashtable.$string"
                    #Use invoke-expression as the hashtable properties are variable, use mess of if/else to check through all possibilites
                    if((Invoke-Expression $text) -eq $NULL){
                        If($i -eq $count){
                            if(($test.Value.GetType()).name -eq "String"){
                                ($test.Value).Split() | % {
                                    $value = $_
                                    if($value -like "*/"){
                                        $value = $value -replace ".$"
                                         Invoke-Expression ($text + '.' + '"' + "$($value)" + '"' + "= @{}")
                                    } Else {
                                        Invoke-Expression ($text + ' = ''' + "$($value)" + '''')
                                    }
                                }
                            } Else {
                                Invoke-Expression ($text + ' = ''' + "$($test.value)" + '''')
                            }
                        } Else {
                            Invoke-Expression ($text + "= @{}")
                        }
                    }
                    $i++
                    $string += '.'
                }
            }
            #convert hashtable to JSON and output
            $json = $Hashtable | ConvertTo-Json -Depth 10
            Write-Output $json
        } Else {
            if($SpecificKey -eq $NULL){
                Write-error "Please enter a SpecificKey"
                break
            } Else {
                $URI = 'http://169.254.169.254/latest/meta-data/' + $SpecificKey
                Try{
                    $rest = Invoke-RestMethod -Uri $uri
                } Catch {
                    Write-Error "Invalid key attempted - $SpecificKey - Please try again using a proper key. Ex. Get-KPMGMetaAsJson -SpecificKey identity-credentials/ec2"
                    break
                }
                If($SpecificKey.Substring($SpecificKey.Length -1) -eq '/'){$SpecificKey = $SpecificKey -replace ".$"}
                $Hashtable = @{}
                $i = 1
                $string = ""
                $Count = $SpecificKey.Split('/').Count
                $SpecificKey.Split('/') | % {
                    $string += '"' + ("$_") + '"'
                    $text = "`$hashtable.$string"
                    if((Invoke-Expression $text) -eq $NULL){
                        If($i -eq $count){
                            if(($rest.GetType()).name -eq "String"){
                                Invoke-Expression ($text + "= @()")
                                $Rest.Split() | % {
                                    $value = $_
                                    Invoke-Expression ($text + " += `$value")
                                }
                            } Else {
                                Invoke-Expression ($text + ' = ''' + "$($rest)" + '''')
                            }
                        } Else {
                            Invoke-Expression ($text + "= @{}")
                        }
                    }
                    $i++
                    $string += '.'
                }
                $json = $Hashtable | ConvertTo-Json -Depth 10
                Write-Output $json
            }
        }
    }#End of Process
}#End of Function Get-KPMGMetaAsJson

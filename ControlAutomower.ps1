########################################################
# Name: ControlAutomower.ps1                              
# Creator: Michael Seidl aka Techguy                    
# CreationDate: 23.06.2020
# LastModified: 23.06.2020
# Version: 1.0
# Doc: 
# PSVersion tested:
#
# Version 1.0 - RTM
########################################################
#
# www.techguy.at                                        
# www.facebook.com/TechguyAT                            
# www.twitter.com/TechguyAT                             
# michael@techguy.at 
########################################################

# PowerShell Self Service Web Portal at www.au2mator.com/PowerShell

#region Variables
$APIKey = "00000000000000000000000000"
$APISecret = "00000000000000000000000000"

$Username = "your Mail"
$Password = "your Password"

$OAuthURL = "https://api.authentication.husqvarnagroup.dev/v1/oauth2/token"
#endregion Variables


#region OAuthToken
$Body = @{
    'username'   = $Username
    'client_id'  = $APIKey
    'grant_type' = 'password'
    'password'   = $Password
}

$params = @{
    ContentType = 'application/x-www-form-urlencoded'
    Headers     = @{'accept' = 'application/json' }
    Body        = $Body
    Method      = 'Post'
    URI         = $OAuthURL
}

$token = Invoke-RestMethod @params
#endregion OAuthToken


#region GetMowerID
$Uri = 'https://api.amc.husqvarna.dev/v1/mowers'
$params2 = @{
  
    Headers = @{
        'accept'                 = "application/vnd.api+json"
        'authorization'          = "Bearer $($token.access_token)"
        'X-Api-Key'              = "$Apikey"
        'Authorization-Provider' = 'husqvarna'
    }
    Method  = 'Get'
    URI     = $Uri
}
$Result = Invoke-RestMethod @params2

$MowerID=$Result.data.id
#endregion GetMowerID


Function Send-MowerCommand {

    Param(
        [ValidateSet("Start", "Pause", "Park", "ResumeSchedule","ParkUntilNextSchedule","ParkUntilFurtherNotice")]
        [parameter(Mandatory = $true)]
        [String]
        $Command,
        
        [parameter(Mandatory = $false)]
        [int]
        $Duration,


        [parameter(Mandatory = $true)]
        [string]
        $MowerID
    )


    $Uri = "https://api.amc.husqvarna.dev/v1/mowers/$MowerID/actions"

    $params = @{
  
        Headers = @{
            'accept'                 = "*/*"
            'authorization'          = "Bearer $($token.access_token)"
            'X-Api-Key'              = "$Apikey"
            'Authorization-Provider' = 'husqvarna'
            'Content-Type'           = 'application/vnd.api+json'
        }
        Method  = 'Post'
        URI     = $Uri
 
        <# $Body = @{
    'data' = @{
        'type' = "Start"
        'attributes'  = @{
          'name' = $RunbookName
        }
}
#>

     
    }



    if ($Command -eq "Pause") {
        $Body = @{
            'data' = @{
                'type' = 'Pause'
            }
        } | ConvertTo-Json
    }

    if ($Command -eq "ResumeSchedule") {
        $Body = @{
            'data' = @{
                'type' = 'ResumeSchedule'
            }
        } | ConvertTo-Json
    }

    if ($Command -eq "Start") {
        $Body = @{
            'data' = @{
                'type' = 'Start'
                'attributes'  = @{
                    'duration' = $Duration
                  }
            }
        } | ConvertTo-Json
    }

    if ($Command -eq "Park") {
        $Body = @{
            'data' = @{
                'type' = 'Park'
                'attributes'  = @{
                    'duration' = $Duration
                  }
            }
        } | ConvertTo-Json
    }


    if ($Command -eq "ParkUntilNextSchedule") {
        $Body = @{
            'data' = @{
                'type' = 'ParkUntilNextSchedule'
            }
        } | ConvertTo-Json
    }

    if ($Command -eq "ParkUntilFurtherNotice") {
        $Body = @{
            'data' = @{
                'type' = 'ParkUntilFurtherNotice'
            }
        } | ConvertTo-Json
    }



    Invoke-RestMethod @params -body $Body

}





# Pause Mower
Send-MowerCommand -Command Pause -MowerID $MowerID

# Staert Mower with Schedule
Send-MowerCommand -Command ResumeSchedule -MowerID $MowerID

#Start Mower for 10 Minutes, outside Shedule
Send-MowerCommand -Command Start -MowerID $MowerID -Duration 10

#Park Mower for 10 Minutes
Send-MowerCommand -Command Park -MowerID $MowerID -Duration 10


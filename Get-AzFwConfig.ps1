#region Credits
# Author: Federico Lillacci
# GitHub: https://github.com/tsmagnum
# Version: 1.0
# Date: 12/12/2022
#endregion

#region Azure Info
#Fill these variables - all of these are mandatory!
$SubscriptionId = "mySubId"
$TenantId = "myTenantId"
$ClientId = "myAppClientId"
$ClientSecret = "myAppSecretId"
$resGroupName = "rg-containing-fw"
$fwName = "myFwName"
$fwPolicyName ="myFwPolicyName"
#endregion

#Getting the date to name the configuration file
$today = (Get-Date -Format 'ddMMyyyy-hhmmss')

#Preparing the access token request
$Resource = "https://management.core.windows.net/"
$RequestAccessTokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/token"
$body = "grant_type=client_credentials&client_id=$ClientId&client_secret=$ClientSecret&resource=$Resource"

#Get the access token
$AccessToken = Invoke-RestMethod -Method Post -Uri $RequestAccessTokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'

#Format the authorization header for the API call
$Headers = @{}
$Headers.Add("Authorization","$($AccessToken.token_type) "+ " " + "$($AccessToken.access_token)")

#Setting the URI and the body for the API call
$uri = "https://management.azure.com/subscriptions/$SubscriptionId/resourcegroups/$resGroupName/exportTemplate?api-version=2021-04-01"
$restBody = @"
{
    "options": "SkipResourceNameParameterization",
    "resources": [
        "/subscriptions/$SubscriptionId/resourceGroups/$resGroupName/providers/Microsoft.Network/azureFirewalls/$fwName",
        "/subscriptions/$SubscriptionId/resourceGroups/$resGroupName/providers/Microsoft.Network/firewallPolicies/$fwPolicyName"
    ]
}
"@

#Invoking REST API
$fwConfig = Invoke-RestMethod -Method Post -Uri $uri -Headers $Headers -Body $restBody -ContentType 'application/json'

#Saving the output in a json file
$fwConfig.template | ConvertTo-Json -Depth 10 | Out-File "AzFw_Backup_$today.json"
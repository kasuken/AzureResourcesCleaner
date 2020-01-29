param($Timer)

$currentUTCtime = (Get-Date).ToUniversalTime()

$expiredResources = Search-AzGraph -Query 'where todatetime(tags.expireOn) < now() | project id, name'

foreach ($r in $expiredResources) {
    Write-Host "==> Deleting  $($r.name)...";
    Remove-AzResource -ResourceId $r.id -Force -WhatIf
}

$expiredResources = Get-AzResourceGroup;

foreach ($resourceGroup in $expiredResources) {
    $count = (Get-AzResource | Where-Object { $_.ResourceGroupName -match $resourceGroup.ResourceGroupName }).Count;
    if ($count -eq 0) {
        Write-Host "==> $($resourceGroup.ResourceGroupName) is empty. Deleting it...";
        Remove-AzResourceGroup -Name $resourceGroup.ResourceGroupName -Force -WhatIf
    }
}

$expiredResources = Get-AzResourceGroup | Where-Object { $_.Tags.expireOn -and [DateTime] $_.Tags.expireOn -lt $currentUTCtime }

Foreach ($resourceGroup in $expiredResources) {
    Write-Host "==> $($resourceGroup.ResourceGroupName) is expired. Deleting it..."
    Remove-AzResourceGroup -Name $resourceGroup.ResourceGroupName -Force -WhatIf
}

# Write an information log with the current time.
Write-Host "Azure Resources Cleaner ran at : $currentUTCtime"
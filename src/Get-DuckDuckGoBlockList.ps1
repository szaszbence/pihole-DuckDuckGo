function Get-DuckDuckGoBlockList {
    [CmdletBinding()]
    param()

    $originalListResponse = Invoke-WebRequest https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts 
    $originalList = $originalListResponse.Content.Split([System.Environment]::NewLine,[System.StringSplitOptions]::RemoveEmptyEntries) | Where-Object { $_.StartsWith("0.0.0.0 ") }

    $blockListResponse = Invoke-WebRequest https://raw.githubusercontent.com/duckduckgo/tracker-blocklists/main/app/android-tds.json
    if($blockListResponse.StatusCode -ne 200) {
        Write-Error "Failed to donwload block list."
    } else {
        $blockList = $blockListResponse.Content | ConvertFrom-Json
        $trackers = $blockList.trackers

        foreach($entry in ($trackers | Get-Member -MemberType NoteProperty))
        {
            $trackerName = $entry.Name
            [PSCustomObject] @{
                Name = $trackerName;
                Operation = $trackers.$trackerName.default
            } | Where-Object -Property Operation -eq block | Select-Object -ExpandProperty Name | ForEach-Object { "0.0.0.0 $_" } | Where-Object { $originalList -notcontains $_ } | Write-Output
        }
    }
}
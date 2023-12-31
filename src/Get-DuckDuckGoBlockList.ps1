function Get-DuckDuckGoBlockList {
    [CmdletBinding()]
    param()

    $originalListResponse = Invoke-WebRequest https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts 
    $originalList = $originalListResponse.Content.Split([System.Environment]::NewLine,[System.StringSplitOptions]::RemoveEmptyEntries) | Where-Object { $_.StartsWith("0.0.0.0 ") }

    $blockListResponse = Invoke-WebRequest https://raw.githubusercontent.com/duckduckgo/tracker-blocklists/main/web/v6/extension-tds.json
    $blockListResponse2 = Invoke-WebRequest https://raw.githubusercontent.com/duckduckgo/tracker-blocklists/main/app/android-tds.json
    if($blockListResponse.StatusCode -ne 200 -or $blockListResponse2.StatusCode -ne 200) {
        Write-Error "Failed to donwload block list(s)."
    } else {
        $blockList = $blockListResponse.Content | ConvertFrom-Json
        $blockList2 = $blockListResponse2.Content | ConvertFrom-Json
        $trackers = $blockList.trackers 
        $trackers2 = $blockList2.trackers

        foreach($entry in ($trackers | Get-Member -MemberType NoteProperty))
        {
            $trackerName = $entry.Name
            [PSCustomObject] @{
                Name = $trackerName;
                Operation = $trackers.$trackerName.default
                Rules = $trackers.$trackerName.rules
            } | Where-Object -Property Operation -eq block | Where-Object -Property Rules -eq $null | Select-Object -ExpandProperty Name | ForEach-Object { "0.0.0.0 $_" } | Where-Object { $originalList -notcontains $_ } | Write-Output
        }

        foreach($entry in ($trackers2 | Get-Member -MemberType NoteProperty))
        {
            $trackerName = $entry.Name
            [PSCustomObject] @{
                Name = $trackerName;
                Operation = $trackers.$trackerName.default
                Rules = $trackers.$trackerName.rules
            } | Where-Object -Property Operation -eq block | Where-Object -Property Rules -eq $null | Select-Object -ExpandProperty Name | ForEach-Object { "0.0.0.0 $_" } | Where-Object { $originalList -notcontains $_ } | Write-Output
        }
    }
}
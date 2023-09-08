function Write-Color([String[]]$Text, [ConsoleColor[]]$Color) {
    Write-Host $Text[0] -Foreground $Color[0] -NoNewLine
    Write-Host $Text[1] -Foreground $Color[1] -NoNewLine
}

function Select-SingleMenu([String[]] $arr, [ref]$selected_line) {
    $pointer = $Host.UI.RawUI.CursorPosition.Y
    $maxLines = $Host.UI.RawUI.WindowSize.Height - $pointer - 1
    $maxWidth = $Host.UI.RawUI.WindowSize.Width

    $arr_idx=0
    $selected_line.Value=0
    $selected_row=0

    $minVal= @($arr.Count, $maxLines) | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap {[System.Console]::CursorVisible=$true; break;}
    [System.Console]::CursorVisible=$false


    $humesha_True=$true
    while($humesha_True)
    {
        $Host.UI.RawUI.CursorPosition = @{X=0; Y=$pointer}
        for($i=$arr_idx; ($i - $arr_idx) -lt $minVal; $i++)
        {
            $value = "  $($arr[$i])  "
            $padd = "".PadLeft($maxWidth -$value.Length)

            if($selected_row -eq ($i-$arr_idx))
            {
                Write-Host -NoNewline $value -BackgroundColor White -ForegroundColor Black
                
            }
            else { Write-Host -NoNewline $value }
            Write-Host $padd
        }

        $keyInput=$host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown").VirtualKeyCode
        switch ($keyInput) {
            38
            {
                $selected_line.Value--
                $selected_row--
                if($selected_row -lt 0)
                {
                    $selected_row = 0
                    $arr_idx--
                }
                if($arr_idx -lt 0)
                {
                    $selected_row = $minVal-1
                    $selected_line.Value = $arr.Count-1
                    $arr_idx = $selected_line.Value - $selected_row
                }
                break;
            }
            40 
            {
                $selected_line.Value++
                $selected_row++
                if ($selected_row -eq $minVal)
                {
                    $selected_row = $minVal - 1
                    $arr_idx++
                }
                if($selected_line.Value -eq $arr.Count)
                {
                    $arr_idx = 0
                    $selected_row = 0
                    $selected_line.Value = 0
                }
                break;
            }
            13 { $humesha_True=$false; break;  }
            Default {;}
        }
    }
    [System.Console]::CursorVisible=$true
}



function Select-MultipleMenu([String[]]$torrent_info_array, [ref]$result) {

    $selected=[System.Collections.ArrayList]::Repeat($false,$torrent_info_array.Count)

    function toggleOptions([int]$idx)
    {
        if($selected[$idx] -eq $true)
        {
            $selected[$idx]=$false
        }
        else {
            $selected[$idx] = $true
        }
    }

    function final_steps {
        $temp = ""

        for($i=0; $i -lt $torrent_info_array.Count; $i++)
        {
            if($selected[$i] -eq $true)
            {
                $temp+="$i, "
            }
        }
        
        $temp = $temp.Remove($temp.Length-2)
        $result.Value = $temp
    }
    
    $pointer = $Host.UI.RawUI.CursorPosition.Y
    $maxLines = $Host.UI.RawUI.WindowSize.Height - $pointer - 1
    $maxWidth = $Host.UI.RawUI.WindowSize.Width

    $arr_idx=0
    $selected_line=0
    $selected_row=0

    $minVal= @($torrent_info_array.Count, $maxLines) | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap {[System.Console]::CursorVisible=$true; break;}
    [System.Console]::CursorVisible=$false


    $humesha_True=$true
    while($humesha_True)
    {
        $Host.UI.RawUI.CursorPosition = @{X=0; Y=$pointer}
        for($i=$arr_idx; ($i - $arr_idx) -lt $minVal; $i++)
        {
            # Whether selected or not
            if($selected[$i] -eq $true)
            {
                Write-Host -NoNewline "["
                Write-Host -NoNewline "$([char]0x2714)" -ForegroundColor Green
                Write-Host -NoNewline "] "
            }
            else {
                Write-Host -NoNewline "[ ] "
            }

            $value = "  $($torrent_info_array[$i])  "
            $padd = "".PadLeft($maxWidth -$value.Length-4)

            if($selected_row -eq ($i-$arr_idx))
            {
                
                Write-Host -NoNewline $value -BackgroundColor White -ForegroundColor Black
                
            }
            else { Write-Host -NoNewline $value }
            Write-Host $padd
        }

        $keyInput=$host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown").VirtualKeyCode
        switch ($keyInput) {
            38
            {
                $selected_line--
                $selected_row--
                if($selected_row -lt 0)
                {
                    $selected_row = 0
                    $arr_idx--
                }
                if($arr_idx -lt 0)
                {
                    $selected_row = $minVal-1
                    $selected_line = $torrent_info_array.Count-1
                    $arr_idx = $selected_line - $selected_row
                }
                break;
            }
            40 
            {
                $selected_line++
                $selected_row++
                if ($selected_row -eq $minVal)
                {
                    $selected_row = $minVal - 1
                    $arr_idx++
                }
                if($selected_line -eq $torrent_info_array.Count)
                {
                    $arr_idx = 0
                    $selected_row = 0
                    $selected_line = 0
                }
                break;
            }
            77
            {
                toggleOptions $selected_line
                break;
            }
            13 
            { 
                final_steps
                $humesha_True=$false
                break;  
            }
            Default {; break;}
        }
    }
    [System.Console]::CursorVisible=$true
}


function select-content([string]$MAGNET,[string] $VIDEO_PLAYER){
    Clear-Host
    # VIDEO_PLAYER added to avoid creation of folder in current directory
    $torrent_info=web-torrent-cli "$MAGNET" --select --"vlc"
    
    Write-Color -Text "$([char]0x2191) : ", "Up `t" -Color White, Cyan
    Write-Color -Text "$([char]0x2193) : ", "Down `t" -Color White, Cyan
    Write-Color -Text "m : ", "Toggle Selection `t" -Color White, Cyan
    Write-Color -Text "$([char]0x23CE) : ", "Confirm Selection" -Color White, Cyan
    Write-Host "`n"

    $torrent_info_array=$torrent_info | Select-String -Pattern "Select a file to download:" -Context 0,1000 | Select-Object -ExpandProperty Context | Select-Object -ExpandProperty PostContext | Select-String -Pattern "^[0-9]+\s*.*" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value


    $selected_choice=""
    Select-MultipleMenu $torrent_info_array ([ref] $selected_choice)

    if($selected_choice -ne "")
    {
        if($VIDEO_PLAYER -ne "")
        {
            web-torrent-cli "$MAGNET" --select $selected_choice $VIDEO_PLAYER --not-on-top
        }
        else{
            web-torrent-cli "$MAGNET" --select $selected_choice
        }
    }
    else {
        Write-Host "Exiting..."
    }
}

function yt_downloader {
    Clear-Host
    $url = Read-Host "Enter the url of the video"
    Write-Host
    $yt_options=@("Audio Download", "Video Download")
    $choice=-1
    Select-SingleMenu $yt_options ([ref] $choice)
    
    if($choice -eq 0)
    {
        yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail "$url"
    }
    else{
        yt-dlp "$url"
    }
    
}


function get_data([String]$contentType, [Int32] $category, [ref] $result) {
    $name=Read-Host "Enter the name of the $contentType"
    $name=[uri]::EscapeUriString($name)

    $video_content=(Invoke-WebRequest -Uri "https://tpb25.ukpass.co/apibay/q.php?q=${name}&cat=${category}" -Method Get -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json) | Select-Object -Property name, info_hash
    
    Clear-Host
    Write-Color -Text "$([char]0x2191) : ", "Up `t" -Color White, Cyan
    Write-Color -Text "$([char]0x2193) : ", "Down `t" -Color White, Cyan
    Write-Color -Text "$([char]0x23CE) : ", "Confirm Selection" -Color White, Cyan
    Write-Host "`n"

    $selected_option=0
    Select-SingleMenu $($video_content | Select-Object -ExpandProperty name) ([ref] $selected_option)

    $result.Value = $video_content[$selected_option].info_hash
}


function main {
    Clear-Host
    
    Write-Color -Text "$([char]0x2191) : ", "Up `t" -Color White, Cyan
    Write-Color -Text "$([char]0x2193) : ", "Down `t" -Color White, Cyan
    Write-Color -Text "$([char]0x23CE) : ", "Confirm Selection" -Color White, Cyan
    Write-Host "`n"

    $actions = @("Download Youtube Video", "Download Movie", "Stream Movie", "Download TV Series", "Stream TV Series", "Exit")

    $selected_option=0
    Select-SingleMenu $actions ([ref] $selected_option)

    switch ($selected_option) {
        0 
        {
            yt_downloader
            break;
        }
        1 
        {
            $result=""
            get_data "Movie" 207 ([ref] $result)
            select-content "magnet:?xt=urn:btih:$result" ""
            break;
        }
        2 
        {
            $result=""
            get_data "Movie" 207 ([ref] $result)
            select-content "magnet:?xt=urn:btih:$result" "--vlc"
            break;
        }
        3 
        {
            $result=""
            get_data "TV Series" 208 ([ref] $result)
            select-content "magnet:?xt=urn:btih:$result" ""
            break;
        }
        4 
        {
            $result=""
            get_data "TV Series" 208 ([ref] $result)
            select-content "magnet:?xt=urn:btih:$result" "--mpv"
            break;
        }
        5
        {
            Write-Host "  Exiting.."
            break;
        }
        Default 
        { 
            Write-Host "  Invalid Choice"
            break;
        }
    }
}

main


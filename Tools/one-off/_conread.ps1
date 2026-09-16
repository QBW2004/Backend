$outFile = 'C:\Users\Administrator\reset_20260916\console_dump.txt'
$errFile = 'C:\Users\Administrator\reset_20260916\console_err.txt'
$code = @'
using System;
using System.Runtime.InteropServices;
using System.Text;
public class ConRead {
  [StructLayout(LayoutKind.Sequential)] public struct COORD { public short X; public short Y; }
  [StructLayout(LayoutKind.Sequential)] public struct SMALL_RECT { public short Left; public short Top; public short Right; public short Bottom; }
  [StructLayout(LayoutKind.Sequential)] public struct CONSOLE_SCREEN_BUFFER_INFO {
     public COORD dwSize; public COORD dwCursorPosition; public ushort wAttributes;
     public SMALL_RECT srWindow; public COORD dwMaximumWindowSize;
  }
  [DllImport("kernel32.dll", SetLastError=true)] public static extern bool FreeConsole();
  [DllImport("kernel32.dll", SetLastError=true)] public static extern bool AttachConsole(uint pid);
  [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Unicode)] public static extern IntPtr CreateFileW(string n, uint acc, uint share, IntPtr sec, uint disp, uint flags, IntPtr t);
  [DllImport("kernel32.dll", SetLastError=true)] public static extern bool GetConsoleScreenBufferInfo(IntPtr h, out CONSOLE_SCREEN_BUFFER_INFO info);
  [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Unicode)] public static extern bool ReadConsoleOutputCharacterW(IntPtr h, StringBuilder buf, uint len, COORD coord, out uint read);
  [DllImport("kernel32.dll", SetLastError=true)] public static extern bool CloseHandle(IntPtr h);
}
'@
$log = New-Object System.Collections.ArrayList
function W($s) { [void]$log.Add([string]$s) }

try {
    Add-Type -TypeDefinition $code -ErrorAction Stop
    $p = Get-CimInstance Win32_Process -Filter "Name='ServerCenterNew.exe'"
    W ("CENTER_PID=" + $p.ProcessId)
    [void][ConRead]::FreeConsole()
    $att = [ConRead]::AttachConsole([uint32]$p.ProcessId)
    W ("ATTACH=" + $att + " GLE=" + [Runtime.InteropServices.Marshal]::GetLastWin32Error())
    if ($att) {
        $h = [ConRead]::CreateFileW('CONOUT$', 0xC0000000, 3, [IntPtr]::Zero, 3, 0, [IntPtr]::Zero)
        W ("CONOUT_HANDLE=" + $h + " GLE=" + [Runtime.InteropServices.Marshal]::GetLastWin32Error())
        if ($h -ne [IntPtr]::Zero -and $h -ne [IntPtr](-1)) {
            $info = New-Object ConRead+CONSOLE_SCREEN_BUFFER_INFO
            $ok = [ConRead]::GetConsoleScreenBufferInfo($h, [ref]$info)
            W ("SCREENINFO_OK=" + $ok + " BUF=" + $info.dwSize.X + "x" + $info.dwSize.Y + " CUR_Y=" + $info.dwCursorPosition.Y + " WIN=" + $info.srWindow.Top + "-" + $info.srWindow.Bottom)
            if ($ok) {
                $width = $info.dwSize.X
                $endY = $info.dwCursorPosition.Y
                $startY = $endY - 150
                if ($startY -lt 0) { $startY = 0 }
                for ($y = $startY; $y -le $endY; $y++) {
                    $sb = New-Object System.Text.StringBuilder ($width + 1)
                    $rd = 0
                    $c = New-Object ConRead+COORD
                    $c.X = 0; $c.Y = [short]$y
                    $r = [ConRead]::ReadConsoleOutputCharacterW($h, $sb, [uint32]$width, $c, [ref]$rd)
                    if ($r) { W ("" + $y + ": " + $sb.ToString().TrimEnd()) } else { W ("" + $y + ": <read failed GLE=" + [Runtime.InteropServices.Marshal]::GetLastWin32Error() + ">") }
                }
            }
            [void][ConRead]::CloseHandle($h)
        }
    }
} catch {
    W ("EXCEPTION: " + $_.Exception.Message)
}
[System.IO.File]::WriteAllText($outFile, ($log -join "`r`n"), (New-Object System.Text.UTF8Encoding($false)))

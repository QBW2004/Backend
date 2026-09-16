$outFile = 'C:\Users\Administrator\reset_20260916\acl_dump.txt'
$code = @'
using System;
using System.Runtime.InteropServices;
public class PipeSec2 {
  [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Unicode)]
  static extern IntPtr CreateFileW(string name, uint access, uint share, IntPtr sec, uint disp, uint flags, IntPtr templ);
  [DllImport("advapi32.dll", SetLastError=true)]
  static extern uint GetSecurityInfo(IntPtr handle, int objectType, uint secInfo, out IntPtr pOwner, out IntPtr pGroup, out IntPtr pDacl, out IntPtr pSacl, out IntPtr pSD);
  [DllImport("advapi32.dll", SetLastError=true, CharSet=CharSet.Unicode)]
  static extern bool ConvertSecurityDescriptorToStringSecurityDescriptorW(IntPtr sd, uint rev, uint secInfo, out IntPtr str, out uint len);
  [DllImport("kernel32.dll", SetLastError=true)] static extern bool CloseHandle(IntPtr h);
  [DllImport("kernel32.dll", SetLastError=true)] static extern IntPtr LocalFree(IntPtr h);

  public static string Probe(string pipeName) {
    uint GENERIC_READ = 0x80000000;
    IntPtr h = CreateFileW(pipeName, GENERIC_READ, 0, IntPtr.Zero, 3, 0, IntPtr.Zero);
    int gle = Marshal.GetLastWin32Error();
    if (h == new IntPtr(-1)) return "OPEN_FAILED GLE=" + gle;
    string result = "OPEN_OK";
    IntPtr sd = IntPtr.Zero, sa = IntPtr.Zero, da = IntPtr.Zero, ow = IntPtr.Zero, gr = IntPtr.Zero;
    uint rc = GetSecurityInfo(h, 6, 4, out ow, out gr, out da, out sa, out sd);
    result += " GetSecurityInfo=" + rc;
    if (sd != IntPtr.Zero) {
      IntPtr str = IntPtr.Zero; uint len = 0;
      if (ConvertSecurityDescriptorToStringSecurityDescriptorW(sd, 1, 4, out str, out len)) {
        result += " SDDL=" + Marshal.PtrToStringUni(str);
        LocalFree(str);
      } else { result += " SDDL_FAIL=" + Marshal.GetLastWin32Error(); }
    }
    CloseHandle(h);
    return result;
  }
}
'@
$log = New-Object System.Collections.ArrayList
function W($s) { [void]$log.Add([string]$s) }
try {
    Add-Type -TypeDefinition $code -ErrorAction Stop
    W ("PROBE: " + [PipeSec2]::Probe('\\.\pipe\mynamedpipe'))
    W ("PROBE_ROBOT: " + [PipeSec2]::Probe('\\.\pipe\MTH_RobotPipe'))
    W ("PROBE_SRVPIPE: " + [PipeSec2]::Probe('\\.\pipe\MTH_ServerPipe'))
    $who = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    W ("CURRENT_USER=" + $who.Name + " SID=" + $who.User.Value)
    W ("GROUPS=" + (($who.Groups | ForEach-Object { $_.Translate([System.Security.Principal.NTAccount]).Value }) -join ', '))
} catch { W ("EXCEPTION: " + $_.Exception.Message) }
[System.IO.File]::WriteAllText($outFile, ($log -join "`r`n"), (New-Object System.Text.UTF8Encoding($false)))

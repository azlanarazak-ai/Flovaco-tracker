$root = "C:\Users\Azlan\.ilmucode\workspace\default"
$listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Any, 5680)
$listener.Start()
Write-Host "Serving $root on http://localhost:5680/ and http://192.168.1.106:5680/"
while ($true) {
  $client = $listener.AcceptTcpClient()
  try {
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $firstLine = $reader.ReadLine()
    $rel = "/"
    if ($firstLine -match "^GET\s+(\S+)") { $rel = $Matches[1] }
    if ($rel -eq "/") { $rel = "/index.html" }
    $file = Join-Path $root (($rel -split "\?")[0].TrimStart("/") -replace "/", "\")
    if (Test-Path $file -PathType Leaf) {
      $bytes = [System.IO.File]::ReadAllBytes($file)
      $header = "HTTP/1.1 200 OK`r`nContent-Type: text/html; charset=utf-8`r`nContent-Length: $($bytes.Length)`r`nConnection: close`r`n`r`n"
      $hb = [System.Text.Encoding]::ASCII.GetBytes($header)
      $stream.Write($hb, 0, $hb.Length)
      $stream.Write($bytes, 0, $bytes.Length)
    } else {
      $msg = [System.Text.Encoding]::UTF8.GetBytes("HTTP/1.1 404 Not Found`r`nContent-Length: 9`r`nConnection: close`r`n`r`nnot found")
      $stream.Write($msg, 0, $msg.Length)
    }
    $stream.Close()
  } catch { }
  finally { $client.Close() }
}

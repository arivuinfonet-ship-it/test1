# Native PowerShell HTTP Server for localhost:8000
$port = 8000
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   TAMIL EXAM & QUIZ INTERACTIVE WEB PORTAL LOCALSERVER  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

try {
    $listener.Start()
    Write-Host "Server successfully started on: http://localhost:$port/" -ForegroundColor Green
    Write-Host "Opening browser..." -ForegroundColor Yellow
    
    # Auto-open browser
    Start-Process "http://localhost:$port/"
    
    Write-Host "Press [Ctrl+C] to stop the server." -ForegroundColor Red
    Write-Host "----------------------------------------------------------"
    
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $urlPath = $request.RawUrl.Split('?')[0]
        if ($urlPath -eq "/") { $urlPath = "/index.html" }
        
        $filePath = Join-Path $pwd $urlPath
        
        if (Test-Path $filePath -PathType Leaf) {
            $buffer = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $buffer.Length
            
            # Match Content-Type header
            if ($filePath.EndsWith(".html")) {
                $response.ContentType = "text/html; charset=utf-8"
            }
            elseif ($filePath.EndsWith(".css")) {
                $response.ContentType = "text/css; charset=utf-8"
            }
            elseif ($filePath.EndsWith(".js")) {
                $response.ContentType = "application/javascript; charset=utf-8"
            }
            else {
                $response.ContentType = "application/octet-stream"
            }
            
            $output = $response.OutputStream
            $output.Write($buffer, 0, $buffer.Length)
            $output.Close()
            Write-Host "Served file [200]: $urlPath" -ForegroundColor DarkGray
        } else {
            $response.StatusCode = 404
            $response.Close()
            Write-Host "File not found [404]: $urlPath" -ForegroundColor DarkYellow
        }
    }
}
catch {
    Write-Host "An error occurred starting the server: $_" -ForegroundColor Red
}
finally {
    $listener.Close()
    Write-Host "`nServer stopped." -ForegroundColor Red
}

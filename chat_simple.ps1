# =========================
# ==== 1) 設定値を入力 ====
# =========================
if ([string]::IsNullOrEmpty($tenantName)) {
    $tenantName = Read-Host "テナント名(例：aa99999999)を入力してください。"
}
if ([string]::IsNullOrEmpty($idtoken)) {
    $idtoken = Read-Host "有効なトークンを入力してください。"
}
$content = Read-Host "質問を入力してください。"

# ==========================
# ==== 3) GAP問い合わせ ====
# ==========================
$jsonObject = [PSCustomObject]@{
    messages    = @()
    question    = $content
    model       = "cohere.command-r-plus-fujitsu"
    max_tokens  = 1024
    temperature = 0.5
    top_p       = 1
}
$requestJson = $jsonObject | ConvertTo-Json -Depth 10
Set-Content -Path .\body.json -Value $requestJson -Encoding utf8
$endpoint="api/v1/action/defined/text:simple_chat/call"
curl.exe -s -X POST "https://$tenantName.generative-ai-platform.cloud.global.fujitsu.com/$endpoint" `
  -H "Authorization: Bearer $idToken" `
  -H "Content-Type: application/json" `
  --data-binary "@body.json" `
  --ssl-no-revoke `
  --output result.json
$rawJson = Get-Content result.json -Raw -Encoding UTF8
$json = $rawJson | ConvertFrom-Json
Write-Host $json.answer

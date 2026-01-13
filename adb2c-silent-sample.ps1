# =========================
# ==== 1) 設定値を入力 ====
# =========================
$tname = 'aa99999999'
$secret   = 'yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyy'
$clientId   = 'yyyyyyyyyyyyyyy'
$policy     = 'b2c_1_fjcloud_genai_susi'

# =========================
# ==== 2) トークンリクエストURLを組み立て & トークン取得 ====
# =========================
$scope  = "https://$tname.onmicrosoft.com/$clientId/.default"
$scope  = [Uri]::EscapeDataString($scope)
$tokenEndpoint = "https://$tname.b2clogin.com/tfp/$tname.onmicrosoft.com/B2C_1_fjcloud_genai_susi/oauth2/v2.0/token"
$tokenForm = "client_id=$clientId" +
             "&client_secret=$secret" +
             "&scope=$scope" +
             "&grant_type=client_credentials"
$rawJson = & curl.exe -s -X POST `
    "$tokenEndpoint" `
    -H "Content-Type: application/x-www-form-urlencoded" `
    --data "$tokenForm"

# レスポンスをPowerShellのオブジェクトへ
$json = $rawJson | ConvertFrom-Json

# =========================
# ==== 3) 結果の出力 ====
# =========================
$idToken       = $json.id_token
$accessToken   = $json.access_token
$refreshToken  = $json.refresh_token

Write-Host "`n== RESULT =="
Write-Host "ID Token (JWT):"
$idToken
Write-Host "`nAccess Token (JWT):"
$accessToken
Write-Host "`nRefresh Token:"
$refreshToken

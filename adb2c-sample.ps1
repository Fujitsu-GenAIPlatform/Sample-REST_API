# 管理者モードで起動すること
# =========================
# ==== 1) 設定値を入力 ====
# =========================
$tenantName = Read-Host "テナント名(例：aa99999999)を入力してください。"
$clientId   = Read-Host "クライアントID(例:yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyy)を入力してください。"
$policy     = 'b2c_1_fjcloud_genai_susi'

# 推奨: 明示的なポート/パスを使う（管理者権限不要）。アプリ登録のRedirect URIと一致させてください。
$redirectUri = "http://localhost"

# =========================
# ==== 2) 認可リクエストURLを組み立て & ブラウザーで開く ====
# =========================
$nonce  = [Guid]::NewGuid().ToString()
$scope  = [Uri]::EscapeDataString("openid offline_access")
$redir  = [Uri]::EscapeDataString($redirectUri)

# B2C の authorize エンドポイント（ポリシーはパスに含める）
$authorizeUrl = "https://$tenantName.b2clogin.com/$tenantName.onmicrosoft.com/$policy/oauth2/v2.0/authorize" +
                "?client_id=$clientId" +
                "&nonce=$nonce" +
                "&redirect_uri=$redir" +
                "&scope=$scope" +
                "&response_type=code"

Write-Host "Open browser for sign-in: $authorizeUrl"

# ブラウザーでサインイン開始
Start-Process $authorizeUrl

# ------ 管理者モードで実行が必要な部分(開始)
Write-Host "ブラウザでサインインしてください。”
# ローカルで HTTP リスナーを開始
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost/")
$listener.Start()
Write-Host "Waiting for redirect..."
# ブラウザからのアクセスを待つ
$context = $listener.GetContext()
$request = $context.Request
# URL の code パラメータを取得
$code = $request.QueryString["code"]
$listener.Stop()
# ------ 管理者モードで実行が必要な部分(終了)

# ------ 管理者モードで起動できない場合
# Write-Host "ブラウザでサインインし、リダイレクト後のアドレスバーのURLをコピーしてください。"
#
# # ユーザーが貼り付けたURLから code を抽出（HttpListener 不要）
# $code = Read-Host "リダイレクト先のURLのcode=以降を貼り付けて Enter（例: http://localhost:8400/callback?code=...）"

Write-Host "認可コードの取得に成功しました。code=$code"

# =========================
# ==== 3) 認可コードをトークンに交換（curl.exe を使用）====
# =========================
$tokenEndpoint = "https://$tenantName.b2clogin.com/$tenantName.onmicrosoft.com/$policy/oauth2/v2.0/token"
# application/x-www-form-urlencoded を組み立て
$tokenForm = "client_id=$clientId" +
             "&grant_type=authorization_code" +
             "&code=$code"

Write-Host "Exchanging code for tokens via curl.exe ..."
# ここで必ず curl.exe を呼ぶ（Invoke-RestMethodは使わない）
$rawJson = & curl.exe -s -X POST `
    "$tokenEndpoint" `
    -H "Content-Type: application/x-www-form-urlencoded" `
    --data "$tokenForm"

# レスポンスをPowerShellのオブジェクトへ
$json = $rawJson | ConvertFrom-Json

# =========================
# ==== 4) 結果の出力 ====
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

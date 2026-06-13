param(
    [string]$ProjectDir = (Split-Path -Parent $PSScriptRoot)
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$projectRoot = [System.IO.Path]::GetFullPath($ProjectDir)
$envPath = Join-Path $projectRoot '.env'
$examplePath = Join-Path $projectRoot '.env.example'

function Get-EnvValue {
    param(
        [string[]]$Lines,
        [string]$Key
    )

    foreach ($line in $Lines) {
        if ($line -match "^\s*$([regex]::Escape($Key))\s*=\s*(.*)$") {
            return $matches[1].Trim().Trim([char]34, [char]39)
        }
    }

    return ''
}

function Set-EnvValue {
    param(
        [System.Collections.Generic.List[string]]$Lines,
        [string]$Key,
        [string]$Value
    )

    $pattern = "^\s*$([regex]::Escape($Key))\s*="
    for ($index = 0; $index -lt $Lines.Count; $index++) {
        if ($Lines[$index] -match $pattern) {
            $Lines[$index] = "${Key}=${Value}"
            return
        }
    }

    $Lines.Add("${Key}=${Value}")
}

if (-not (Test-Path $envPath) -and (Test-Path $examplePath)) {
    Copy-Item $examplePath $envPath
}

$existingLines = if (Test-Path $envPath) { Get-Content $envPath } else { @() }
$existingKey = Get-EnvValue -Lines $existingLines -Key 'OPENAI_API_KEY'

$form = New-Object System.Windows.Forms.Form
$form.Text = '配置 AI API Key'
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(560, 230)
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.TopMost = $true

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(20, 20)
$label.Size = New-Object System.Drawing.Size(500, 45)
$label.Text = '可在启动开发环境前输入 OpenAI API Key。留空并点“跳过继续”即可继续启动，之后也可以手动修改 .env。'
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(20, 80)
$textBox.Size = New-Object System.Drawing.Size(500, 28)
$textBox.UseSystemPasswordChar = $true
$textBox.Text = $existingKey
$form.Controls.Add($textBox)

$hint = New-Object System.Windows.Forms.Label
$hint.Location = New-Object System.Drawing.Point(20, 112)
$hint.Size = New-Object System.Drawing.Size(500, 20)
$hint.Text = '保存后会自动写入 OPENAI_API_KEY，并把 AI_EXPLANATION_ENABLED 设为 true。'
$form.Controls.Add($hint)

$saveButton = New-Object System.Windows.Forms.Button
$saveButton.Location = New-Object System.Drawing.Point(260, 145)
$saveButton.Size = New-Object System.Drawing.Size(120, 32)
$saveButton.Text = '保存并继续'
$saveButton.Add_Click({
    if ([string]::IsNullOrWhiteSpace($textBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show('请输入 API Key，或者点击“跳过继续”。', '提示') | Out-Null
        return
    }

    $form.Tag = 'save'
    $form.Close()
})
$form.Controls.Add($saveButton)

$skipButton = New-Object System.Windows.Forms.Button
$skipButton.Location = New-Object System.Drawing.Point(400, 145)
$skipButton.Size = New-Object System.Drawing.Size(120, 32)
$skipButton.Text = '跳过继续'
$skipButton.Add_Click({
    $form.Tag = 'skip'
    $form.Close()
})
$form.Controls.Add($skipButton)

$form.Add_Shown({ $form.Activate(); $textBox.Focus(); $textBox.SelectAll() })

[void]$form.ShowDialog()

if ($form.Tag -eq 'save') {
    $updatedLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $existingLines) {
        [void]$updatedLines.Add($line)
    }

    Set-EnvValue -Lines $updatedLines -Key 'AI_EXPLANATION_ENABLED' -Value 'true'
    Set-EnvValue -Lines $updatedLines -Key 'OPENAI_API_KEY' -Value ($textBox.Text.Trim())

    Set-Content -Path $envPath -Value $updatedLines -Encoding UTF8
    Write-Host '[INFO] 已写入 .env，并启用 AI_EXPLANATION_ENABLED=true'
} else {
    Write-Host '[INFO] 已跳过 API Key 配置，继续启动开发环境。'
}

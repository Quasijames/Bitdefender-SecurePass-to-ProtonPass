param(
    [string]$InputFile = 'C:\Users\James\downloads\export.csv',
    [string]$OutputFile = 'C:\Users\James\downloads\proton-import.csv'
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $InputFile -PathType Leaf)) {
    throw "Input file not found: $InputFile"
}
if (Test-Path -LiteralPath $OutputFile) {
    throw "Output already exists; nothing overwritten: $OutputFile"
}
$rows = @(Import-Csv -LiteralPath $InputFile -Delimiter ',' -Encoding UTF8)
if ($rows.Count -eq 0) { throw 'The input CSV has no data rows.' }
$required = @('website_password_title', 'website_password_url',
    'website_password_username', 'website_password_password', 'website_password_notes')
foreach ($column in $required) {
    if ($rows[0].PSObject.Properties.Name -notcontains $column) {
        throw "Missing expected column: $column. Nothing converted."
    }
}
$skipped = 0
$totp = 0
$converted = @(foreach ($row in $rows) {
    $hasWebsiteData = $false
    foreach ($column in $required) {
        if (-not [string]::IsNullOrEmpty([string]$row.$column)) { $hasWebsiteData = $true }
    }
    if (-not $hasWebsiteData) { $skipped++; continue }
    if (-not [string]::IsNullOrEmpty([string]$row.website_password_totp_code)) { $totp++ }
    $title = [string]$row.website_password_title
    if ([string]::IsNullOrWhiteSpace($title)) { $title = [string]$row.website_password_url }
    if ([string]::IsNullOrWhiteSpace($title)) { $title = 'Imported website login' }
    [pscustomobject][ordered]@{
        name = $title
        url = [string]$row.website_password_url
        email = [string]$row.website_password_username
        password = [string]$row.website_password_password
        note = [string]$row.website_password_notes
    }
})
if ($converted.Count -eq 0) { throw 'No website login rows found. Nothing written.' }
$converted | Export-Csv -LiteralPath $OutputFile -NoTypeInformation -Encoding UTF8 -NoClobber
$check = @(Import-Csv -LiteralPath $OutputFile -Encoding UTF8)
if ($check.Count -ne $converted.Count) { throw 'Output verification failed. Do not import.' }
for ($i = 0; $i -lt $converted.Count; $i++) {
    foreach ($column in @('name','url','email','password','note')) {
        if ($check[$i].$column -cne $converted[$i].$column) {
            throw "Output verification failed at row $($i + 1), column $column. Do not import."
        }
    }
}
Write-Host "Created and verified $($converted.Count) website logins: $OutputFile"
Write-Host "Input rows: $($rows.Count); skipped non-website rows: $skipped."
Write-Warning 'This converts website logins only. Cards, identities, application passwords and standalone notes are NOT converted. Keep the original export.'
if ($totp -gt 0) { Write-Warning "$totp website rows contain 2FA data. 2FA is NOT converted; keep your existing authenticator setup." }
Write-Warning 'Both CSV files contain unencrypted credentials. Do not upload them or open them in a spreadsheet.'

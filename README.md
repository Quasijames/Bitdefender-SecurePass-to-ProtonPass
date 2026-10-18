# Bitdefender SecurePass to Proton Pass

## The problem

I tried moving my passwords from Bitdefender SecurePass to Proton Pass using an exported CSV file. Instead of my saved logins, I got 552 entries called “Unnamed note.”

## The likely cause

The two apps organize the exported information differently. Proton didn’t understand which parts were the website names, usernames, and passwords.

## Our solution

We made a script that rearranges the information into the format Proton expects, without changing the original file.

## Step-by-step solution for Windows

This script converts website logins only—not cards, personal details, separate notes, or two-factor authentication settings.

### 1. Export your passwords

- Open Bitdefender SecurePass and export your passwords as a CSV file.
- Save it in your computer’s **Downloads** folder.
- Name the file **`export.csv`**.

### 2. Download the script

- Click Convert-SecurePass.ps1 in this repository.
- Click Download raw file.
- Save it in your Downloads folder.

### 3. Check your files

Your Downloads folder should now contain both files:

```text
export.csv
Convert-SecurePass.ps1
```

### 4. Open PowerShell

- Click the **Start** button.
- Type **PowerShell**.
- Open **Windows PowerShell**. You don’t need to run it as administrator.

### 5. Run the script

Copy this line, paste it into PowerShell, and press **Enter**:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\Downloads\Convert-SecurePass.ps1"
```

If it finishes successfully, it creates a new file in Downloads called:

```text
proton-import.csv
```

If you see a red error message, stop rather than importing the file.

Your original export stays unchanged. The script also reports how many website logins it converted and how many other rows it skipped.

If it finishes successfully, you’ll see a confirmation followed by yellow warning messages. For example:

```text
Created and verified 552 website logins: C:\Users\James\downloads\proton-import.csv
Input rows: 552; skipped non-website rows: 0.
WARNING: This converts website logins only. Cards, identities, application passwords and standalone notes are NOT converted. Keep the original export.
WARNING: Both CSV files contain unencrypted credentials. Do not upload them or open them in a spreadsheet.
```

Your numbers and file path may be different. **The yellow warnings are reminders, not errors.**

### 6. Import the new file into Proton Pass

- Open the import settings in **Proton Pass**.
- Choose **Generic CSV**.
- Select the newly created **`proton-import.csv`** from Downloads.

The script has been tested with sample data. A successful import into Proton Pass has not yet been confirmed.

### 7. Check your passwords

Open a few imported entries and check that the website, username, and password are correct before relying on them.

### 8. Keep a safe offline backup

Once you’ve checked that the import worked:

- Copy **`export.csv`** and **`proton-import.csv`** to an **encrypted USB stick**.
- Check that both files are on the stick.
- Unplug it and store it somewhere safe.
- Delete the CSV files from your computer’s Downloads folder and empty the Recycle Bin.

**Important:** These CSV files contain readable passwords. Anyone who gets access to them can read those passwords, so use an encrypted USB stick or encrypted storage—not just an ordinary folder labelled “secure.”

# Fresh start setup (VS Code + Antigravity first)

Use this guide if you are setting up BA-Kit on a fresh machine or first-time environment.

## 1. Install prerequisites

- git (required)
  - macOS: run `xcode-select --install`
  - Windows: install Git for Windows from https://git-scm.com/download/win
  - Linux: install from your distro package manager (for example, `sudo apt install git`)
- One assistant/IDE
  - VS Code + GitHub Copilot (recommended)
    - Install Visual Studio Code
    - Install the GitHub Copilot extension in VS Code
    - Sign in to GitHub in VS Code so Copilot Chat is available
  - Antigravity IDE
    - Install Antigravity IDE
    - Complete first-launch/sign-in so local skills can be detected
- Terminal
  - macOS / Linux: built-in Terminal
  - Windows: PowerShell 7+ (`pwsh`)

## 2. Clone BA-Kit

```sh
git clone https://github.com/aplakhotnik/bakit.git
cd bakit
```

## 3. Install for VS Code (Copilot)

macOS / Linux:

```sh
./install.sh --agent copilot
```

Windows (PowerShell 7+):

```powershell
.\install.ps1 -Agent copilot
```

If Windows shows "running scripts is disabled on this system", run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1 -Agent copilot
```

This affects only the current terminal session.

Optional persistent user-level policy:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

After install in VS Code:

- Reload window: Command Palette -> Developer: Reload Window
- Trust folder if prompted
- In Copilot Chat, type `/` and confirm commands like `/ba.start-project`

## 4. Install for Antigravity

Workspace scope (recommended when starting):

```sh
./install.sh --agent antigravity --scope workspace
# .\install.ps1 -Agent antigravity -Scope workspace
```

Global scope (all projects on this machine):

```sh
./install.sh --agent antigravity --scope global
# .\install.ps1 -Agent antigravity -Scope global
```

## 5. Verify install

- VS Code: `.github/prompts/ba.start-project.prompt.md` exists
- Antigravity workspace scope: `.agents/skills/ba.start-project/SKILL.md` exists
- Antigravity global scope: `~/.gemini/config/skills/ba.start-project/SKILL.md` exists

If you want other assistants later (Claude/Cursor/Generic), re-run installer with `--agent` (or `-Agent`) for each target.

## 6. Continue

- Daily workflow: [Getting started](getting-started.md)
- Troubleshooting: [FAQ](faq.md)

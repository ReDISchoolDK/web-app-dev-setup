# WAD Setup

Welcome! Follow these steps to set up your development tools for the course.

---

## Step 1: Protect your email

Before anything else, go to your GitHub settings and turn on email privacy.
This prevents your personal email from showing up in your commits.

1. Go to [GitHub → Settings → Emails](https://github.com/settings/emails)
2. Check **Keep my email addresses private**
3. Check **Block command line pushes that expose my email**

> With "Block command line pushes" enabled, GitHub will reject any push
> that contains your real email. This is your safety net.

The setup script will automatically configure Git to use your GitHub noreply
email address, so you don't need to copy anything manually.

---

## Step 2: Run the setup script

Open a terminal and paste the command for your operating system.

### macOS / Linux

Open **Terminal** and run:

```bash
curl -fsSL https://raw.githubusercontent.com/ReDISchoolDK/web-app-dev-setup/main/setup-mac.sh -o /tmp/setup.sh && bash /tmp/setup.sh
```

### Windows

Open **PowerShell** and run:

```powershell
irm https://raw.githubusercontent.com/ReDISchoolDK/web-app-dev-setup/main/setup-windows.ps1 | iex
```

The script will install everything you need:
- Git (if not already installed)
- VS Code
- Volta and Node.js (LTS)
- GitHub CLI (and log you in)
- VS Code extensions (ESLint, Prettier, Tailwind, Copilot)
- Configure Git so your email stays private

---

## Step 3: Post your GitHub username to Slack

At the end of the script you'll see your GitHub username displayed.
Post it in the course Slack channel so we can add you to the private practice repo.

Once you've been added, you'll receive an invite to the practice repo where you'll make your first Pull Request.

---

## Manual setup (if the script doesn't work)

If the setup script fails or you're on an unsupported system, install everything manually using the links below.

### 1. Git

- **Windows:** [git-scm.com/downloads/win](https://git-scm.com/downloads/win)
- **macOS:** [git-scm.com/downloads/mac](https://git-scm.com/downloads/mac)
- **Linux:** [git-scm.com/downloads/linux](https://git-scm.com/downloads/linux)

### 2. VS Code

Download from [code.visualstudio.com](https://code.visualstudio.com/)

### 3. Volta and Node.js

1. Install Volta from [volta.sh](https://volta.sh/)
2. Then open a terminal and run:
   ```
   volta install node@lts
   ```

### 4. GitHub CLI

Install from [cli.github.com](https://cli.github.com/), then run:

```
gh auth login
```

When prompted, pick these options:
- **Where do you use GitHub?** → GitHub.com
- **Preferred protocol?** → HTTPS
- **Authenticate Git with GitHub?** → Yes
- **How to authenticate?** → Login with a web browser

### 5. VS Code extensions

Open VS Code and install these extensions (search by name in the Extensions panel, or click the links):

- [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
- [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
- [Tailwind CSS IntelliSense](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)
- [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot)
- [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat)

### 6. Configure Git email privacy

After logging into GitHub CLI, run these commands in your terminal (replace `Your Name` with your actual name):

```
git config --global user.name "Your Name"
```

To find your private email address, go to [github.com/settings/emails](https://github.com/settings/emails). Under **Primary email address** you'll see an address like `123456+username@users.noreply.github.com`. Copy it, then run:

```
git config --global user.email "YOUR_NOREPLY_EMAIL"
```

Make sure you also check **Keep my email addresses private** and **Block command line pushes that expose my email** on that same page.

# WAD Setup

Welcome! This guide sets up the tools you need for the course.

It takes about 10 minutes. Do the steps in order.

---

## Step 1: Hide your email

Every commit you make records an email address, and anyone can read it.
GitHub can hide your real one for you. Turn that on first.

1. Open [GitHub → Settings → Emails](https://github.com/settings/emails)
2. Tick **Keep my email addresses private**
3. Tick **Block command line pushes that expose my email**

The second box is your safety net. If your real email ever slips into a
commit, GitHub refuses the push instead of publishing it.

You do not need to copy any address by hand. The setup script does that
part for you.

---

## Step 2: Run the setup script

Copy the command for your computer and paste it into a terminal.

The script asks you a few questions while it runs, so stay at your desk.

### macOS / Linux

Open **Terminal** and run:

<!-- MAINTAINERS: pin this URL to a commit hash each semester. See "Updating this repo" below. -->

```bash
curl -fsSL https://raw.githubusercontent.com/ReDISchoolDK/web-app-dev-setup/9baedb52134f55bcb94030ca8f572e2f6c35f223/setup-mac.sh -o ~/redi-setup.sh && bash ~/redi-setup.sh
```

This saves the script to your home folder as `redi-setup.sh` and then runs
it. You can open that file and read it first if you want to see what it does.

Linux note: the script works on Ubuntu, Debian, Mint and Pop!_OS. On other
Linux systems, use the manual steps at the bottom of this page.

### Windows

Open **PowerShell** and run:

```powershell
irm https://raw.githubusercontent.com/ReDISchoolDK/web-app-dev-setup/9baedb52134f55bcb94030ca8f572e2f6c35f223/setup-windows.ps1 | iex
```

Windows may need a second run. If the script says some tools are not
visible yet, close the terminal, open a new one, and paste the same
command again. It picks up where it stopped.

### What it installs

- **Git** — tracks changes to your code
- **VS Code** — the editor we use in class
- **Volta** — keeps everyone on the same Node version
- **Node.js and pnpm** — runs your code and installs packages
- **GitHub CLI** — logs you into GitHub from the terminal
- **VS Code extensions** — Biome, Tailwind CSS IntelliSense
- It also sets up Git to use your hidden email

**Biome** is our linter and formatter. It spots mistakes and formats your
code when you save. Do not install Prettier as well. Two formatters fight
over the same file, and your code ends up looking different from everyone
else's.

**GitHub Copilot** ships built into VS Code now — chat, inline
suggestions, and agents all work out of the box. There is nothing to
install.

You do not have to pick a Node version. The course project tells Volta
which one to use, and Volta switches to it the moment you open the folder.

---

## Step 3: Send us your GitHub username

The script prints your GitHub username when it finishes.

Post it in the course Slack channel. We will add you to the practice repo,
where you will make your first Pull Request.

---

## Manual setup

Use this only if the script fails, or if you are on a Linux system it does
not support.

### 1. Git

- **Windows:** [git-scm.com/downloads/win](https://git-scm.com/downloads/win)
- **macOS:** [git-scm.com/downloads/mac](https://git-scm.com/downloads/mac)
- **Linux:** [git-scm.com/downloads/linux](https://git-scm.com/downloads/linux)

### 2. VS Code

Download it from [code.visualstudio.com](https://code.visualstudio.com/)

### 3. Volta, Node.js and pnpm

Install Volta from [volta.sh](https://volta.sh/). You need **version 2.0 or
newer** — older versions cannot install pnpm.

Then open a new terminal and run:

```
volta install node@lts
volta install pnpm@11
```

### 4. GitHub CLI

Install it from [cli.github.com](https://cli.github.com/), then run:

```
gh auth login
```

Pick these answers:

- **Where do you use GitHub?** → GitHub.com
- **Preferred protocol?** → HTTPS
- **Authenticate Git with GitHub?** → Yes
- **How to authenticate?** → Login with a web browser

### 5. VS Code extensions

Open VS Code and install these two:

- [Biome](https://marketplace.visualstudio.com/items?itemName=biomejs.biome)
- [Tailwind CSS IntelliSense](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)

GitHub Copilot isn't listed — it ships built into VS Code now, chat and
inline suggestions included. There is nothing to install.

### 6. Hide your email in Git

Set your name:

```
git config --global user.name "Your Name"
```

Now find your hidden email. Go to
[github.com/settings/emails](https://github.com/settings/emails) and look
under **Primary email address**. You will see something like
`123456+username@users.noreply.github.com`. Copy it and run:

```
git config --global user.email "PASTE_YOUR_ADDRESS_HERE"
```

The number at the front matters. An address without it gets rejected once
you tick **Block command line pushes**.

---

## Updating this repo (instructors)

The install commands above point at a fixed commit hash, not at `main`.
That way every student runs the exact same script, no matter which week
they start. Changing the script does not change what past students ran.

After you edit a script:

1. Commit the change and copy the new commit hash.
2. Replace the hash in both commands above.
3. Commit that as a separate change.

**Use a merge commit, not a squash merge.** Squashing replaces the commit
you pinned to with a brand new one, and the hash in the commands above
stops matching anything in this branch's history. If you do squash, redo
steps 1–3 against the squashed commit.

Bump the pinned Node and pnpm versions in the course project's
`package.json` between semesters, as a deliberate commit.

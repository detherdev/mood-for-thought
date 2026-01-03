# 🚀 GitHub Setup Guide

## Quick Commands (Copy & Paste)

### 1. Create GitHub Repo First
Go to https://github.com/new and create a new repository named `mood-for-thought`

### 2. Push Your Code

```bash
cd /Users/davey/Projects/moodappios

# Add your GitHub remote (REPLACE YOUR_USERNAME!)
git remote add origin https://github.com/YOUR_USERNAME/mood-for-thought.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### 3. Enable GitHub Pages

1. Go to your repo on GitHub
2. Click **Settings** → **Pages**
3. Under **Source**, select: **Branch: main** → **/ (root)**
4. Click **Save**
5. Wait 1-2 minutes

### 4. Your URLs Will Be:

**Privacy Policy (for App Store):**
```
https://YOUR_USERNAME.github.io/mood-for-thought/privacy-policy.html
```

**Landing Page:**
```
https://YOUR_USERNAME.github.io/mood-for-thought/
```

---

## ✅ What to Enter in App Store Connect:

| Field | Value |
|-------|-------|
| **Privacy Policy URL** | `https://YOUR_USERNAME.github.io/mood-for-thought/privacy-policy.html` |
| **Marketing URL** | `https://YOUR_USERNAME.github.io/mood-for-thought/` |
| **Support URL** | Same as above or use your email |

---

## 🔄 Future Updates

When you make changes:

```bash
cd /Users/davey/Projects/moodappios
git add .
git commit -m "Your update message"
git push
```

GitHub Pages will automatically update within 1-2 minutes!

---

## 🆘 Troubleshooting

### If git push fails:
```bash
# Check if remote is set correctly
git remote -v

# Should show:
# origin  https://github.com/YOUR_USERNAME/mood-for-thought.git (fetch)
# origin  https://github.com/YOUR_USERNAME/mood-for-thought.git (push)
```

### If you need to change the remote:
```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/mood-for-thought.git
```

### If GitHub asks for credentials:
Use a Personal Access Token instead of password:
1. Go to GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token with `repo` scope
3. Use token as password

---

## ✨ You're All Set!

Once pushed and GitHub Pages is enabled, your privacy policy will be live and ready for App Store submission! 🎉


#!/bin/bash

# ============================================================================
# ENTERPRISE AUTH SYSTEM - ONE-COMMAND GITHUB PUSH
# ============================================================================
# This script does EVERYTHING for you. Just run it!
# ============================================================================

set -e  # Exit on error

echo "🚀 Starting GitHub push for Enterprise Auth System..."
echo ""

# ============================================================================
# STEP 1: Navigate to project directory
# ============================================================================
echo "📁 Step 1: Navigating to project directory..."
cd /home/claude/enterprise-auth-system
echo "✅ In directory: $(pwd)"
echo ""

# ============================================================================
# STEP 2: Initialize git (if not already initialized)
# ============================================================================
echo "🔧 Step 2: Initializing git..."
if [ -d .git ]; then
    echo "✅ Git already initialized, skipping..."
else
    git init
    echo "✅ Git initialized"
fi
echo ""

# ============================================================================
# STEP 3: Add all files
# ============================================================================
echo "📝 Step 3: Adding all files to git..."
git add .
echo "✅ All files added"
echo ""

# ============================================================================
# STEP 4: Check git status
# ============================================================================
echo "📊 Step 4: Checking git status..."
echo "---"
git status
echo "---"
echo ""

# ============================================================================
# STEP 5: Create initial commit
# ============================================================================
echo "💾 Step 5: Creating initial commit..."
git commit -m "Initial commit: Enterprise authentication system with Spring Boot + Angular + PostgreSQL"
echo "✅ Commit created"
echo ""

# ============================================================================
# STEP 6: Rename branch to main
# ============================================================================
echo "🌿 Step 6: Setting up main branch..."
git branch -M main
echo "✅ Branch renamed to 'main'"
echo ""

# ============================================================================
# STEP 7: Add GitHub remote
# ============================================================================
echo "🔗 Step 7: Adding GitHub remote..."
echo ""
echo "⚠️  IMPORTANT: You need your GitHub username!"
echo "Go to: https://github.com/new"
echo ""
echo "Enter your GitHub username (e.g., NMSP19):"
read GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ Username required! Exiting..."
    exit 1
fi

REPO_URL="https://github.com/${GITHUB_USERNAME}/enterprise-auth-system.git"
echo "Using repository: $REPO_URL"
echo ""

# Remove existing remote if it exists
git remote remove origin 2>/dev/null || true

# Add new remote
git remote add origin "$REPO_URL"
echo "✅ GitHub remote added"
echo ""

# ============================================================================
# STEP 8: Push to GitHub
# ============================================================================
echo "📤 Step 8: Pushing code to GitHub..."
echo ""
echo "⚠️  IMPORTANT: You may be asked for authentication!"
echo "Two options:"
echo "  1. GitHub Personal Access Token (recommended)"
echo "  2. GitHub username & password"
echo ""
echo "Getting token? Go to: https://github.com/settings/tokens"
echo ""

git push -u origin main

echo ""
echo "✅ Code pushed to GitHub!"
echo ""

# ============================================================================
# STEP 9: Verify on GitHub
# ============================================================================
echo "🎉 Step 9: Verification"
echo "---"
echo "✅ Project pushed successfully!"
echo ""
echo "Your GitHub repository:"
echo "📍 https://github.com/${GITHUB_USERNAME}/enterprise-auth-system"
echo ""
echo "Next steps:"
echo "1. Go to the URL above"
echo "2. Verify all files are there"
echo "3. Share the link with recruiters"
echo ""
echo "---"
echo ""

# ============================================================================
# FINAL MESSAGE
# ============================================================================
echo "🚀 SUCCESS! Your project is now on GitHub!"
echo ""
echo "What to do next:"
echo "1. Visit: https://github.com/${GITHUB_USERNAME}/enterprise-auth-system"
echo "2. Click ⭐ (Star your own repo - helps with recruiting)"
echo "3. Add link to LinkedIn profile"
echo "4. Send link to recruiters"
echo ""
echo "Tell recruiters:"
echo "  'I built an enterprise authentication system with Spring Boot,"
echo "   Angular, and PostgreSQL. It demonstrates full-stack security"
echo "   knowledge with JWT tokens, RBAC, and session management.'"
echo ""
echo "For interview prep:"
echo "  Read: /home/claude/enterprise-auth-system/docs/INTERVIEW_GUIDE.md"
echo ""
echo "Good luck! You've got this! 💪"
echo ""

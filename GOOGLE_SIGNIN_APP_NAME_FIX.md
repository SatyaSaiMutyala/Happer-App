# Fix Google Sign-In App Name Display

## Problem:
Google Sign-In shows "project-287519573282" instead of "Happer"

## Solution:

### Step 1: Go to Google Cloud Console
1. Visit: https://console.cloud.google.com/
2. Select your project: **project-287519573282**

### Step 2: Configure OAuth Consent Screen
1. In the left menu, go to: **APIs & Services** → **OAuth consent screen**
   - Or direct link: https://console.cloud.google.com/apis/credentials/consent

2. Click **EDIT APP** button

3. Under **App information**:
   - **App name**: Change from "project-287519573282" to "Happer"
   - **User support email**: Add your email
   - **App logo** (optional): Upload Happer logo
   - **Application home page** (optional): https://happer.fr
   - **Application privacy policy link** (optional): Your privacy policy URL
   - **Application terms of service link** (optional): Your terms URL

4. Click **SAVE AND CONTINUE**

5. Continue through the remaining steps:
   - **Scopes**: Keep existing (email, profile)
   - **Test users**: Add test emails if needed
   - Click **SAVE AND CONTINUE** until done

6. Click **BACK TO DASHBOARD**

### Step 3: Test
1. Close your app completely
2. Clear app data (or uninstall/reinstall)
3. Try Google Sign-In again
4. You should now see "Choose an account to continue to **Happer**"

## Notes:
- Changes may take a few minutes to propagate
- You might need to clear browser cache/app data to see changes
- Make sure your app is published (not in testing mode) for all users to see the new name

## Your Project Details:
- Project ID: project-287519573282
- New App Name: Happer
- Bundle ID: fr.happer.app

# Vapi Simple Call Button - Quick Setup Guide

This is a standalone HTML page that lets you make calls to **+31633690627** using Vapi with a single button click.

## Features

- 🎯 **Simple & Direct**: No n8n or Docker required
- 🔒 **Secure**: Credentials stored in browser localStorage
- 📱 **Hardcoded Number**: Calls +31633690627 automatically
- 🎨 **Beautiful UI**: Modern, responsive interface
- ⚡ **Fast**: Direct API calls to Vapi

## Quick Start

### 1. Get Your Vapi Credentials

You need two things from [https://dashboard.vapi.ai/](https://dashboard.vapi.ai/):

1. **API Key**: Found in Settings → API Keys
2. **Assistant ID**: Create an assistant or use an existing one

### 2. Open the HTML File

Simply open `vapi-simple-call-button.html` in your web browser:

```bash
# Option 1: Open directly
open vapi-simple-call-button.html  # macOS
xdg-open vapi-simple-call-button.html  # Linux
start vapi-simple-call-button.html  # Windows

# Option 2: Use a local web server (recommended)
python3 -m http.server 8000
# Then open: http://localhost:8000/vapi-simple-call-button.html
```

### 3. Configure Your Credentials

1. Enter your **Vapi API Key**
2. Enter your **Assistant ID**
3. Click **"Save Configuration"**

Your credentials will be saved in your browser for future use.

### 4. Make a Call

Click the **"Make Call"** button and the system will:
- Call **+31633690627** using your Vapi assistant
- Show real-time status updates
- Display the call ID when successful

## How It Works

The HTML page makes a direct API call to Vapi:

```javascript
POST https://api.vapi.ai/call/phone
Headers: Authorization: Bearer YOUR_API_KEY
Body: {
  "assistantId": "YOUR_ASSISTANT_ID",
  "customer": {
    "number": "+31633690627"
  }
}
```

## Troubleshooting

### "Failed to initiate call" Error

**Possible causes:**
1. Invalid API Key or Assistant ID
2. Insufficient Vapi credits
3. Assistant not properly configured
4. Phone number format issue

**Solutions:**
- Verify credentials in Vapi dashboard
- Check your Vapi account balance
- Ensure your assistant is active and configured
- Check browser console (F12) for detailed error messages

### Button is Disabled

The button is disabled until you save valid credentials. Make sure to:
1. Fill in both fields
2. Click "Save Configuration"
3. Look for "✓ Configuration ready" message

### CORS Errors

If you see CORS errors in the browser console:
- Serve the HTML file through a web server instead of opening it directly
- Use: `python3 -m http.server 8000`

## Changing the Phone Number

To call a different number, edit line 219 in `vapi-simple-call-button.html`:

```javascript
const PHONE_NUMBER = '+31633690627';  // Change this number
```

Also update the display on line 178:

```html
<div class="phone-number-value">+31 6 3369 0627</div>
```

## Security Notes

- Credentials are stored in browser localStorage (client-side only)
- Never share your API key publicly
- Clear credentials: Open browser DevTools → Application → Local Storage → Delete items

## Files

- `vapi-simple-call-button.html` - The main HTML page with button and UI
- `VAPI_SIMPLE_CALL_SETUP.md` - This setup guide

## Need Help?

- Vapi Documentation: https://docs.vapi.ai/
- Vapi Dashboard: https://dashboard.vapi.ai/
- Vapi API Reference: https://docs.vapi.ai/api-reference

---

**Created for quick Vapi testing and outbound call automation**

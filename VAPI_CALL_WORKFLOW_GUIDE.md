# Vapi Call Button Workflow Guide

This guide will walk you through setting up and using the n8n workflow to make outbound phone calls via Vapi with a simple button click.

---

## 📋 Table of Contents

1. [What You'll Build](#what-youll-build)
2. [Prerequisites](#prerequisites)
3. [Step 1: Import the Workflow](#step-1-import-the-workflow)
4. [Step 2: Configure the Workflow](#step-2-configure-the-workflow)
5. [Step 3: Activate the Workflow](#step-3-activate-the-workflow)
6. [Step 4: Test with the Button](#step-4-test-with-the-button)
7. [How It Works](#how-it-works)
8. [Troubleshooting](#troubleshooting)
9. [Customization](#customization)

---

## 🎯 What You'll Build

You'll create a system where:
1. You click a button in your browser (or send a POST request)
2. n8n receives the request via a webhook
3. n8n calls Vapi's API to initiate a phone call
4. The specified phone number rings with your Vapi assistant

---

## ✅ Prerequisites

Before you begin, make sure you have:

- [x] n8n running (via Docker)
- [x] ngrok tunnel active and pointing to port 5678
- [x] Vapi API key in your `.env` file
- [x] A Vapi Assistant created (you'll need the Assistant ID)
- [x] (Optional) A phone number configured in Vapi or ready to dial

---

## Step 1: Import the Workflow

### Option A: Using the n8n Web Interface

1. **Open n8n** in your browser:
   ```
   http://localhost:5678
   ```

2. **Click on "Workflows" → "Import from File"** (or press Ctrl/Cmd + I)

3. **Select the workflow file:**
   ```
   n8n-workflows/vapi-call-button.json
   ```

4. **Click "Import"**

The workflow will appear with 4 nodes:
- **Webhook Trigger** - Listens for button clicks
- **Call Vapi API** - Makes the API request to Vapi
- **Success Response** - Returns success message
- **Error Response** - Handles errors

### Option B: Manual Creation

If you prefer to create it manually:

1. Create a new workflow in n8n
2. Add a **Webhook** node:
   - Method: POST
   - Path: `vapi-call-button`
   - Respond: Using 'Respond to Webhook' node

3. Add an **HTTP Request** node:
   - Method: POST
   - URL: `https://api.vapi.ai/call/phone`
   - Add Header: `Authorization` = `Bearer {{ $env.VAPI_API_KEY }}`
   - Body (JSON):
     ```json
     {
       "assistantId": "{{ $env.VAPI_ASSISTANT_ID }}",
       "customer": {
         "number": "{{ $json.body.phoneNumber || $env.VAPI_PHONE_NUMBER }}"
       }
     }
     ```

4. Add two **Respond to Webhook** nodes (one for success, one for error)

---

## Step 2: Configure the Workflow

### 2.1 Set Up Your Environment Variables

Make sure your `.env` file has these values:

```env
# Required
VAPI_API_KEY=sk_live_xxxxxxxxxxxxxxxx

# Required - Your Vapi Assistant ID
VAPI_ASSISTANT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Optional - Default phone number to call
VAPI_PHONE_NUMBER=+1234567890

# Required for webhooks
WEBHOOK_URL=https://your-ngrok-url.ngrok.io
```

**Where to find these:**

- **VAPI_API_KEY**:
  - Go to [Vapi Dashboard](https://dashboard.vapi.ai/)
  - Click "API Keys" in the sidebar
  - Copy your private key (starts with `sk_live_`)

- **VAPI_ASSISTANT_ID**:
  - Go to [Vapi Dashboard](https://dashboard.vapi.ai/)
  - Click "Assistants" in the sidebar
  - Click on your assistant
  - Copy the ID from the URL or the assistant details
  - Format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

- **VAPI_PHONE_NUMBER** (optional):
  - Your default phone number to call
  - Format: `+1234567890` (include country code)

### 2.2 Restart n8n

After updating `.env`, restart n8n to load the new variables:

```bash
docker-compose restart
```

### 2.3 Verify ngrok is Running

Make sure your ngrok tunnel is active:

```bash
ngrok http 5678
```

You should see:
```
Forwarding  https://abc123.ngrok.io -> http://localhost:5678
```

Copy the HTTPS URL (e.g., `https://abc123.ngrok.io`) - you'll need it!

---

## Step 3: Activate the Workflow

1. **Open the workflow** in n8n

2. **Click the "Webhook Trigger" node**

3. **Copy the webhook URL**:
   - It should look like: `https://abc123.ngrok.io/webhook/vapi-call-button`
   - This is your ngrok URL + the webhook path

4. **Click "Activate"** in the top right corner
   - The toggle should turn green/blue
   - The workflow is now listening for requests!

5. **Test the webhook** (optional):
   ```bash
   curl -X POST https://abc123.ngrok.io/webhook/vapi-call-button \
     -H "Content-Type: application/json" \
     -d '{"phoneNumber": "+1234567890"}'
   ```

---

## Step 4: Test with the Button

### Option A: Use the HTML Button Interface

1. **Open the HTML file** in your browser:
   ```
   file:///path/to/n8n_vapi/call-button.html
   ```

   Or serve it locally:
   ```bash
   # Using Python 3
   python3 -m http.server 8000
   ```
   Then open: `http://localhost:8000/call-button.html`

2. **Enter your webhook URL**:
   - Paste: `https://abc123.ngrok.io/webhook/vapi-call-button`
   - The URL is saved automatically for next time

3. **Enter a phone number** (optional):
   - Leave empty to use `VAPI_PHONE_NUMBER` from `.env`
   - Or enter a specific number: `+1234567890`

4. **Click "Make Call Now"** 🎯

5. **Wait for the response**:
   - ✅ Success: You'll see the call ID and phone number
   - ❌ Error: You'll see the error message

### Option B: Use curl

```bash
# Call the default number from .env
curl -X POST https://abc123.ngrok.io/webhook/vapi-call-button \
  -H "Content-Type: application/json" \
  -d '{}'

# Call a specific number
curl -X POST https://abc123.ngrok.io/webhook/vapi-call-button \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber": "+1234567890"}'
```

### Option C: Use Postman or Insomnia

1. Create a new POST request
2. URL: `https://abc123.ngrok.io/webhook/vapi-call-button`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON):
   ```json
   {
     "phoneNumber": "+1234567890"
   }
   ```
5. Send!

---

## 🔍 How It Works

Here's the flow when you press the button:

1. **Button Click** (or API request)
   - Sends POST request to your n8n webhook
   - Payload: `{ "phoneNumber": "+1234567890" }` (optional)

2. **Webhook Trigger** (n8n)
   - Receives the request
   - Extracts the phone number (if provided)
   - Passes data to the next node

3. **Call Vapi API** (n8n → Vapi)
   - Makes POST request to `https://api.vapi.ai/call/phone`
   - Headers: `Authorization: Bearer {your-api-key}`
   - Body:
     ```json
     {
       "assistantId": "your-assistant-id",
       "customer": {
         "number": "+1234567890"
       }
     }
     ```

4. **Vapi Response**
   - If successful: Returns call details (ID, status, etc.)
   - If error: Returns error message

5. **Response to User** (n8n → Browser)
   - Success: `{ "success": true, "callId": "...", ... }`
   - Error: `{ "success": false, "error": "..." }`

6. **Phone Rings!** 📞
   - The specified phone number receives a call
   - Your Vapi assistant starts the conversation

---

## 🐛 Troubleshooting

### Issue: "Could not connect to n8n"

**Possible causes:**
- n8n is not running
- Webhook URL is incorrect
- Workflow is not activated

**Solutions:**
```bash
# Check if n8n is running
docker-compose ps

# Restart n8n
docker-compose restart

# Check logs
docker-compose logs -f n8n
```

### Issue: "Failed to initiate call"

**Possible causes:**
- Invalid Vapi API key
- Invalid Assistant ID
- Invalid phone number format
- Insufficient Vapi credits

**Solutions:**
1. Verify your `.env` file has correct values
2. Check [Vapi Dashboard](https://dashboard.vapi.ai/) for API key
3. Ensure phone number includes country code: `+1234567890`
4. Check Vapi account has credits/active subscription

### Issue: "Assistant ID not found"

**Solution:**
1. Go to [Vapi Dashboard](https://dashboard.vapi.ai/)
2. Navigate to "Assistants"
3. Copy the correct Assistant ID
4. Update `VAPI_ASSISTANT_ID` in `.env`
5. Restart n8n: `docker-compose restart`

### Issue: Webhook URL changes after restarting ngrok

**Solution:**
- Free ngrok URLs change on restart
- Either:
  - Update the webhook URL in the HTML button each time
  - Get a paid ngrok plan for a static URL
  - Use Cloudflare Tunnel instead (free static URLs)

### Debug Mode

To see detailed logs in n8n:

1. Edit `.env`:
   ```env
   N8N_LOG_LEVEL=debug
   ```

2. Restart:
   ```bash
   docker-compose restart
   ```

3. View logs:
   ```bash
   docker-compose logs -f n8n
   ```

---

## 🎨 Customization

### Change the Phone Number Dynamically

You can pass different numbers in the request:

```javascript
// JavaScript example
fetch('https://abc123.ngrok.io/webhook/vapi-call-button', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    phoneNumber: '+1234567890'
  })
});
```

### Add Multiple Buttons for Different Numbers

Modify `call-button.html`:

```html
<button onclick="makeCall('+1111111111')">Call Customer Support</button>
<button onclick="makeCall('+2222222222')">Call Sales Team</button>
<button onclick="makeCall('+3333333333')">Call Manager</button>
```

### Pass Custom Data to the Assistant

Modify the "Call Vapi API" node to include custom variables:

```json
{
  "assistantId": "{{ $env.VAPI_ASSISTANT_ID }}",
  "customer": {
    "number": "{{ $json.body.phoneNumber }}",
    "name": "{{ $json.body.customerName }}"
  },
  "assistantOverrides": {
    "variableValues": {
      "customerName": "{{ $json.body.customerName }}",
      "orderId": "{{ $json.body.orderId }}"
    }
  }
}
```

Then send:
```bash
curl -X POST https://abc123.ngrok.io/webhook/vapi-call-button \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumber": "+1234567890",
    "customerName": "John Doe",
    "orderId": "12345"
  }'
```

### Schedule Automatic Calls

1. Add a **Schedule Trigger** node instead of Webhook
2. Set the schedule (e.g., "Every day at 9am")
3. Connect to the "Call Vapi API" node
4. Activate!

### Call Multiple Numbers in Sequence

1. Add a **Function** node with an array of numbers
2. Add a **Split in Batches** node
3. Loop through each number
4. Call Vapi API for each one

---

## 📚 Next Steps

Now that you have a working call button, you can:

1. **Create more complex workflows**:
   - Call different assistants based on time of day
   - Log call results to a database
   - Send email notifications when calls complete

2. **Integrate with other services**:
   - Trigger calls from your CRM
   - Call customers after form submissions
   - Automate follow-up calls

3. **Build a UI**:
   - Create a dashboard with multiple call buttons
   - Add call history tracking
   - Display call analytics

4. **Explore Vapi features**:
   - Create different assistants for different purposes
   - Use webhooks to receive call events
   - Implement dynamic responses during calls

---

## 🔗 Useful Resources

- [Vapi Documentation](https://docs.vapi.ai/)
- [Vapi API Reference](https://docs.vapi.ai/api-reference)
- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)

---

## 🆘 Need Help?

If you run into issues:

1. Check the [Troubleshooting](#troubleshooting) section
2. Look at n8n logs: `docker-compose logs -f n8n`
3. Test the Vapi API directly with curl
4. Check Vapi Dashboard for call logs and errors
5. Visit the [n8n Community](https://community.n8n.io/)

---

**Happy calling! 📞**

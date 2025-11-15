# n8n + Vapi Local Development Setup

This repository provides a complete Docker-based setup for running n8n with Vapi integration locally.

## 📚 Table of Contents

- [What is What?](#what-is-what)
- [Prerequisites](#prerequisites)
- [Installation Steps](#installation-steps)
- [Configuration](#configuration)
- [Using n8n with Vapi](#using-n8n-with-vapi)
- [Common Workflows](#common-workflows)
- [Troubleshooting](#troubleshooting)
- [Useful Resources](#useful-resources)

---

## 🤔 What is What?

### n8n
**n8n** (pronounced "n-eight-n") is a **workflow automation tool** that lets you connect different apps and services together without writing code (or with code if you prefer). Think of it like Zapier or Make.com, but:
- **Open source** - you can host it yourself
- **Self-hostable** - your data stays on your servers
- **Extendable** - you can create custom nodes and workflows
- **Developer-friendly** - supports JavaScript, webhooks, and APIs

**Use cases:**
- Automate repetitive tasks
- Connect APIs together
- Process data between systems
- Create chatbots and voice assistants
- Handle webhooks from various services

### Vapi
**Vapi** is a **voice AI platform** that lets you build voice agents/assistants that can:
- Make and receive phone calls
- Have natural conversations using AI (GPT, Claude, etc.)
- Integrate with your business logic via webhooks
- Handle inbound/outbound calls programmatically

**Use cases:**
- Customer service voice bots
- Appointment booking over the phone
- Voice-based surveys or data collection
- Automated outbound calling campaigns

### How They Work Together
n8n can:
1. **Receive webhooks** from Vapi when calls start, end, or when the assistant needs data
2. **Process that data** (check databases, call other APIs, run logic)
3. **Send data back** to Vapi to continue the conversation
4. **Trigger actions** based on call outcomes (send emails, update CRM, etc.)

### Docker & Docker Compose
- **Docker**: A tool that packages applications with all their dependencies into "containers" so they run the same everywhere
- **Docker Compose**: A tool to define and run multi-container Docker applications using a YAML file

**Why use Docker for this?**
- ✅ Consistent environment (works the same on Mac, Windows, Linux)
- ✅ Easy setup (no manual installation of n8n dependencies)
- ✅ Isolated (doesn't interfere with other software on your computer)
- ✅ Easy cleanup (just delete the containers)

---

## ✅ Prerequisites

Before starting, make sure you have:

1. **Docker Desktop** installed
   - [Download for Mac](https://docs.docker.com/desktop/install/mac-install/)
   - [Download for Windows](https://docs.docker.com/desktop/install/windows-install/)
   - [Download for Linux](https://docs.docker.com/desktop/install/linux-install/)

   Verify installation:
   ```bash
   docker --version
   docker-compose --version
   ```

2. **Vapi Account** (free tier available)
   - Sign up at [https://vapi.ai/](https://vapi.ai/)
   - Get your API key from the [Vapi Dashboard](https://dashboard.vapi.ai/)

3. **A tunneling tool** for local development (choose one):
   - [ngrok](https://ngrok.com/) (recommended for beginners)
   - [Cloudflare Tunnel](https://www.cloudflare.com/products/tunnel/)
   - [localtunnel](https://localtunnel.github.io/www/)

   **Why?** Vapi needs a public URL to send webhooks to your local n8n instance.

---

## 🚀 Installation Steps

### Step 1: Clone the Repository

```bash
git clone <your-repo-url>
cd n8n_vapi
```

### Step 2: Configure Environment Variables

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your favorite text editor:
   ```bash
   nano .env  # or use vim, vscode, etc.
   ```

3. Fill in your Vapi credentials:
   ```env
   VAPI_API_KEY=your_actual_vapi_api_key
   VAPI_PHONE_NUMBER=+1234567890  # if you have one
   VAPI_ASSISTANT_ID=your_assistant_id  # optional
   ```

   **Where to find these:**
   - `VAPI_API_KEY`: Vapi Dashboard → Settings → API Keys
   - `VAPI_PHONE_NUMBER`: Vapi Dashboard → Phone Numbers
   - `VAPI_ASSISTANT_ID`: Vapi Dashboard → Assistants

### Step 3: Start n8n

```bash
docker-compose up -d
```

**What this does:**
- Downloads the n8n Docker image (first time only)
- Creates a Docker container named `n8n_vapi`
- Starts n8n on port 5678
- Creates a Docker volume to persist your workflows

**Check if it's running:**
```bash
docker-compose ps
```

You should see:
```
NAME       IMAGE              STATUS
n8n_vapi   n8nio/n8n:latest   Up X seconds (healthy)
```

### Step 4: Access n8n

Open your browser and go to:
```
http://localhost:5678
```

You'll see the n8n welcome screen. Create your account (this is local only, no data leaves your machine).

### Step 5: Set Up Public URL for Webhooks (Required for Vapi)

Vapi needs to send webhooks to your n8n, but `localhost` isn't accessible from the internet. Use a tunnel:

#### Using ngrok (Recommended):

1. Install ngrok:
   ```bash
   # Mac
   brew install ngrok

   # Windows
   choco install ngrok

   # Or download from https://ngrok.com/download
   ```

2. Start the tunnel:
   ```bash
   ngrok http 5678
   ```

3. You'll see output like:
   ```
   Forwarding   https://abc123.ngrok.io -> http://localhost:5678
   ```

4. Update your `.env` file:
   ```env
   WEBHOOK_URL=https://abc123.ngrok.io
   ```

5. Restart n8n to apply changes:
   ```bash
   docker-compose restart
   ```

**Important:** The ngrok URL changes every time you restart ngrok (unless you have a paid plan). You'll need to update your Vapi webhooks when the URL changes.

---

## ⚙️ Configuration

### Environment Variables Explained

| Variable | Description | Example |
|----------|-------------|---------|
| `N8N_HOST` | Hostname for n8n | `localhost` |
| `N8N_PROTOCOL` | HTTP or HTTPS | `http` |
| `WEBHOOK_URL` | Public URL for webhooks | `https://abc123.ngrok.io` |
| `TIMEZONE` | Your timezone | `America/New_York` |
| `N8N_BASIC_AUTH_ACTIVE` | Enable password protection | `false` |
| `VAPI_API_KEY` | Your Vapi API key | `sk_live_...` |
| `N8N_LOG_LEVEL` | Logging verbosity | `info` |

### Optional: Enable Basic Authentication

To password-protect your n8n instance:

1. Edit `.env`:
   ```env
   N8N_BASIC_AUTH_ACTIVE=true
   N8N_BASIC_AUTH_USER=admin
   N8N_BASIC_AUTH_PASSWORD=your_secure_password
   ```

2. Restart:
   ```bash
   docker-compose restart
   ```

### Optional: Use PostgreSQL Instead of SQLite

By default, n8n uses SQLite (a file-based database). For production-like setups, use PostgreSQL:

1. Uncomment the PostgreSQL section in `docker-compose.yml`
2. Add to your n8n environment in `docker-compose.yml`:
   ```yaml
   - DB_TYPE=postgresdb
   - DB_POSTGRESDB_HOST=postgres
   - DB_POSTGRESDB_PORT=5432
   - DB_POSTGRESDB_DATABASE=${POSTGRES_DB}
   - DB_POSTGRESDB_USER=${POSTGRES_USER}
   - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
   ```
3. Restart: `docker-compose up -d`

---

## 🎯 Using n8n with Vapi

### Example 1: Receive Vapi Call Events

When a Vapi call happens, you can receive webhook events in n8n.

1. **Create a webhook in n8n:**
   - Click "Add first workflow"
   - Add a "Webhook" node
   - Set method to `POST`
   - Copy the webhook URL (e.g., `https://abc123.ngrok.io/webhook/vapi-calls`)

2. **Configure Vapi to send webhooks:**
   - Go to Vapi Dashboard → Assistants → Your Assistant
   - Under "Server URL", paste your n8n webhook URL
   - Vapi will now send events like:
     - `assistant-request` - when the assistant needs data
     - `end-of-call-report` - when a call ends
     - `status-update` - call status changes

3. **Process the webhook in n8n:**
   - Add nodes to handle the incoming data
   - Example: Send an email when a call ends
   - Save and activate your workflow

### Example 2: Make Outbound Calls via Vapi

1. **Create a workflow in n8n:**
   - Add a "Schedule" trigger (or webhook, or manual trigger)
   - Add an "HTTP Request" node

2. **Configure the HTTP Request:**
   ```
   Method: POST
   URL: https://api.vapi.ai/call/phone
   Authentication: Header Auth
     Name: Authorization
     Value: Bearer {{ $env.VAPI_API_KEY }}

   Body (JSON):
   {
     "assistantId": "{{ $env.VAPI_ASSISTANT_ID }}",
     "customer": {
       "number": "+1234567890"
     }
   }
   ```

3. **Activate the workflow** and test!

### Example 3: Dynamic Responses

Vapi can call your n8n webhook to get dynamic data during a call:

1. **Set up a webhook in n8n** that returns JSON
2. **Configure in Vapi:**
   - In your assistant's configuration, set the Server URL to your webhook
   - When the assistant needs data, it will call your n8n webhook
   - Your workflow processes the request and returns data
   - The assistant uses that data in the conversation

---

## 🔄 Common Workflows

### Starting and Stopping n8n

```bash
# Start n8n
docker-compose up -d

# Stop n8n
docker-compose down

# Stop and remove all data (⚠️ deletes workflows)
docker-compose down -v

# View logs
docker-compose logs -f n8n

# Restart n8n
docker-compose restart
```

### Backing Up Your Workflows

Your workflows are stored in a Docker volume. To back them up:

```bash
# Export all workflows from n8n UI:
# Settings → Export → Download all workflows

# Or copy the Docker volume
docker run --rm -v n8n_vapi_n8n_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/n8n-backup.tar.gz -C /data .
```

### Updating n8n

```bash
# Pull the latest image
docker-compose pull

# Restart with the new version
docker-compose up -d
```

---

## 🐛 Troubleshooting

### n8n won't start

```bash
# Check logs
docker-compose logs n8n

# Common issues:
# - Port 5678 already in use → change port in docker-compose.yml
# - Permission issues → check Docker Desktop is running
```

### Vapi webhooks not received

1. **Check your tunnel is running:**
   ```bash
   # ngrok should show HTTP requests
   ```

2. **Verify the webhook URL:**
   - n8n webhook URL should match what's in Vapi
   - Should use the ngrok HTTPS URL, not localhost

3. **Check n8n workflow is active:**
   - Make sure you clicked "Activate" on your workflow

4. **Test the webhook manually:**
   ```bash
   curl -X POST https://your-ngrok-url.ngrok.io/webhook/test \
     -H "Content-Type: application/json" \
     -d '{"test": "data"}'
   ```

### Can't access environment variables in n8n

Environment variables are accessed in n8n using: `{{ $env.VARIABLE_NAME }}`

Example:
```javascript
// In a Code node
const apiKey = $env.VAPI_API_KEY;
```

---

## 📚 Useful Resources

### n8n Documentation
- [n8n Docs](https://docs.n8n.io/)
- [n8n Workflows](https://n8n.io/workflows/)
- [n8n Community](https://community.n8n.io/)

### Vapi Documentation
- [Vapi Docs](https://docs.vapi.ai/)
- [Vapi API Reference](https://docs.vapi.ai/api-reference)
- [Vapi Dashboard](https://dashboard.vapi.ai/)

### Docker
- [Docker Docs](https://docs.docker.com/)
- [Docker Compose Docs](https://docs.docker.com/compose/)

### Tunneling Tools
- [ngrok Docs](https://ngrok.com/docs)
- [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)

---

## 🤝 Contributing

Feel free to open issues or submit pull requests to improve this setup!

---

## 📝 License

MIT License - feel free to use this for your projects!

---

## 💡 Next Steps

1. ✅ Complete the installation above
2. 🎓 Follow the [n8n quickstart](https://docs.n8n.io/quickstart/)
3. 🎤 Create your first [Vapi assistant](https://docs.vapi.ai/quickstart)
4. 🔗 Connect them together using webhooks
5. 🚀 Build something awesome!

Need help? Check the troubleshooting section or reach out to the communities linked above.

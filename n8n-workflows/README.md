# n8n Workflows Directory

This directory is mounted to the n8n container and can be used to store workflow backups and exports.

## How to Use

### Exporting Workflows

1. **From n8n UI:**
   - Open n8n at `http://localhost:5678`
   - Go to Settings → Workflows
   - Click "Export" to download workflows as JSON files
   - Save them in this directory

2. **Automatic backups:**
   - Any workflows you create in n8n are automatically saved in the Docker volume
   - This directory can be used for manual backups and version control

### Importing Workflows

1. Place `.json` workflow files in this directory
2. In n8n UI, go to Settings → Workflows → Import
3. Select the workflow file to import

## Example Vapi Workflows

You can create workflows like:

- **Receive Call Webhooks**: Handle incoming Vapi call events
- **Make Outbound Calls**: Trigger Vapi calls based on schedules or events
- **Process Call Data**: Store call logs, send notifications, update databases

## Tips

- Use descriptive filenames: `vapi-call-handler.json`, `outbound-caller.json`
- Version control your workflows by committing them to git
- Test workflows before deploying to production

For more examples, check the [n8n workflow gallery](https://n8n.io/workflows/).

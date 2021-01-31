# Zendesk Helper

Application that synchronizes tickets in Zendesk with threads in Slack.

1. When the status of a ticket, which is associated with a thread in Slack, is updated in Zendesk, the bot sets a reaction to the original thread message and writes a message to the Slack thread itself notifying about the current status of the ticket.
2. When new messages appear in Slack in a thread that is associated with a ticket to Zendesk, the ticket status changes to "Open".
3. All messages that are written to the Slack thread, which is associated with a ticket to Zendesk, are saved in the Zendesk ticket as an internal note.

All you need is:
* Set up Helper;
* Configurate sending Slack params (thread ts and thread reply count) to Zendesk ticket's custom fields;
* Configurate scheduler and run it.

# Installation

Set up gems:
```bush
bundle install
```

# Usage

## Configuration

Go `config/secrets.yml.sample` for sample configuration. Set up all needed params.

`default_locale: 'ru'`

### Slack

1. Create a new app: https://api.slack.com/apps?new_app=1
2. Set up Scopes: https://i.imgur.com/Acz4UWw.png
3. Install App to Workspace
4. Set config params in `config/secrets.yml`

```ruby
slack_host: 'https://yourdomain.slack.com/' # Workspace url
slack_access_token: 'xoxb-' # Bot User OAuth Access Token (OAuth & Permissions)
slack_token_auth_type: 'Bearer' # Default value
slack_bot_user_id: '' # Bot id
```

### Zendesk

1. Create a new Oauth client: https://yourdomain.zendesk.com/agent/admin/api/oauth_clients
3. Create custom fields (thread_ts & reply_count) for tickets: https://yourdomain.zendesk.com/agent/admin/ticket_fields
2. Set config params in `config/secrets.yml`

```ruby
zd_host: 'https://yourdomain.zendesk.com/' # Workspace url
zd_client_id: '' # Oauth client id
zd_client_secret: '' # Oauth client secret
zd_username: '' # Workspace admin login (email)
zd_password: '' # Workspace admin password
zd_token_auth_type: 'Bearer' # Default value
slack_thread_ts_field_id: '' # Custom field id for thread ts: https://i.imgur.com/8jKnjSL.png
slack_reply_count_field_id: '' # Custom field id for reply count: https://i.imgur.com/8jKnjSL.png
```

# Deploy

Setup ssh config for production server
Push all changes
and run:

```bash
bundle exec cap production deploy
```

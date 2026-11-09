admin_password_version = 0
administrator_login    = "relaydevadmin"

server = {
  name = "psql-relay-dev"
}

# Metadata of the Entra app and its portal-created client secret.
app = {
  display_name = "app-relay-dev"
  client_id    = "6f1c2a90-3d4e-4b77-9a10-relaydev01"
  object_id    = "8b2d4c11-5e6f-4a88-bb23-relayobj01"
}

portal_credential = {
  key_id       = "c4a1e872-9b3d-4f60-8e21-relaykey01"
  start_date   = "2026-09-20T08:00:00Z"
  end_date     = "2028-09-20T08:00:00Z"
  display_name = "terraform-managed"
}

# Demo value; the real plaintext passes through a terminal exactly once.
client_secret = "demo-only-not-a-real-secret"

# Two copies of the database password, one of the Entra secret; one more row per team that needs to read it.
key_vault_secrets = {
  relay_db = {
    vault       = "kv-relay-dev"
    secret_name = "relay-db-password"
    source      = "pg"
  }
  shared_db = {
    vault       = "kv-shared-dev"
    secret_name = "relay-db-password"
    source      = "pg"
  }
  relay_client = {
    vault       = "kv-relay-dev"
    secret_name = "relay-client-secret"
    source      = "entra"
  }
}

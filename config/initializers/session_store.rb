# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_session_id',
  :secret      => '105a283f07a9dc874067440a4aad8993b6d85173bf3694100905a2507b90ebd0ab065b267936079c6d72edb2f5ad1a3b09071642b96bd78a9ba09a34acf2dcf0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_market_session',
  :secret      => 'b8e189da2896a80eadf7df76662e5908b02d3d46cf808f3796d7cc178e66512e7cca1e111954944296e9a1b162170f3431e3e6e3e3fc4203496a84f515edfdab'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

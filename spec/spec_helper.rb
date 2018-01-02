require './lib/blockchain'
require 'pp'

def create_transaction(sender: SecureRandom.uuid, recipient: SecureRandom.uuid, amount: rand(1..1000))
  { sender: sender, recipient: recipient, amount: amount }
end

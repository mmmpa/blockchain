module BlockChain
  require 'active_model'
  require 'json'
  require 'securerandom'

  require 'blockchain/hash_calculation'
  require 'blockchain/pow_calculation'
  require 'blockchain/block'
  require 'blockchain/chain'
  require 'blockchain/node'
  require 'blockchain/transaction'
end

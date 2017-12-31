require 'digest/sha2'

module BlockChain
  module HashCalculation
    def to_calculated_hash(index:, previous_hash:, timestamp:, data:)
      Digest::SHA256.hexdigest([index, previous_hash, timestamp, data].join(''))
    end
  end
end

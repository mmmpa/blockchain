require 'json'

module BlockChain
  class Block
    include ActiveModel::Validations
    include HashCalculation
    include PowCalculation

    attr_reader :index, :previous_hash, :timestamp, :data, :hash, :proof

    validates :index, :previous_hash, :timestamp, :hash, presence: true
    validates :index, numericality: { only_integer: true }

    def initialize(index:, previous_hash:, timestamp:, data:, hash:, proof:)
      @index = index
      @previous_hash = previous_hash
      @timestamp = timestamp
      @data = JSON.parse(data.to_json)
      @hash = hash
      @proof = proof
    end

    def as_json(*)
      {
        'index' => index,
        'previous_hash' => previous_hash,
        'timestamp' => timestamp,
        'data' => data,
        'hash' => hash,
        'proof' => proof,
      }
    end

    def to_json(*)
      JSON.generate(as_json)
    end

    def to_hash_prams
      {
        index: index,
        previous_hash: previous_hash,
        timestamp: timestamp,
        data: data,
        proof: proof,
      }
    end

    def valid_as_next!(block)
      case
      when block.index != index + 1
        raise InvalidIndex
      when block.previous_hash != hash
        raise InvalidPreviousHash
      when to_calculated_hash(block.to_hash_prams) != block.hash
        raise InvalidHash
      when !valid_proof?(previous: proof, mine: block.proof)
        raise InvalidPow
      else
        true
      end
    end

    def ==(other)
      to_json == other.to_json
    end

    class InvalidIndex < StandardError
    end

    class InvalidPreviousHash < StandardError
    end

    class InvalidHash < StandardError
    end

    class InvalidPow < StandardError
    end
  end
end

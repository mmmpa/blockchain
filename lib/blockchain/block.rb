require 'json'

module BlockChain
  class Block
    include ActiveModel::Validations
    include HashCalculation

    attr_reader :index, :previous_hash, :timestamp, :data, :hash

    validates :index, :previous_hash, :timestamp, :hash, presence: true
    validates :index, numericality: { only_integer: true }

    def initialize(index:, previous_hash:, timestamp:, data:, hash:)
      @index = index
      @previous_hash = previous_hash
      @timestamp = timestamp
      @data = data
      @hash = hash
    end

    def as_json(*)
      {
        'index' => index,
        'previous_hash' => previous_hash,
        'timestamp' => timestamp,
        'data' => data,
        'hash' => hash,
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
        else
          true
      end
    end

    def ==(block)
      case block
        when Block
          as_json == block.as_json
        when Hash
          as_json == block
        else
          super
      end
    end

    class InvalidIndex < StandardError
    end

    class InvalidPreviousHash < StandardError
    end

    class InvalidHash < StandardError
    end
  end
end

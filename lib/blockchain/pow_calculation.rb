require 'digest/sha2'

module BlockChain
  module PowCalculation
    HOPE = '0000'.freeze
    HOPE_SIZE = HOPE.size

    def to_pow(n)
      proof_of_work(previous: n)
    end

    def proof_of_work(previous:)
      n = 0
      loop do
        return n if valid_proof?(previous: previous, mine: n)
        n += 1
      end
    end

    def valid_proof?(previous:, mine:)
      Digest::SHA256.hexdigest([previous, mine].join(''))[-HOPE_SIZE..-1] == HOPE
    end
  end
end

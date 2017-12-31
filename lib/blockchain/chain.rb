module BlockChain
  class Chain
    include ActiveModel::Validations
    include HashCalculation

    attr_reader :body

    class << self
      include HashCalculation

      def genesis_block
        Block.new(
          index: 0,
          previous_hash: '0',
          timestamp: 1514752944,
          data: 'genesis block',
          hash: 'b1c4763ce5e60659e3063d6f7d37af8a8259a148ce8e3c9b631dbe96f2414362',
        )
      end
    end

    def initialize(body: [])
      @body =
        if body.present?
          body.map { |b| Block.new(b.symbolize_keys!) }
        else
          [Chain.genesis_block]
        end

      validate_body!
    end

    def as_json
      { 'body' => body.map(&:as_json) }
    end

    def to_json
      JSON.generate(as_json)
    end

    def add(data)
      params = {
        index: last_block.index + 1,
        previous_hash: last_block.hash,
        timestamp: Time.now.to_i,
        data: data,
      }

      body.push(Block.new(**params, hash: to_calculated_hash(params)))
    end

    # - 長さのチェック (自分より長くなければ却下)
    # - genesis block のチェック (起源が違えば却下)
    # - 各 block のハッシュが正しいかチェック (計算方式が自分のと同じかチェック)
    def replace!(raw_body)
      raise NoReplaceNeed if raw_body.size <= size
      raise GenesisBlockDifference if genesis_block != raw_body[0]

      # initialize 時にハッシュの正当性が確認される
      new_chain = Chain.new(body: raw_body)

      @body = new_chain.body
    end

    def validate_body!
      body[1..-1].inject(genesis_block) do |pre, block|
        block.tap do
          begin
            pre.valid_as_next!(block)
          rescue => e
            raise InvalidBlockInclusion, e
          end
        end
      end

      true
    end

    def genesis_block
      body[0]
    end

    def size
      body.size
    end

    def last_block
      body[-1]
    end

    class NoReplaceNeed < StandardError
    end

    class InvalidBlockInclusion < StandardError
    end

    class GenesisBlockDifference < StandardError
    end
  end
end

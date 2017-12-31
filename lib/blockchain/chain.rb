module BlockChain
  class Chain
    include ActiveModel::Validations
    include HashCalculation

    attr_reader :body

    class << self
      def genesis_block
        params = {
          index: 0,
          previous_hash: '0',
          timestamp: 1514752944,
          data: 'genesis block',
        }

        Block.new(**params, hash: to_calculated_hash(params))
      end
    end

    def initialize(raw_body: [])
      @body =
        if raw_body.present?
          raw_body.map {|b| Block.new(b)}
        else
          [Chain.genesis_block]
        end

      validate_body!
    end

    # - 長さのチェック (自分より長くなければ却下)
    # - genesis block のチェック (起源が違えば却下)
    # - 各 block のハッシュが正しいかチェック (計算方式が自分のと同じかチェック)
    def replace!(raw_body)
      raise 'Short' if raw_body.size <= size
      raise 'Different genesis block' if genesis_block != raw_body.first

      # initialize 時にハッシュの正当性が確認される
      new_chain = Chain.new(raw_body: raw_body)

      @body = new_chain.body
    end

    def validate_body!
      body[1..-1].inject(genesis_block) do |pre, block|
        if pre.valid_as_next?(block)
          block
        else
          raise 'Invalid block'
        end
      end

      true
    end

    def genesis_block
      body.first
    end

    def size
      body.size
    end
  end
end

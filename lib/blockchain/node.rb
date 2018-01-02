module BlockChain
  class Node
    module Message
      QUERY_LATEST = 0
      QUERY_ALL = 1
      RESPONSE_BLOCKCHAIN = 2
    end

    attr_reader :chain, :peers

    def initialize
      @chain = Chain.new
      @peers = Set.new
    end

    def add_peer(peer)
      peers.add(peer)
    end

    def blocks
      chain.body
    end

    def size
      chain.size
    end

    def last_block
      chain.last_block
    end

    # 新しいデータ登録を行う。
    # 自分のチェインにブロックを登録し、peers に登録されたことを通知する
    def add(data)
      chain.add(data)
      broadcast(type: Message::RESPONSE_BLOCKCHAIN, message: [last_block])
    end

    def broadcast(type:, message: nil)
      peers.each { |o| o.receive(type: type, message: JSON.generate(message)) }
    end

    def receive(type:, message: nil)
      case type
      when Message::QUERY_LATEST
        broadcast(type: Message::RESPONSE_BLOCKCHAIN, message: [last_block])
      when Message::QUERY_ALL
        broadcast(type: Message::RESPONSE_BLOCKCHAIN, message: blocks)
      when Message::RESPONSE_BLOCKCHAIN
        decide(JSON.parse(message))
      else
        raise UnknownMessageType
      end
    end

    def decide(received_blocks)
      received_blocks.sort! { |a, b| a['index'] - b['index'] }
      last_received_block = received_blocks[-1]

      case
      when last_received_block['index'] <= last_block.index
        # index が最後のブロックの index を超えていないので更新しない
        puts 'Not new block.'
      when last_received_block['previous_hash'] == last_block.hash
        # 次にくるブロックなので追加する
        chain.add_block(last_received_block.symbolize_keys!)
        broadcast(type: Message::RESPONSE_BLOCKCHAIN, message: [last_received_block])
      when received_blocks.size == 1
        # あたらしい last ブロックのみが来たが間が欠けているのですべての blocks を要求する
        broadcast(type: Message::QUERY_ALL)
      else
        # 自分より長いフルセットのブロックチェインが届いたので置換を試みる
        chain.replace!(received_blocks)
      end
    rescue => e
      puts e
    end

    class UnknownMessageType < StandardError
    end

    class NotNewBlock < StandardError
    end
  end
end

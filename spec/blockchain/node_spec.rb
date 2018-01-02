require './spec/spec_helper'

RSpec.describe BlockChain::Node do
  let(:node1) { BlockChain::Node.new }
  let(:node2) { BlockChain::Node.new }
  let(:node3) { BlockChain::Node.new }

  describe 'sync' do
    before do
      node1.add_peer(node2)
      node1.add_peer(node3)
      node2.add_peer(node1)
      node2.add_peer(node3)
      node3.add_peer(node1)
      node3.add_peer(node2)
    end

    it do
      node1.add(create_transaction)
      node1.add(create_transaction)
      node1.add(last_transaction = create_transaction)

      expect(node1.last_block.data['amount']).to eq(last_transaction[:amount])
      expect(node2.last_block.data['amount']).to eq(last_transaction[:amount])
      expect(node3.last_block.data['amount']).to eq(last_transaction[:amount])
      expect(node1.size).to eq(4)
      expect(node2.size).to eq(4)
      expect(node3.size).to eq(4)
    end
  end

  describe 'replace' do
    let(:pre_added_last_transaction) { create_transaction }

    before do
      node1.add(create_transaction)
      node1.add(create_transaction)
      node1.add(pre_added_last_transaction)

      node1.add_peer(node2)
      node1.add_peer(node3)
      node2.add_peer(node1)
      node2.add_peer(node3)
      node3.add_peer(node1)
      node3.add_peer(node2)
    end

    it do
      node1.add(last_transaction = create_transaction)

      expect(node1.last_block.data['amount']).to eq(last_transaction[:amount])
      expect(node2.last_block.data['amount']).to eq(last_transaction[:amount])
      expect(node3.last_block.data['amount']).to eq(last_transaction[:amount])
      expect(node1.size).to eq(5)
      expect(node2.size).to eq(5)
      expect(node3.size).to eq(5)
    end

    it do
      node2.add(last_transaction = create_transaction)

      expect(node1.last_block.data['amount']).to eq(pre_added_last_transaction[:amount])
      expect(node2.last_block.data['amount']).to eq(last_transaction[:amount])
      expect(node3.last_block.data['amount']).to eq(last_transaction[:amount])
      expect(node1.size).to eq(4)
      expect(node2.size).to eq(2)
      expect(node3.size).to eq(2)
    end

    it '', type: :invalid_sync do
      invalid_params = JSON.parse(node1.chain.body[1].to_json).
                         symbolize_keys!.
                         merge!(
                           data: 'invalid',
                           hash: node1.chain.body[1].hash,
                         )
      node1.chain.body[1] = BlockChain::Block.new(invalid_params)
      node1.add(first_transaction = create_transaction)

      expect(node1.last_block.data['amount']).to eq(first_transaction[:amount])
      expect(node2.last_block.data).to eq('genesis block')
      expect(node3.last_block.data).to eq('genesis block')
      expect(node1.size).to eq(5)
      expect(node2.size).to eq(1)
      expect(node3.size).to eq(1)

      node2.add(create_transaction)
      node2.add(create_transaction)
      node2.add(create_transaction)
      node2.add(create_transaction)

      expect(node1.last_block.data['amount']).to eq(first_transaction[:amount])

      node2.add(last_transaction = create_transaction)

      expect(node1.last_block.data['amount']).to eq(last_transaction[:amount])
      expect(node2.last_block.data['amount']).to eq(last_transaction[:amount])
      expect(node3.last_block.data['amount']).to eq(last_transaction[:amount])
    end
  end
end

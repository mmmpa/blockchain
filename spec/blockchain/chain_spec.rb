require './spec/spec_helper'

RSpec.describe BlockChain::Chain do
  let(:new_chain) { BlockChain::Chain.new }
  let(:body_params) { JSON.parse(new_chain.to_json)['body'] }

  describe 'new' do
    it do
      expect(new_chain.size).to eq(1)
    end
  end

  describe '#validate_body!' do
    before do
      new_chain.add('new data 1')
      new_chain.add('new data 2')
      new_chain.add('new data 3')
    end

    it do
      expect { BlockChain::Chain.new(body: body_params) }.not_to raise_error
    end

    it do
      body_params[2]['data'] = 'invalid'

      expect { BlockChain::Chain.new(body: body_params) }.
        to raise_error(BlockChain::Chain::InvalidBlockInclusion)
    end
  end

  describe '#add' do
    before do
      new_chain.add('new data')
    end

    it do
      expect(new_chain.size).to eq(2)
    end

    it do
      expect(new_chain.body[0].valid_as_next!(new_chain.body[1])).to eq(true)
    end
  end

  describe '#replace!' do
    let(:another_chain) { BlockChain::Chain.new }
    let(:different_chain) do
      b = BlockChain::Chain.new
      pa = {
        index: 0,
        previous_hash: '0',
        timestamp: Time.now.to_i,
        data: 'another genesis block',
        proof: 1,
      }

      b.body[0] = BlockChain::Block.new(**pa, hash: b.to_calculated_hash(pa))
      b
    end

    let(:another_body_params) { JSON.parse(another_chain.to_json)['body'] }
    let(:different_body_params) { JSON.parse(different_chain.to_json)['body'] }

    it do
      expect { new_chain.replace!(another_body_params) }.
        to raise_error(BlockChain::Chain::NoReplaceNeed)
    end

    it do
      another_chain.add('new another data')
      expect { new_chain.replace!(another_body_params) }.not_to raise_error
    end

    it do
      expect {
        another_chain.add('new another data')
        new_chain.replace!(another_body_params)
      }.to change { new_chain.size }.by(1)
    end

    it do
      new_chain.add('new another data 1')
      another_chain.add('new another data 1')
      another_chain.add('new another data 2')
      another_body_params[1]['data'] = 'invalid'
      expect { new_chain.replace!(another_body_params) }.
        to raise_error(BlockChain::Chain::InvalidBlockInclusion)
    end

    it do
      new_chain.add('new another data 1')
      another_chain.add('new another data 1')
      another_chain.add('new another data 2')
      another_body_params[1]['proof'] = 'invalid'
      expect { new_chain.replace!(another_body_params) }.
        to raise_error(BlockChain::Chain::InvalidBlockInclusion)
    end

    it do
      different_chain.add('new different data')
      expect { new_chain.replace!(different_body_params) }.
        to raise_error(BlockChain::Chain::GenesisBlockDifference)
    end
  end
end

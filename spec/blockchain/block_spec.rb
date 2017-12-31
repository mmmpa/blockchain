require './spec/spec_helper'

RSpec.describe BlockChain::Block do
  class Hasher
    include BlockChain::HashCalculation
  end

  let(:hasher) {Hasher.new}
  let(:p1) {
    {
      index: 1,
      previous_hash: '0',
      timestamp: Time.now.to_i,
      data: 'data',
    }
  }

  let(:first) {BlockChain::Block.new(**p1, hash: hasher.to_calculated_hash(p1))
  }

  let(:p2) {
    {
      index: 2,
      previous_hash: first.hash,
      timestamp: Time.now.to_i,
      data: 'data',
    }
  }

  let(:second) {BlockChain::Block.new(**p2, hash: hasher.to_calculated_hash(p2))}

  it do
    expect(first.valid_as_next?(second)).to eq(true)
  end

  it do
    p3 = p2.merge(index: 3)
    second = BlockChain::Block.new(**p3, hash: hasher.to_calculated_hash(p3))
    expect{first.valid_as_next?(second)}.to raise_error(BlockChain::Block::InvalidIndex)
  end

  it do
    p3 = p2.merge(previous_hash: 'invalid')
    second = BlockChain::Block.new(**p3, hash: hasher.to_calculated_hash(p3))
    expect{first.valid_as_next?(second)}.to raise_error(BlockChain::Block::InvalidPreviousHash)
  end

  it do
    second = BlockChain::Block.new(**p2, hash: 'invalid')
    expect{first.valid_as_next?(second)}.to raise_error(BlockChain::Block::InvalidHash)
  end
end
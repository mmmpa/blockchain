require './spec/spec_helper'

RSpec.describe BlockChain::PowCalculation do
  class Power
    include BlockChain::PowCalculation
  end

  let(:power) { Power.new }

  describe '#proof_of_work' do
    it do
      result = power.proof_of_work(previous: 1)

      expect(Digest::SHA256.hexdigest([1, result].join(''))[-4..-1]).to eq('0000')
    end
  end

  describe '#valid_proof?' do
    it do
      expect(power.valid_proof?(previous: 1, mine: 12370)).to eq(true)
    end
  end
end

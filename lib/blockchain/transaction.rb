module BlockChain
  class Transaction
    attr_reader :sender, :recipient, :amount

    def initialize(sender:, recipient:, amount:)
      @sender = sender
      @recipient = recipient
      @amount = amount
    end

    def as_json(*)
      {
        'sender' => sender,
        'recipient' => recipient,
        'amount' => amount,
      }
    end

    def to_json(*)
      JSON.generate(as_json)
    end
  end
end

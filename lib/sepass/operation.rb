# auto_register: false

require "dry/transaction/operation"

module Sepass
  class Operation
    def self.inherited(subclass)
      subclass.include Dry::Transaction::Operation
    end
  end
end

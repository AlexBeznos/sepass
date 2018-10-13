# frozen_string_literal: true

# auto_register: false

require 'dry/transaction'
require 'sepass/container'

module Sepass
  class Transaction
    include Dry::Transaction(container: Container)
  end
end

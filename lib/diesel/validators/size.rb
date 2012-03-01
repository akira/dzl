class Diesel::Validator
  def validate(input)
    raise "You must implement #validate in your Diesel::Validator subclass"
  end
end # TODO

module Diesel::Validators
  class Size < Diesel::Validator
    def initialize
      @conditions = []
    end

    def validate(input)
      true # TODO
    end

    [:==, :<=, :>=, :<, :>].each do |op|
      define_method(op) do |n|
        @conditions << [op, n]
      end
    end
  end
end
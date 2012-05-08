require 'dzl/examples/base'

class Dzl::Examples::FunWithParams < Dzl::Examples::Base
  Time.zone = "Eastern Time (US & Canada)"
  endpoint '/foo' do
    required :foo do
      type Array
      disallowed_values %w{zilch zip nada}
    end
  end

  endpoint '/bar' do
    required :foo do
      type Array, separator: '+'
    end
  end

  endpoint '/baz' do
    required :foo do
      type Array, separator: ','
    end
  end

  endpoint '/bar' do
    required :foo
  end

  endpoint '/foo/:bar' do
    required :bar do
      type Time
    end
  end

  endpoint '/protected' do
    protect do
      http_basic username: 'no', password: 'way'
    end
  end

  post '/body' do
    required :foo, :bar
  end

  post '/other_protected', :get do
    required :foo

    protect do
      http_basic username: 'no', password: 'way'
    end
  end

  endpoint '/api' do
    protect do
      api_key header: 'x_api_key', valid_keys: ['valid-key']
    end
  end

  endpoint '/arithmetic' do
    optional :int do
      type Fixnum
      value >= 5
    end

    optional :str do
      value == 'hello'
    end

    optional :date do
      type Date
      value > Date.parse('2012-01-01')
    end
  end

  endpoint '/defaults' do
    optional :foo do
      default 'hello'
    end

    optional :bar
    optional :baz do
      default 'world'
    end

    optional :nil do
      default nil
    end
  end

  endpoint '/foo/:bar'

  endpoint '/rofl/:copter', :post do
    optional(:candy) { type Array }
    optional(:cookies, :sunshine) { type Fixnum }
    optional :more
    required :sunshine, :steak
  end
end

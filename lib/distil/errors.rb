class Distil::Error < StandardError
  attr_reader :data, :status

  def initialize(data = {})
    @data = data
    @status = 500
  end

  def to_json
    {
      status: @status,
      error_class: self.class.to_s,
      errors: @data,
      trace: self.backtrace
    }.to_json
  end
end

class Distil::RequestError < Distil::Error; end

class Distil::NotFound < Distil::RequestError
  def initialize(data = {})
    super(data)
    @status = 404
  end
end

class Distil::BadRequest < Distil::RequestError
  def initialize(data = {})
    super(data)
    @status = 400
  end
end
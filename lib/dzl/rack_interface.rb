require 'rack'
require 'dzl/request'

module Dzl::RackInterface
  PROFILE_REQUESTS = false

  def call(env)
    __reloader.reload_if_updated if respond_to?(:__reloader)
    response = nil
    request = nil
    start_time = Time.now
    start_profile if PROFILE_REQUESTS
    response = begin
      request = Dzl::Request.new(env)
      __router.handle_request(request)
    rescue Dzl::RespondWithHTTPBasicChallenge
      respond_with_http_basic_challenge
    rescue Dzl::Error => e
      respond_with_dzl_error_handler(e)
    rescue StandardError => e
      respond_with_standard_error_handler(e)
    end

    if response[0] < 100
      response = respond_with_standard_error_handler(StandardError.new('Application did not respond'))
    end

    stop_profiling_and_print if PROFILE_REQUESTS
    log_request(request, response, (Time.now - start_time)) unless request.silent?

    if Dzl.production? || Dzl.staging?
      (response[0] < 500) ? response : [response[0], [], [response[0].to_s]]
    else
      response
    end
  end

  def respond_with_http_basic_challenge
    response = Rack::Response.new
    response['WWW-Authenticate'] = %(Basic realm="Dzl HTTP Basic")
    response.status = 401
    response.headers['Content-Type'] = 'text/html'
    response.write("Not Authorized\n")
    response.finish
  end

  def respond_with_standard_error_handler(e)
    response = Rack::Response.new
    response.headers['Content-Type'] = 'application/json'
    response.status = 500

    response.write({
      status: 500,
      error_class: e.class.to_s,
      errors: e.to_s,
      trace: e.backtrace
    }.to_json)

    response.finish
  end

  def respond_with_dzl_error_handler(e)
    response = Rack::Response.new
    response.headers['Content-Type'] = 'application/json'

    if e.is_a?(Dzl::RequestError)
      response.status = e.status
      response.write(e.to_json)
    else
      response.status = e.status
      response.write(e.to_json)
    end

    response.finish
  end

  def start_profile
    require 'ruby-prof'
    RubyProf.start
  end

  def stop_profiling_and_print
    result = RubyProf.stop
    printer = RubyProf::GraphHtmlPrinter.new(result)
    printer.print(
      File.open('/Projects/dzl/profile.html', 'w'),
      min_percent: 5
    )
  end

  def log_request(request, response, seconds)
    logger.info "#{request.request_method} #{request.path}"
    logger.info "PARAMS: #{request.params}"
    logger.info "#{response[0]} in #{seconds * 1000}ms"
  end
end
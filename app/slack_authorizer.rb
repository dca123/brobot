class SlackAuthorizer
  UNAUTHORIZED_MESSAGE = 'Ops! Looks like the application is not authorized! Please review the token configuration.'.freeze
  UNAUTHORIZED_RESPONSE = ['200', {'Content-Type' => 'text'}, [UNAUTHORIZED_MESSAGE]]

  def initialize(app)
    @app = app
  end
  def call(env)
    req = Rack::Request.new(env)
    x =  req.body.read
    if defined?(req.params['token']) and (req.params['token'] == ENV['SLACK_VERIFICATION_TOKEN'])
      @app.call(env)
    elsif !(x.nil?) and !(x['type'].nil?)
      env['body'] = x
      @app.call(env)
    else
      UNAUTHORIZED_RESPONSE
    end
  end
end

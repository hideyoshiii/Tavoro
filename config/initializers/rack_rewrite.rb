if ENV['RACK_ENV'] == 'production'
  Powder::Application.config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
    r301 %r{.*}, 'https://www.tavore.net$&', :if => Proc.new {|rack_env|
      rack_env['SERVER_NAME'] == 'tavore.herokuapp.com'
    }
  end
end


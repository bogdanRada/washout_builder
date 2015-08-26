class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception



  def test_soap
    require 'savon'

client = Savon::Client.new(wsdl: "http://localhost:3000/api/rumbas/wsdl")

client.operations # => [:integer_to_string, :concat, :add_circle]

result = client.call(:concat, message: { :a => "123", :b => "abc" })


render :json => result.to_hash # => {:value=>"123abc"}
  end
end

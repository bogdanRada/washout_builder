require 'spec_helper'
mock_controller do
   soap_action 'dispatcher_method', :args => nil, :return => nil
 
   def dispatcher_method
      #nothing
   end
 end
describe WashoutBuilder::WashoutBuilderController, :type => :controller  do
    routes { WashoutBuilder::Engine.routes }
 
  let(:soap_config) { OpenStruct.new(
      camelize_wsdl: false,
      namespace: "/api/wsdl",
    ) }
  
   let(:washout_builder) { stub(:root_url => "#{request.protocol}#{request.host_with_port}/")}
   
  before(:each) do
    ApiController.stubs(:soap_config).returns(soap_config)
    controller.stubs(:washout_builder).returns(washout_builder)
  end

  it "gets the services" do
    get :all
    assigns(:services).should eq([{'service_name'=>"Api", 'namespace'=>"/api/wsdl", 'endpoint'=>"/api/action", 'documentation_url'=>"http://test.host/Api"}])
  end
  
  it "renders the template" do
    get :all
    response.should render_template("wash_with_html/all_services")
  end

end

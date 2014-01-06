require 'spec_helper'


describe WashoutBuilderController, :type => :controller  do
  
  let(:soap_config) { OpenStruct.new(
      camelize_wsdl: false,
      namespace: "/api/wsdl",
    ) }
  
  before(:each) do
    ApiController.stubs(:soap_config).returns(soap_config)
  end

  it "gets the services" do
    pending("test fails with rails 4.0 and jruby but work with other versions of ruby . Reason is because of symbols. ")
    get :all
<<<<<<< HEAD
    assigns(:services).should eq([{:service_name=>"Api", :namespace=>"/api/wsdl", :endpoint=>"/api/action", :documentation_url=>"http://test.host/api/doc"}])
=======
    assigns(:services).should eq([{'service_name'=>"Api", 'namespace'=>"/api/wsdl", 'endpoint'=>"/api/action", 'documentation_url'=>"http://test.host/api/doc"}])
>>>>>>> develop
  end
  
  
  it "renders the template" do
    get :all
    response.should render_template("wash_with_html/all_services")
  end
  

end

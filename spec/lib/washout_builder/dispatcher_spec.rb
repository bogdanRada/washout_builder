#encoding:utf-8

require 'spec_helper'
mock_controller do
  soap_action 'dispatcher_method', :args => nil, :return => nil

  def dispatcher_method
    raise SOAPError.new("some message", 1001) 
  end
end

describe ApiController, :type => :controller do

  let(:document) { WashoutBuilder::Document::Generator.new}
  
  render_views(false)
 
  before(:each) do
    WashoutBuilder::Document::Generator.stubs(:new).returns(document)
  end
  
  it "inits the document generator" do
    WashoutBuilder::Document::Generator.expects(:new).with(
      :config => ApiController.soap_config, 
      :service_class => ApiController,  
      :soap_actions =>  {'dispatcher_method' => 
          {:args => nil, :return => nil, :in => [], :out => [], :to => 'dispatcher_method'}
      }
    )      
    get :_generate_doc
  end
  
  it "verifies render" do
    controller.expects(:render).with(nil)
    controller.expects(:render).with(:template => "wash_with_html/doc", :layout => false,
      :content_type => 'text/html')
    get :_generate_doc
  end
   
  it "renders the template" , :fails =>true do
    get :_generate_doc
    response.should render_template("wash_with_html/doc")
  end
  
  
end
require 'spec_helper'
mock_controller do
  soap_action 'dispatcher_method', args: nil, return: nil

  def dispatcher_method
    # nothing
  end
end
describe WashoutBuilder::WashoutBuilderController, type: :controller do
  routes { WashoutBuilder::Engine.routes }

  let(:soap_config) do
    OpenStruct.new(
      camelize_wsdl: false,
      namespace: '/api/wsdl'
    )
  end

  let(:washout_builder) { stub(root_url: "#{request.protocol}#{request.host_with_port}/") }
  let(:route) { stub(defaults: { controller: 'api' }) }
  let(:params) { { name: 'some_name' } }

  before(:each) do
    ApiController.stubs(:soap_config).returns(soap_config)
    controller.stubs(:washout_builder).returns(washout_builder)
  end

  it 'gets the services' do
    get :all
    expect(subject.instance_variable_get(:@services)).to eq([{ 'service_name' => 'Api', 'namespace' => '/api/wsdl', 'endpoint' => '/api/action', 'documentation_url' => '/api/soap_doc' }])
  end

  it 'renders the template' do
    get :all
    expect(subject.instance_variable_get(:@file_to_serve)).to eq('wash_with_html/all_services')
    if response.respond_to?(:media_type)
      expect(response.media_type).to eq("text/html")
    else
      expect(response.content_type).to eq('text/html')
    end
    expect(response).to have_http_status(:ok)
  end

  it 'checks it controller is a service' do
    controller.send(:find_all_routes)
    expect(controller.send(:controller_is_a_service?, 'api')).not_to eq nil
  end

  it 'render a service documentation' do
    controller.stubs(:controller_class).returns(ApiController)
    controller.stubs(:controller_is_a_service?).with(params[:name]).returns(route)
    WashoutBuilder::Document::Generator.expects(:new).with(route, route.defaults[:controller])
    if Rails::VERSION::MAJOR >= 5
      get :all, params: params
    else
      get :all, params
    end
    expect(subject.instance_variable_get(:@file_to_serve)).to eq('wash_with_html/doc')
    if response.respond_to?(:media_type)
      expect(response.media_type).to eq("text/html")
    else
      expect(response.content_type).to eq('text/html')
    end
    expect(response).to have_http_status(:ok)
  end
end

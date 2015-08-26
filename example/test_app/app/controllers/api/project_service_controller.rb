class Api::ProjectServiceController < Api::Core
  before_filter  :require_api_authorization

  soap_service  namespace: "#{Rails.configuration.api_namespace}project_service/wsdl"

  # Simple case
  soap_action "create_or_update",  :args   => Api::ProjectType , :return => :boolean,  :to => :create_or_update


  def create_or_update
    render :soap => true
  end

  soap_action "delete_member",  :args   => {:mail  => :string, 'redmine_projectid' => :integer, "project_type"=> Api::TestNamespace::TestType } , :return => :boolean,  :to => :set_inactive_project_assignment

  def set_inactive_project_assignment
  render :soap => true
  end



  soap_action "add_members",  :args   => {:members  =>  [{:mail => :string }] , 'redmine_projectid' => :integer, 'project_type' => :string} , :return => :boolean,  :to => :create_or_set_active_project_assignment

  def create_or_set_active_project_assignment
    render :soap => true
  end

end

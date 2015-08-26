class Api::ProjectType < WashOut::Type
  map :project => {
    :name                                    => :string,
    :description                           => :string,
    'project_tag_list'                    => :string,
    'project_code'                        => :string,
    'redmine_project_id'              => :integer,
     'pm_mail'                              => :string,
    :users_info                                    => [{:mail_info => :string }],
    'redmine_project_type'          => :string,
    'redmine_project_parent_id'  => :integer,
    'customer_department'          => :string
  }
end

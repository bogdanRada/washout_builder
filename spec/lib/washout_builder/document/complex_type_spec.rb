#encoding:utf-8
require 'spec_helper'


describe WashoutBuilder::Document::ComplexType do
  let(:soap_config) { OpenStruct.new(
      camelize_wsdl: false,
      namespace: "/api/wsdl",
      description: "some description"
    ) }
  
  def get_wash_out_param(class_name_or_structure, soap_config = soap_config)
    WashOut::Param.parse_builder_def(soap_config, class_name_or_structure)[0]
  end
  
  let(:subject) {  get_wash_out_param(ProjectType) }
  let(:namespaced_object) { get_wash_out_param(Api::TestType) }
  
  it "returns the complex class name" do
    subject.get_complex_class_name.should eq("ProjectType")
  end
  
  
  it "returns the complex class name" do
    subject.get_complex_class_name.should eq("ProjectType")
  end
   
  
  it "returns the complex class with namespace" do
    namespaced_object.get_complex_class_name.should eq("Api::TestType")
  end
  
    
  it "returns error if classname already detected (only used for hashes)" do
    subject.stubs(:classified?).returns(false)
    subject.stubs(:basic_type).returns("ProjectType")
    defined  = [ { :class= => "ProjectType" }]
    defined.stubs(:detect).returns({:class => "ProjectType"})
    expect {subject.get_complex_class_name(defined) }.to  raise_error(RuntimeError, "Duplicate use of `ProjectType` type name. Consider using classified types.")
  end
  
  it "returns the param structure" do
    subject.get_param_structure.should eq({"project"=>"struct"})
  end
  
  it "fixes the first descendant " do
    descendant = get_wash_out_param(ProjectType.wash_out_param_map)
    subject.fix_descendant_wash_out_type(soap_config, ProjectType)
    subject.name.should eq(descendant.name)
    subject.map[0].get_param_structure.should eq(descendant.map[0].get_param_structure)
  end
  
  it "same as ancestor" do
    subject.get_ancestors(ProjectType).should eq([])
  end
  
  
 
  
  
end
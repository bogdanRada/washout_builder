# encoding:utf-8
require 'spec_helper'

describe WashoutBuilder::Document::ComplexType do
  let(:soap_config) do
    OpenStruct.new(
        camelize_wsdl: false,
        namespace: '/api/wsdl',
        description: 'some description'
    )
  end

  let(:subject) { get_wash_out_param(ProjectType) }
  let(:namespaced_object) { get_wash_out_param(Api::TestType) }

  it 'returns the complex class name' do
    expect(subject.find_complex_class_name).to eq('Project')
  end

  it 'returns the complex class with namespace' do
    expect(namespaced_object.find_complex_class_name).to eq('Project')
  end

  it 'does not return error if classname already detected (only used for hashes) and same structure' do
    subject.stubs(:classified?).returns(false)
    subject.stubs(:basic_type).returns('ProjectType')
    classes_defined = [{ class: 'ProjectType', obj: get_wash_out_param(ProjectType), ancestors: [] }]
    expect { subject.find_complex_class_name(classes_defined) }.to_not raise_error(RuntimeError, 'Duplicate use of `ProjectType` type name. Consider using classified types.')
  end

  it 'returns error if classname already detected (only used for hashes)' do
    subject.stubs(:classified?).returns(false)
    subject.stubs(:basic_type).returns('ProjectType')
    classes_defined = [{ class: 'ProjectType', obj: get_wash_out_param(Api::TestType), ancestors: [] }]
    expect { subject.find_complex_class_name(classes_defined) }.to raise_error(RuntimeError, 'Duplicate use of `ProjectType` type name. Consider using classified types.')
  end

  it 'returns the param structure' do
    expect(subject.find_param_structure).to eq("description"=>"string", "name"=>"string", "users"=>"struct")
  end

  it 'same as ancestor' do
    expect(subject.get_ancestors(ProjectType)).to eq([])
  end

  it 'same as ancestor' do
    expect(subject.get_ancestors('WashoutBuilderSomeInexistentClass')).to eq(nil)
  end

  it 'returns the complex type ancestors' do
    expected = 'some_name'
    subject.stubs(:classified?).returns(true)
    subject.expects(:get_class_ancestors).with(soap_config, ProjectType, []).returns(expected)
    expect(subject.complex_type_ancestors(soap_config, ProjectType, [])).to eq(expected)
  end

  it 'returns nil  for unclassified objects' do
    subject.stubs(:classified?).returns(false)
    expect(subject.complex_type_ancestors(soap_config, ProjectType, [])).to eq(nil)
  end

  it 'should remove inheritable elements' do
    subject_dup = subject.dup
    subject_dup.remove_type_inheritable_elements(['name'])
    expect(subject_dup.map.find { |element| element.name == 'name' }).to eq(nil)
  end

  it 'should return true if same structure' do
    expect(subject.same_structure_as_ancestor?(subject)).to eq(true)
  end

  it 'should return true if same structure' do
    expect(subject.same_structure_as_ancestor?(get_wash_out_param(Fluffy))).to eq(false)
  end

  describe '#complex_type_descendants' do
    it 'returns empty array if not struct?' do
      classes_defined = []
      subject.stubs(:struct?).returns(false)
      expect(subject.complex_type_descendants(soap_config, classes_defined)).to eq(classes_defined)
    end

    it 'returns the descendants if  struct?' do
      classes_defined = []
      subject.map.each do |obj|
        obj.expects(:get_nested_complex_types).with(soap_config, classes_defined).returns([obj.name])
      end
      subject.stubs(:struct?).returns(true)
      expect(subject.complex_type_descendants(soap_config, classes_defined)).to eq(subject.map.map(&:name))
    end
  end

  describe '#get_nested_complex_types' do
    let(:complex_class) { 'ProjectType' }
    let(:ancestors) { ['something'] }
    let(:complex_type_hash) { { class: complex_class, obj: subject, ancestors: ancestors } }
    let(:expected) { [complex_type_hash] }

    it 'returns the complex class ancestors' do
      classes_defined = []
      subject.expects(:find_complex_class_name).with(classes_defined).returns(complex_class)
      subject.expects(:find_class_from_string).with(complex_class).returns(nil)
      subject.expects(:complex_type_ancestors).with(soap_config, complex_class, classes_defined).returns(ancestors)
      subject.expects(:complex_type_hash).with(complex_class, subject, ancestors).returns(complex_type_hash)
      subject.expects(:complex_type_descendants).with(soap_config, [complex_type_hash]).returns(expected)
      expect(subject.get_nested_complex_types(soap_config, classes_defined)).to eq(expected)
    end

    it 'returns the the descendants' do
      classes_defined = nil
      subject.expects(:find_complex_class_name).with([]).returns(nil)
      subject.expects(:complex_type_descendants).with(soap_config, []).returns(expected)
      expect(subject.get_nested_complex_types(soap_config, classes_defined)).to eq(expected)
    end
  end

  describe '#ancestor_structure' do
    let(:ancestor_class) { ProjectType }
    let(:ancestors) { [ancestor_class] }

    it 'returns the ancestor structure' do
      expect(subject.ancestor_structure(ancestors)).to eq(ancestors[0].to_s.downcase => ancestors[0].wash_out_param_map)
    end
  end

  describe '#complex_type_hash' do
    let(:complex_class) { 'ProjectType' }
    let(:ancestors) { ['something'] }

    it 'returns the complex_type_hash' do
      expect(subject.complex_type_hash(complex_class, subject, ancestors)).to eq(class: complex_class, obj: subject, ancestors: ancestors)
    end
  end

  describe '#get_class_ancestors' do
    let(:class_name) { 'ProjectType' }
    let(:classes_defined) { [] }
    let(:ancestors) { ['SomeInexistentClass'] }
    let(:ancestor_structure) { { ancestors[0].to_s.downcase => 'bla' } }
    let(:top_ancestors) {}
    let(:complex_type_hash) { { class: class_name, obj: subject, ancestors: ancestors } }

    it 'returns nil if no ancestors' do
      subject.expects(:get_ancestors).with(class_name).returns(nil)
      expect(subject.get_class_ancestors(soap_config, class_name, classes_defined)).to eq(nil)
    end

    it 'returns the ancestors and the top ones' do
      skip 'recursion problem'
      subject.expects(:get_ancestors).with(class_name).returns(ancestors)
      subject.expects(:ancestor_structure).with(ancestors).returns(ancestor_structure)
      WashOut::Param.stubs(:parse_def).returns([namespaced_object])
      subject.expects(:same_structure_as_ancestor?).with(namespaced_object).returns(false)
      subject.expects(:complex_type_hash).returns(complex_type_hash)
      expect(subject.get_class_ancestors(soap_config, class_name, classes_defined)).to eq([complex_type_hash])
    end

    it 'returns nil if same structure as ancestor' do
      namespaced_object
      subject.expects(:get_ancestors).with(class_name).returns(ancestors)
      subject.expects(:ancestor_structure).with(ancestors).returns(ancestor_structure)
      WashOut::Param.stubs(:parse_def).with(soap_config, ancestor_structure).returns([namespaced_object])
      subject.expects(:same_structure_as_ancestor?).with(namespaced_object).returns(true)
      expect(subject.get_class_ancestors(soap_config, class_name, classes_defined)).to eq(nil)
    end
  end
end

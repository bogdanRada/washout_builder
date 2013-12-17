#encoding:utf-8

require 'spec_helper'

describe WashoutBuilder::Type do

  it "defines a list of types" do
    WashoutBuilder::Type::BASIC_TYPES.should eq([ 
        "string",
        "integer",
        "double",
        "boolean",
        "date",
        "datetime",
        "float",
        "time",
        "int"])
  end
 
end
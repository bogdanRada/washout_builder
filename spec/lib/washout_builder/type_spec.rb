#encoding:utf-8

require 'spec_helper'

describe WashoutBuilder::Type do

  [ "string",
    "integer",
    "double",
    "boolean",
    "date",
    "datetime",
    "float",
    "time",
    "int"].each do |type|
    it "defines a list of types" do
      WashoutBuilder::Type::BASIC_TYPES.should include(type)
    end
  end

end
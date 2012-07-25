require 'spec_helper'

#-----------------------------------------------------------------------------------------------------------------------
# Model
#-----------------------------------------------------------------------------------------------------------------------

#--------------------
ActiveRecord::Schema.define do
  create_table :simple_homes do |table|
    table.column :phone_number, :string
  end

  create_table :helpful_homes do |table|
    table.column :phone_number, :string
  end
end

#--------------------
class SimpleHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates :phone_number, :phony_plausible => true
end

#--------------------
class HelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number
end

#-----------------------------------------------------------------------------------------------------------------------
# Tests
#-----------------------------------------------------------------------------------------------------------------------

VALID_NUMBER = '123456789'
INVALID_NUMBER = '123456789 123456789 123456789 123456789'

#-----------------------------------------------------------------------------------------------------------------------
describe PhonyPlausibleValidator do

  #--------------------
  describe '#validates' do

    before(:each) do
      @home = SimpleHome.new
    end

    it "should validate an empty number" do
      @home.should be_valid
    end

    it "should validate a valid number" do
      @home.phone_number = VALID_NUMBER
      @home.should be_valid
    end

    it "should invalidate an invalid number" do
      @home.phone_number = INVALID_NUMBER
      @home.should_not be_valid
      @home.errors.messages.should include(:phone_number => ["is an invalid number"])
    end

  end
end

#-----------------------------------------------------------------------------------------------------------------------
describe ActiveModel::Validations::HelperMethods do

  #--------------------
  describe '#validates_plausible_phone' do

    before(:each) do
      @home = HelpfulHome.new
    end

    it "should validate an empty number" do
      @home.should be_valid
    end

    it "should validate a valid number" do
      @home.phone_number = VALID_NUMBER
      @home.should be_valid
    end

    it "should invalidate an invalid number" do
      @home.phone_number = INVALID_NUMBER
      @home.should_not be_valid
      @home.errors.messages.should include(:phone_number => ["is an invalid number"])
    end

  end

end

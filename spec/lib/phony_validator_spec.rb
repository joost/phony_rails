require 'spec_helper'

ActiveRecord::Schema.define do
  create_table :validating_homes do |table|
    table.column :phone_number, :string
    table.column :fax_number, :string
  end
end

class ValidatingHome < ActiveRecord::Base
  attr_accessor :phone_method, :fax_number
  validates :phone_number, :phony_plausible => true
  validates_plausible_phone :fax_number
end



describe PhonyPlausibleValidator do

  describe 'validates' do
    before(:each) do
      @home = ValidatingHome.new
    end

    it "should validate an empty number" do
      @home.should be_valid
    end

    it "should validate a valid number" do
      @home.phone_number = '123456789'
      @home.should be_valid
    end

    it "should invalidate an invalid number" do
      @home.phone_number = '123456789 123456789 123456789 123456789'
      @home.should_not be_valid
    end
  end

  describe 'validates_plausible_phone' do
    before(:each) do
      @home = ValidatingHome.new
    end

    it "should validate an empty number" do
      @home.should be_valid
    end

    it "should validate a valid number" do
      @home.fax_number = '123456789'
      @home.should be_valid
    end

    it "should invalidate an invalid number" do
      @home.fax_number = '123456789 123456789 123456789 123456789'
      @home.should_not be_valid
    end
  end

end
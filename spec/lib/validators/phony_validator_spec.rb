# encoding: utf-8
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

  create_table :required_helpful_homes do |table|
    table.column :phone_number, :string
  end

  create_table :optional_helpful_homes do |table|
    table.column :phone_number, :string
  end

  create_table :formatted_helpful_homes do |table|
    table.column :phone_number, :string
  end

  create_table :not_formatted_helpful_homes do |table|
    table.column :phone_number, :string
  end

  create_table :big_helpful_homes do |table|
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

#--------------------
class RequiredHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, :presence => true
end

#--------------------
class OptionalHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, :presence => false
end

#--------------------
class FormattedHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, :with => /^\+\d+/
end

#--------------------
class NotFormattedHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, :without => /^\+\d+/
end

#--------------------
class BigHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, :presence => true, :with => /^\+\d+/
end

#-----------------------------------------------------------------------------------------------------------------------
# Tests
#-----------------------------------------------------------------------------------------------------------------------

I18n.locale = :en
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

    it "should translate the error message in english" do
      I18n.with_locale(:en) do
        @home.phone_number = INVALID_NUMBER
        @home.valid?
        @home.errors.messages.should include(:phone_number => ["is an invalid number"])
      end
    end

    it "should translate the error message in french" do
      I18n.with_locale(:fr) do
        @home.phone_number = INVALID_NUMBER
        @home.valid?
        @home.errors.messages.should include(:phone_number => ["est un numéro invalide"])
      end
    end

  end
end

#-----------------------------------------------------------------------------------------------------------------------
describe ActiveModel::Validations::HelperMethods do

  #--------------------
  describe '#validates_plausible_phone' do

    #--------------------
    context 'when a number is optional' do

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

    #--------------------
    context 'when a number is required (:presence = true)' do

      before(:each) do
        @home = RequiredHelpfulHome.new
      end

      it "should invalidate an empty number" do
        @home.should_not be_valid
        @home.errors.messages.should include(:phone_number => ["can't be blank"])
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

    #--------------------
    context 'when a number is not required (!presence = false)' do

      before(:each) do
        @home = OptionalHelpfulHome.new
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

    #--------------------
    context 'when a number must be formatted (:with)' do

      before(:each) do
        @home = FormattedHelpfulHome.new
      end

      it "should invalidate an empty number" do
        @home.should_not be_valid
        @home.errors.messages.should include(:phone_number => ["is invalid"])
      end

      it "should validate a well formatted valid number" do
        @home.phone_number = "+33 #{VALID_NUMBER}"
        @home.should be_valid
      end

      it "should invalidate a bad formatted valid number" do
        @home.phone_number = VALID_NUMBER
        @home.should_not be_valid
        @home.errors.messages.should include(:phone_number => ["is invalid"])
      end

    end

    #--------------------
    context 'when a number must not be formatted (:without)' do

      before(:each) do
        @home = NotFormattedHelpfulHome.new
      end

      it "should validate an empty number" do
        @home.should be_valid
      end

      it "should validate a well formatted valid number" do
        @home.phone_number = VALID_NUMBER
        @home.should be_valid
      end

      it "should invalidate a bad formatted valid number" do
        @home.phone_number =  "+33 #{VALID_NUMBER}"
        @home.should_not be_valid
        @home.errors.messages.should include(:phone_number => ["is invalid"])
      end

    end

  end

end

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

  create_table :australian_helpful_homes do |table|
    table.column :phone_number, :string
  end

  create_table :polish_helpful_homes do |table|
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
class AustralianHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, :country_number => "61"
end

#--------------------
class PolishHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, :country_code => "PL"
end

#--------------------
class BigHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, :presence => true, :with => /^\+\d+/, :country_number => "33"
end

#-----------------------------------------------------------------------------------------------------------------------
# Tests
#-----------------------------------------------------------------------------------------------------------------------

I18n.locale = :en
VALID_NUMBER = '1 555 555 5555'
AUSTRALIAN_NUMBER_WITH_COUNTRY_CODE = '61390133997'
POLISH_NUMBER_WITH_COUNTRY_CODE = '48600600600'
FORMATTED_AUSTRALIAN_NUMBER_WITH_COUNTRY_CODE = '+61 390133997'
FRENCH_NUMBER_WITH_COUNTRY_CODE = '33627899541'
FORMATTED_FRENCH_NUMBER_WITH_COUNTRY_CODE = '+33 627899541'
INVALID_NUMBER = '123456789 123456789 123456789 123456789'

#-----------------------------------------------------------------------------------------------------------------------
describe PhonyPlausibleValidator do

  #--------------------
  describe '#validates' do

    let(:home) { build(:simple_home) }

    it "validates an empty number" do
      expect(home).to be_valid
    end

    it "validates a valid number" do
      home.phone_number = VALID_NUMBER
      expect(home).to be_valid
    end

    it "invalidates an invalid number" do
      home.phone_number = INVALID_NUMBER
      expect(home).to_not be_valid
      expect(home.errors.messages).to include(:phone_number => ["is an invalid number"])
    end

    it "translates the error message in English" do
      I18n.with_locale(:en) do
        home.phone_number = INVALID_NUMBER
        home.valid?
        expect(home.errors.messages).to include(:phone_number => ["is an invalid number"])
      end
    end

    it "translates the error message in French" do
      I18n.with_locale(:fr) do
        home.phone_number = INVALID_NUMBER
        home.valid?
        expect(home.errors.messages).to include(:phone_number => ["est un numéro invalide"])
      end
    end

    it "translates the error message in Japanese" do
      I18n.with_locale(:ja) do
        home.phone_number = INVALID_NUMBER
        home.valid?
        expect(home.errors.messages).to include(:phone_number => ["は正し電話番号ではありません"])
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

      let(:home) { build(:helpful_home) }

      it "validates an empty number" do
        expect(home).to be_valid
      end

      it "validates a valid number" do
        home.phone_number = VALID_NUMBER
        expect(home).to be_valid
      end

      it "invalidates an invalid number" do
        home.phone_number = INVALID_NUMBER
        expect(home).to_not be_valid
        expect(home.errors.messages).to include(:phone_number => ["is an invalid number"])
      end

    end

    #--------------------
    context 'when a number is required (:presence = true)' do

      let(:home) { build(:required_helpful_home) }

      it "invalidates an empty number" do
        expect(home).to_not be_valid
        expect(home.errors.messages).to include(:phone_number => ["can't be blank"])
      end

      it "validates a valid number" do
        home.phone_number = VALID_NUMBER
        expect(home).to be_valid
      end

      it "invalidates an invalid number" do
        home.phone_number = INVALID_NUMBER
        expect(home).to_not be_valid
        expect(home.errors.messages).to include(:phone_number => ["is an invalid number"])
      end

    end

    #--------------------
    context 'when a number is not required (!presence = false)' do

      let(:home) { build(:optional_helpful_home) }

      it "validates an empty number" do
        expect(home).to be_valid
      end

      it "validates a valid number" do
        home.phone_number = VALID_NUMBER
        expect(home).to be_valid
      end

      it "invalidates an invalid number" do
        home.phone_number = INVALID_NUMBER
        expect(home).to_not be_valid
        expect(home.errors.messages).to include(:phone_number => ["is an invalid number"])
      end

    end

    #--------------------
    context 'when a number must be formatted (:with)' do

      let(:home) { build(:formatted_helpful_home) }

      it "invalidates an empty number" do
        expect(home).to_not be_valid
        expect(home.errors.messages).to include(:phone_number => ["is invalid"])
      end

      it "validates a well formatted valid number" do
        home.phone_number = "+#{VALID_NUMBER}"
        expect(home).to be_valid
      end

      it "invalidates a bad formatted valid number" do
        home.phone_number = VALID_NUMBER
        expect(home).to_not be_valid
        expect(home.errors.messages).to include(:phone_number => ["is invalid"])
      end

    end

    #--------------------
    context 'when a number must not be formatted (:without)' do

      let(:home) { build(:not_formatted_helpful_home) }

      it "validates an empty number" do
        expect(home).to be_valid
      end

      it "validates a well formatted valid number" do
        home.phone_number = VALID_NUMBER
        expect(home).to be_valid
      end

      it "invalidates a bad formatted valid number" do
        home.phone_number =  "+#{VALID_NUMBER}"
        expect(home).to_not be_valid
        expect(home.errors.messages).to include(:phone_number => ["is invalid"])
      end

    end

    #--------------------
    context 'when a number must include a specific country number' do

      let(:home) { build(:australian_helpful_home) }

      it "validates an empty number" do
        expect(home).to be_valid
      end

      it "validates a valid number with the right country code" do
        home.phone_number = AUSTRALIAN_NUMBER_WITH_COUNTRY_CODE
        expect(home).to be_valid
      end

      it "invalidates a valid number with the wrong country code" do
        home.phone_number = FRENCH_NUMBER_WITH_COUNTRY_CODE
        expect(home).to_not be_valid
        expect(home.errors.messages).to include(:phone_number => ["is an invalid number"])
      end

      it "invalidates a valid number without a country code" do
        home.phone_number = VALID_NUMBER
        expect(home).to_not be_valid
        expect(home.errors.messages).to include(:phone_number => ["is an invalid number"])
      end

    end

    #--------------------
    context 'when a number must include a specific country code' do

      before(:each) do
        @home = PolishHelpfulHome.new
      end

      it "should validate an empty number" do
        @home.should be_valid
      end

      it "should validate a valid number with the right country code" do
        @home.phone_number = POLISH_NUMBER_WITH_COUNTRY_CODE
        @home.should be_valid
      end

      it "should invalidate a valid number with the wrong country code" do
        @home.phone_number = FRENCH_NUMBER_WITH_COUNTRY_CODE
        @home.should_not be_valid
        @home.errors.messages.should include(:phone_number => ["is an invalid number"])
      end

      it "should invalidate a valid number without a country code" do
        @home.phone_number = VALID_NUMBER
        @home.should_not be_valid
        @home.errors.messages.should include(:phone_number => ["is an invalid number"])
      end

    end

    context 'when lots of things are being validated simultaneously' do

      let(:home) { build(:big_helpful_home) }

      it "invalidates an empty number" do
        expect(home).to_not be_valid
      end

      it "invalidates an invalid number" do
        home.phone_number = INVALID_NUMBER
        expect(home).to_not be_valid
        expect(home.errors.messages[:phone_number]).to include "is an invalid number"
      end

      it "invalidates a badly formatted number with the right country code" do
        home.phone_number = FRENCH_NUMBER_WITH_COUNTRY_CODE
        expect(home).to_not be_valid
        expect(home.errors.messages[:phone_number]).to include "is invalid"
      end

      it "invalidates a properly formatted number with the wrong country code" do
        home.phone_number = FORMATTED_AUSTRALIAN_NUMBER_WITH_COUNTRY_CODE
        expect(home).to_not be_valid
        expect(home.errors.messages[:phone_number]).to include "is an invalid number"
      end

      it "validates a properly formatted number with the right country code" do
        home.phone_number = FORMATTED_FRENCH_NUMBER_WITH_COUNTRY_CODE
        expect(home).to be_valid
      end

    end

  end

end

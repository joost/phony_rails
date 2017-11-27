# frozen_string_literal: true

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

  create_table :normalizable_helpful_homes do |table|
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

  create_table :mismatched_helpful_homes do |table|
    table.column :phone_number, :string
  end

  create_table :invalid_country_code_helpful_homes do |table|
    table.column :phone_number, :string
  end

  create_table :symbolizable_helpful_homes do |table|
    table.column :phone_number, :string
    table.column :phone_number_country_code, :string
  end
end

#--------------------
class SimpleHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates :phone_number, phony_plausible: true
end

#--------------------
class HelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number
end

#--------------------
class RequiredHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, presence: true
end

#--------------------
class OptionalHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, presence: false
end

#--------------------
class FormattedHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, with: /\A\+\d+/
end

#--------------------
class NotFormattedHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, without: /\A\+\d+/
end

#--------------------
class NormalizableHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, normalized_country_code: 'US'
end

#--------------------
class AustralianHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, country_number: '61'
end

#--------------------
class PolishHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, country_code: 'PL'
end

#--------------------
class BigHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, presence: true, with: /\A\+\d+/, country_number: '33'
end

#--------------------
class MismatchedHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number, :country_code
  validates :phone_number, phony_plausible: { ignore_record_country_code: true }
end

#--------------------

class InvalidCountryCodeHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number
  validates_plausible_phone :phone_number

  def country_code
    '--'
  end
end

#--------------------
class SymbolizableHelpfulHome < ActiveRecord::Base
  attr_accessor :phone_number, :phone_number_country_code
  validates_plausible_phone :phone_number, country_code: :phone_number_country_code
end

#--------------------
class NoModelMethod < HelpfulHome
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, country_code: :nonexistent_method
end

#--------------------
class MessageOptionUndefinedInModel < HelpfulHome
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, message: :email
end

#--------------------
class MessageOptionSameAsModelMethod < HelpfulHome
  attr_accessor :phone_number
  validates_plausible_phone :phone_number, message: :email

  def email
    'user@example.com'
  end
end
#-----------------------------------------------------------------------------------------------------------------------
# Tests
#-----------------------------------------------------------------------------------------------------------------------

I18n.locale = :en
VALID_NUMBER = '1 555 555 5555'
VALID_NUMBER_WITH_EXTENSION = '1 555 555 5555 x123'
VALID_NUMBER_WITH_INVALID_EXTENSION = '1 555 555 5555 x1a'
NORMALIZABLE_NUMBER = '555 555 5555'
AUSTRALIAN_NUMBER_WITH_COUNTRY_CODE = '61390133997'
POLISH_NUMBER_WITH_COUNTRY_CODE = '48600600600'
FORMATTED_AUSTRALIAN_NUMBER_WITH_COUNTRY_CODE = '+61 390133997'
FRENCH_NUMBER_WITH_COUNTRY_CODE = '33627899541'
FORMATTED_FRENCH_NUMBER_WITH_COUNTRY_CODE = '+33 627899541'
INVALID_NUMBER = '123456789 123456789 123456789 123456789'
NOT_A_NUMBER = 'HAHA'
JAPAN_COUNTRY = 'jp'

#-----------------------------------------------------------------------------------------------------------------------
describe PhonyPlausibleValidator do
  #--------------------
  describe '#validates' do
    before(:each) do
      @home = SimpleHome.new
    end

    it 'should validate an empty number' do
      expect(@home).to be_valid
    end

    it 'should validate a valid number' do
      @home.phone_number = VALID_NUMBER
      expect(@home).to be_valid
    end

    it 'should validate a valid number with extension' do
      @home.phone_number = VALID_NUMBER_WITH_EXTENSION
      expect(@home).to be_valid
    end

    it 'should invalidate an invalid number' do
      @home.phone_number = INVALID_NUMBER
      expect(@home).to_not be_valid
      expect(@home.errors.messages).to include(phone_number: ['is an invalid number'])
    end

    it 'should invalidate an valid number with invalid extension' do
      @home.phone_number = VALID_NUMBER_WITH_INVALID_EXTENSION
      expect(@home).to_not be_valid
      expect(@home.errors.messages).to include(phone_number: ['is an invalid number'])
    end

    it 'should invalidate not a number' do
      @home.phone_number = NOT_A_NUMBER
      expect(@home).to_not be_valid
      expect(@home.errors.messages).to include(phone_number: ['is an invalid number'])
    end

    it 'should translate the error message in Dutch' do
      I18n.with_locale(:nl) do
        @home.phone_number = INVALID_NUMBER
        @home.valid?
        expect(@home.errors.messages).to include(phone_number: ['is geen geldig nummer'])
      end
    end

    it 'should translate the error message in English' do
      I18n.with_locale(:en) do
        @home.phone_number = INVALID_NUMBER
        @home.valid?
        expect(@home.errors.messages).to include(phone_number: ['is an invalid number'])
      end
    end

    it 'should translate the error message in French' do
      I18n.with_locale(:fr) do
        @home.phone_number = INVALID_NUMBER
        @home.valid?
        expect(@home.errors.messages).to include(phone_number: ['est un numéro invalide'])
      end
    end

    it 'should translate the error message in Japanese' do
      I18n.with_locale(:ja) do
        @home.phone_number = INVALID_NUMBER
        @home.valid?
        expect(@home.errors.messages).to include(phone_number: ['は正しい電話番号ではありません'])
      end
    end

    it 'should translate the error message in Khmer' do
      I18n.with_locale(:km) do
        @home.phone_number = INVALID_NUMBER
        @home.valid?
        expect(@home.errors.messages).to include(phone_number: ['គឺជាលេខមិនត្រឹមត្រូវ'])
      end
    end

    it 'should translate the error message in Ukrainian' do
      I18n.with_locale(:uk) do
        @home.phone_number = INVALID_NUMBER
        @home.valid?
        expect(@home.errors.messages).to include(phone_number: ['є недійсним номером'])
      end
    end

    it 'should translate the error message in Russian' do
      I18n.with_locale(:ru) do
        @home.phone_number = INVALID_NUMBER
        @home.valid?
        expect(@home.errors.messages).to include(phone_number: ['является недействительным номером'])
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

      it 'should validate an empty number' do
        expect(@home).to be_valid
      end

      it 'should validate a valid number' do
        @home.phone_number = VALID_NUMBER
        expect(@home).to be_valid
      end

      it 'should invalidate an invalid number' do
        @home.phone_number = INVALID_NUMBER
        expect(@home).to_not be_valid
        expect(@home.errors.messages).to include(phone_number: ['is an invalid number'])
      end
    end

    #--------------------
    context 'when a number is required (:presence = true)' do
      before(:each) do
        @home = RequiredHelpfulHome.new
      end

      it 'should invalidate an empty number' do
        expect(@home).to_not be_valid
        expect(@home.errors.messages).to include(phone_number: ["can't be blank"])
      end

      it 'should validate a valid number' do
        @home.phone_number = VALID_NUMBER
        expect(@home).to be_valid
      end

      it 'should invalidate an invalid number' do
        @home.phone_number = INVALID_NUMBER
        expect(@home).to_not be_valid
        expect(@home.errors.messages).to include(phone_number: ['is an invalid number'])
      end
    end

    #--------------------
    context 'when a number is not required (!presence = false)' do
      before(:each) do
        @home = OptionalHelpfulHome.new
      end

      it 'should validate an nil number' do
        @home.phone_number = nil
        expect(@home).to be_valid
      end

      it 'should validate an empty number' do
        @home.phone_number = ''
        expect(@home).to be_valid
      end

      it 'should validate a valid number' do
        @home.phone_number = VALID_NUMBER
        expect(@home).to be_valid
      end

      it 'should invalidate an invalid number' do
        @home.phone_number = INVALID_NUMBER
        expect(@home).to_not be_valid
        expect(@home.errors.messages).to include(phone_number: ['is an invalid number'])
      end
    end

    #--------------------
    context 'when a number must be formatted (:with)' do
      before(:each) do
        @home = FormattedHelpfulHome.new
      end

      it 'should invalidate an empty number' do
        expect(@home).to_not be_valid
        expect(@home.errors.messages).to include(phone_number: ['is invalid'])
      end

      it 'should validate a well formatted valid number' do
        @home.phone_number = "+#{VALID_NUMBER}"
        expect(@home).to be_valid
      end

      it 'should invalidate a bad formatted valid number' do
        @home.phone_number = VALID_NUMBER
        expect(@home).to_not be_valid
        expect(@home.errors.messages).to include(phone_number: ['is invalid'])
      end
    end

    #--------------------
    context 'when a number must not be formatted (:without)' do
      before(:each) do
        @home = NotFormattedHelpfulHome.new
      end

      it 'should validate an empty number' do
        expect(@home).to be_valid
      end

      it 'should validate a well formatted valid number' do
        @home.phone_number = VALID_NUMBER
        expect(@home).to be_valid
      end

      it 'should invalidate a bad formatted valid number' do
        @home.phone_number =  "+#{VALID_NUMBER}"
        expect(@home).to_not be_valid
        expect(@home.errors.messages).to include(phone_number: ['is invalid'])
      end
    end

    #--------------------
    context 'when a number must include a specific country number' do
      before(:each) do
        @home = AustralianHelpfulHome.new
      end

      it 'should validate an empty number' do
        expect(@home).to be_valid
      end

      it 'should validate a valid number with the right country code' do
        @home.phone_number = AUSTRALIAN_NUMBER_WITH_COUNTRY_CODE
        expect(@home).to be_valid
      end

      it 'should invalidate a valid number with the wrong country code' do
        @home.phone_number = FRENCH_NUMBER_WITH_COUNTRY_CODE
        expect(@home).to_not be_valid
        expect(@home.errors.messages).to include(phone_number: ['is an invalid number'])
      end

      it 'should invalidate a valid number without a country code' do
        @home.phone_number = VALID_NUMBER
        expect(@home).to_not be_valid
        expect(@home.errors.messages).to include(phone_number: ['is an invalid number'])
      end
    end

    #--------------------
    context 'when a number must be validated after normalization' do
      before(:each) do
        @home = NormalizableHelpfulHome.new
      end

      it 'should validate an empty number' do
        expect(@home).to be_valid
      end

      it 'should validate a valid number' do
        @home.phone_number = VALID_NUMBER
        expect(@home).to be_valid
      end

      it 'should validate a normalizable number' do
        @home.phone_number = NORMALIZABLE_NUMBER
        expect(@home).to be_valid
      end

      it 'should invalidate an invalid number' do
        @home.phone_number = INVALID_NUMBER
        expect(@home).to_not be_valid
        expect(@home.errors.messages).to include(phone_number: ['is an invalid number'])
      end
    end

    #--------------------
    context 'when a number must include a specific country code' do
      before(:each) do
        @home = PolishHelpfulHome.new
      end

      it 'should validate an empty number' do
        expect(@home).to be_valid
      end

      it 'should validate a valid number with the right country code' do
        @home.phone_number = POLISH_NUMBER_WITH_COUNTRY_CODE
        expect(@home).to be_valid
      end

      it 'should invalidate a valid number with the wrong country code' do
        @home.phone_number = FRENCH_NUMBER_WITH_COUNTRY_CODE
        expect(@home).to_not be_valid
        expect(@home.errors.messages).to include(phone_number: ['is an invalid number'])
      end

      it 'should invalidate a valid number without a country code' do
        @home.phone_number = VALID_NUMBER
        expect(@home).to_not be_valid
        expect(@home.errors.messages).to include(phone_number: ['is an invalid number'])
      end
    end

    context 'when lots of things are being validated simultaneously' do
      before(:each) do
        @home = BigHelpfulHome.new
      end

      it 'should invalidate an empty number' do
        expect(@home).to_not be_valid
      end

      it 'should invalidate an invalid number' do
        @home.phone_number = INVALID_NUMBER
        expect(@home).to_not be_valid
        expect(@home.errors.messages[:phone_number]).to include 'is an invalid number'
      end

      it 'should invalidate a badly formatted number with the right country code' do
        @home.phone_number = FRENCH_NUMBER_WITH_COUNTRY_CODE
        expect(@home).to_not be_valid
        expect(@home.errors.messages[:phone_number]).to include 'is invalid'
      end

      it 'should invalidate a properly formatted number with the wrong country code' do
        @home.phone_number = FORMATTED_AUSTRALIAN_NUMBER_WITH_COUNTRY_CODE
        expect(@home).to_not be_valid
        expect(@home.errors.messages[:phone_number]).to include 'is an invalid number'
      end

      it 'should validate a properly formatted number with the right country code' do
        @home.phone_number = FORMATTED_FRENCH_NUMBER_WITH_COUNTRY_CODE
        expect(@home).to be_valid
      end
    end

    #--------------------
    context 'when a phone number does not match the records country' do
      before(:each) do
        @home = MismatchedHelpfulHome.new
        @home.country_code = JAPAN_COUNTRY
        @home.phone_number = FRENCH_NUMBER_WITH_COUNTRY_CODE
      end

      it 'should allow this number' do
        expect(@home).to be_valid
      end
    end

    #--------------------
    context 'when a country code is set to something invalid' do
      before(:each) do
        @home = InvalidCountryCodeHelpfulHome.new
      end

      it 'should allow any valid number' do
        @home.phone_number = FRENCH_NUMBER_WITH_COUNTRY_CODE
        expect(@home).to be_valid
      end

      it 'should not allow any invalid number' do
        @home.phone_number = INVALID_NUMBER
        expect(@home).to_not be_valid
      end

      it 'should not raise a NoMethodError when looking up a country fails (Regression)' do
        expect do
          @home.valid?
        end.to_not raise_error
      end
    end

    #--------------------
    context 'when a country code is passed as a symbol' do
      before(:each) do
        @home = SymbolizableHelpfulHome.new
      end

      it 'should validate an empty number' do
        expect(@home).to be_valid
      end

      it 'should validate a valid number with the right country code' do
        @home.phone_number = POLISH_NUMBER_WITH_COUNTRY_CODE
        @home.phone_number_country_code = 'PL'
        expect(@home).to be_valid
      end

      it 'should invalidate a valid number with the wrong country code' do
        @home.phone_number = FRENCH_NUMBER_WITH_COUNTRY_CODE
        @home.phone_number_country_code = 'PL'
        expect(@home).to_not be_valid
        expect(@home.errors.messages).to include(phone_number: ['is an invalid number'])
      end

      it 'should invalidate a valid number without a country code' do
        @home.phone_number = VALID_NUMBER
        @home.phone_number_country_code = 'PL'
        expect(@home).to_not be_valid
        expect(@home.errors.messages).to include(phone_number: ['is an invalid number'])
      end
    end

    #--------------------
    context 'when a nonexistent method is passed as a symbol to an option other than message' do
      it 'raises NoMethodError' do
        @home = NoModelMethod.new
        @home.phone_number = FRENCH_NUMBER_WITH_COUNTRY_CODE

        expect { @home.save }.to raise_error(NoMethodError)
      end
    end

    #--------------------
    context 'when a nonexistent method is passed as a symbol to the message option' do
      it 'does not raise an error' do
        @home = MessageOptionUndefinedInModel.new
        @home.phone_number = INVALID_NUMBER

        expect { @home.save }.to_not raise_error
      end
    end

    #--------------------
    context 'when an existing Model method is passed as a symbol to the message option' do
      it 'does not use the Model method' do
        @home = MessageOptionSameAsModelMethod.new
        @home.phone_number = INVALID_NUMBER

        expect(@home).to_not receive(:email)

        @home.save
      end
    end
  end
end

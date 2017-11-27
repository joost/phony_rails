# frozen_string_literal: true

require 'coveralls'
Coveralls.wear!

# Own code here.

require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'mongoid'
require 'phony_rails'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  create_table :active_record_models do |table|
    table.column :phone_attribute, :string
    table.column :phone_number, :string
    table.column :phone_number_as_normalized, :string
    table.column :fax_number, :string
    table.column :country_code_attribute, :string
    table.column :symboled_phone, :string
  end
end

module SharedModelMethods
  extend ActiveSupport::Concern
  included do
    attr_accessor :phone_method, :phone1_method, :symboled_phone_method, :country_code, :country_code_attribute, :recipient, :delivery_method
    phony_normalized_method :phone_attribute # adds normalized_phone_attribute method
    phony_normalized_method :phone_method # adds normalized_phone_method method
    phony_normalized_method :phone1_method, default_country_code: 'DE' # adds normalized_phone_method method
    phony_normalized_method :symboled_phone_method, country_code: :country_code_attribute # adds phone_with_symboled_options method
    phony_normalize :phone_number # normalized on validation
    phony_normalize :fax_number, default_country_code: 'AU'
    phony_normalize :symboled_phone, default_country_code: :country_code_attribute

    def use_phone?
      delivery_method == 'sms'
    end

    def use_email?
      delivery_method == 'email'
    end
  end
end

class ActiveRecordModel < ActiveRecord::Base
  include SharedModelMethods
end

class RelaxedActiveRecordModel < ActiveRecord::Base
  self.table_name = 'active_record_models'
  attr_accessor :phone_number, :country_code

  phony_normalize :phone_number, enforce_record_country: false
end

class ActiveRecordDummy < ActiveRecordModel
end

# In case you don't want a database for your model
class ActiveModelModel
  include ActiveModel::Model # this provides most of the interface of AR
  include ActiveModel::Validations::Callbacks # we use callbacks for normalization
  include SharedModelMethods

  # database columns don't give us free attributes, we have to define them
  attr_accessor :phone_number, :phone_attribute, :phone_number_as_normalized, :country_code_attribute, :fax_number, :symboled_phone
end

class ActiveModelDummy < ActiveModelModel
end

class MongoidModel
  include Mongoid::Document
  include Mongoid::Phony
  field :phone_attribute, type: String
  field :phone_number,    type: String
  field :phone_number_as_normalized, type: String
  field :fax_number
  field :country_code_attribute, type: String
  field :symboled_phone, type: String
  include SharedModelMethods
end

class MongoidDummy < MongoidModel
end

I18n.config.enforce_available_locales = true

# RSpec.configure do |config|
#   # some (optional) config here
# end

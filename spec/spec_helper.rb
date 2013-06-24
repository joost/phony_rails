require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'mongoid'
require 'phony_rails'

ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => ":memory:"
)

ActiveRecord::Schema.define do
  create_table :active_record_models do |table|
    table.column :phone_attribute, :string
    table.column :phone_number, :string
    table.column :phone_number_as_normalized, :string
  end
end

class ActiveRecordModel < ActiveRecord::Base
  attr_accessor :phone_method, :phone1_method, :country_code
  phony_normalized_method :phone_attribute # adds normalized_phone_attribute method
  phony_normalized_method :phone_method # adds normalized_phone_method method
  phony_normalized_method :phone1_method, :default_country_code => 'DE' # adds normalized_phone_method method
  phony_normalize :phone_number # normalized on validation
end

class ActiveRecordDummy < ActiveRecordModel
end

class MongoidModel
  include Mongoid::Document
  include Mongoid::Phony
  field :phone_attribute, type: String
  field :phone_number,    type: String
  field :phone_number_as_normalized, type: String
  attr_accessor :phone_method, :phone1_method, :country_code
  phony_normalized_method :phone_attribute # adds normalized_phone_attribute method
  phony_normalized_method :phone_method # adds normalized_phone_method method
  phony_normalized_method :phone1_method, :default_country_code => 'DE' # adds normalized_phone_method method
  phony_normalize :phone_number # normalized on validation
end

class MongoidDummy < MongoidModel
end

RSpec.configure do |config|
  # some (optional) config here
end
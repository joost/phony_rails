require 'spec_helper'
describe PhonyRails do

  describe 'String extensions' do
    it "should phony_format a String" do
      "31101234123".phony_formatted(:format => :international, :spaces => '-').should eql('+31-10-1234123')
    end
  end

  describe 'PhonyRails#normalize_number' do
    it "should normalize a number with a default_country_code" do
      PhonyRails.normalize_number('010-1234123', :default_country_code => 'NL').should eql('31101234123')
    end

    it "should normalize a number with a country_code" do
      PhonyRails.normalize_number('010-1234123', :country_code => 'NL', :default_country_code => 'DE').should eql('31101234123')
      PhonyRails.normalize_number('010-1234123', :country_code => 'NL').should eql('31101234123')
    end

    it "should handle different countries" do
      PhonyRails.normalize_number('(030) 8 61 29 06', :country_code => 'DE').should eql('49308612906')
      PhonyRails.normalize_number('+43 664 3830412', :country_code => 'AT').should eql('436643830412')
      PhonyRails.normalize_number('0203 330 8897', :country_code => 'GB').should eql('442033308897')
    end

    it "should handle some edge cases" do
      PhonyRails.normalize_number('some nasty stuff in this +31 number 10-1234123 string', :country_code => 'NL').should eql('31101234123')
      PhonyRails.normalize_number('070-4157134', :country_code => 'NL').should eql('31704157134')
      PhonyRails.normalize_number('0031-70-4157134', :country_code => 'NL').should eql('31704157134')
      PhonyRails.normalize_number('+31-70-4157134', :country_code => 'NL').should eql('31704157134')
      PhonyRails.normalize_number('0323-2269497', :country_code => 'BE').should eql('323232269497')
    end
  end

  describe 'defining ActiveRecord#phony_normalized_method' do
    it "should add a normalized_phone_attribute method" do
      Home.new.should respond_to(:normalized_phone_attribute)
    end

    it "should add a normalized_phone_method method" do
      Home.new.should respond_to(:normalized_phone_method)
    end

    it "should raise error on existing methods" do
      lambda {
        Home.phony_normalized_method(:phone_method)
      }.should raise_error(StandardError)
    end

    it "should raise error on not existing attribute" do
      Home.phony_normalized_method(:phone_non_existing_method)
      lambda {
        Home.new.normalized_phone_non_existing_method
      }.should raise_error(ArgumentError)
    end
  end

  describe 'defining ActiveRecord#phony_normalize' do
    it "should not accept :as option with multiple attribute names" do
      lambda {
        Home.phony_normalize(:phone_number, :phone1_method, :as => 'non_existing_attribute')
      }.should raise_error(ArgumentError)
    end

    it "should not accept :as option with unexisting attribute name" do
      lambda {
        Home.phony_normalize(:non_existing_attribute, :as => 'non_existing_attribute')
      }.should raise_error(ArgumentError)
    end

    it "should not accept :as option with single non existing attribute name" do
      lambda {
        Home.phony_normalize(:phone_number, :as => 'something_else')
      }.should raise_error(ArgumentError)
    end

    it "should accept :as option with single existing attribute name" do
      lambda {
        Home.phony_normalize(:phone_number, :as => 'phone_number_as_normalized')
      }.should_not raise_error(ArgumentError)
    end
  end

  describe 'using ActiveRecord#phony_normalized_method' do
  # Following examples have complete number (with country code!)
    it "should return a normalized version of an attribute" do
      home = Home.new(:phone_attribute => "+31-(0)10-1234123")
      home.normalized_phone_attribute.should eql('31101234123')
    end

    it "should return a normalized version of a method" do
      home = Home.new(:phone_method => "+31-(0)10-1234123")
      home.normalized_phone_method.should eql('31101234123')
    end

  # Following examples have incomplete number
    it "should return nil if no country_code is known" do
      home = Home.new(:phone_attribute => "(0)10-1234123")
      home.normalized_phone_attribute.should eql('11234123') # This actually is an incorrect number! (FIXME?)
    end

    it "should use country_code option" do
      home = Home.new(:phone_attribute => "(0)10-1234123")
      home.normalized_phone_attribute(:country_code => 'NL').should eql('31101234123')
    end

    it "should use country_code object method" do
      home = Home.new(:phone_attribute => "(0)10-1234123", :country_code => 'NL')
      home.normalized_phone_attribute.should eql('31101234123')
    end

    it "should fallback to default_country_code option" do
      home = Home.new(:phone1_method => "(030) 8 61 29 06")
      home.normalized_phone1_method.should eql('49308612906')
    end

    it "should overwrite default_country_code option with object method" do
      home = Home.new(:phone1_method => "(030) 8 61 29 06", :country_code => 'NL')
      home.normalized_phone1_method.should eql('31308612906')
    end

    it "should overwrite default_country_code option with option" do
      home = Home.new(:phone1_method => "(030) 8 61 29 06")
      home.normalized_phone1_method(:country_code => 'NL').should eql('31308612906')
    end

    it "should use last passed options" do 
      home = Home.new(:phone1_method => "(030) 8 61 29 06")
      home.normalized_phone1_method(:country_code => 'NL').should eql('31308612906')
      home.normalized_phone1_method(:country_code => 'DE').should eql('49308612906')
      home.normalized_phone1_method(:country_code => nil).should eql('49308612906')
    end

    it "should use last object method" do 
      home = Home.new(:phone1_method => "(030) 8 61 29 06")
      home.country_code = 'NL'
      home.normalized_phone1_method.should eql('31308612906')
      home.country_code = 'DE'
      home.normalized_phone1_method.should eql('49308612906')
      home.country_code = nil
      home.normalized_phone1_method(:country_code => nil).should eql('49308612906')
    end
  end

  describe 'using ActiveRecord#phony_normalize' do
    it "should set a normalized version of an attribute" do
      home = Home.new(:phone_number => "+31-(0)10-1234123")
      home.valid?.should be_true
      home.phone_number.should eql('31101234123')
    end

    it "should set a normalized version of an attribute using :as option" do
      Home.phony_normalize :phone_number, :as => :phone_number_as_normalized
      home = Home.new(:phone_number => "+31-(0)10-1234123")
      home.valid?.should be_true
      home.phone_number_as_normalized.should eql('31101234123')
    end    
  end
end
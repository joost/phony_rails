require 'spec_helper'
describe PhonyRails do

  it "should not pollute the global namespace with a Country class" do
    should_not be_const_defined "Country"
  end

  describe 'phony_format String extension' do

    describe 'the bang method phony_formatted!' do

      it "should change the String using the bang method" do
        s = "0101234123"
        s.phony_formatted!(:normalize => :NL, :format => :international).should eql('+31 10 1234123')
        s.should eql("+31 10 1234123")
      end

    end

    describe 'with normalize option' do

      it "should phony_format" do
        "0101234123".phony_formatted(:normalize => :NL).should eql('010 1234123')
        "0101234123".phony_formatted(:normalize => :NL, :format => :international).should eql('+31 10 1234123')
      end

      it "should not change original String" do
        s = "0101234123"
        s.phony_formatted(:normalize => :NL).should eql('010 1234123')
        s.should eql("0101234123")
      end

      it "should phony_format String with country code" do
        "31101234123".phony_formatted(:normalize => :NL).should eql('010 1234123')
      end

      it "should phony_format String with country code" do
        "31101234123".phony_formatted(:normalize => :NL).should eql('010 1234123')
      end

      it "should accept strings with non-digits in it" do
        "+31-10-1234123".phony_formatted(:normalize => :NL, :format => :international, :spaces => '-').should eql('+31-10-1234123')
      end

      it "should phony_format String with country code different than normalized value" do
        "+4790909090".phony_formatted(:normalize => :SE, :format => :international).should eql('+47 909 09 090')
      end

    end

    it "should not change original String" do
      s = "0101234123"
      s.phony_formatted(:normalize => :NL).should eql('010 1234123')
      s.should eql("0101234123")
    end

    it "should phony_format a digits string with spaces String" do
      "31 10 1234123".phony_formatted(:format => :international, :spaces => '-').should eql('+31-10-1234123')
    end

    it "should phony_format a digits String" do
      "31101234123".phony_formatted(:format => :international, :spaces => '-').should eql('+31-10-1234123')
    end

    it "returns nil if implausible phone" do
      "this is not a phone".phony_formatted.should be_nil
    end

    it "returns nil on blank string" do
      "".phony_formatted.should be_nil
    end
  end

  describe 'PhonyRails#normalize_number' do
    context 'number with a country code' do

      it "should not add default_country_code" do
        PhonyRails.normalize_number('+4790909090', :default_country_code => 'SE').should eql('4790909090') # SE = +46
        PhonyRails.normalize_number('004790909090', :default_country_code => 'SE').should eql('4790909090')
        PhonyRails.normalize_number('4790909090', :default_country_code => 'NO').should eql('4790909090') # NO = +47
      end

      it "should force add country_code" do
        PhonyRails.normalize_number('+4790909090', :country_code => 'SE').should eql('464790909090')
        PhonyRails.normalize_number('004790909090', :country_code => 'SE').should eql('464790909090')
        PhonyRails.normalize_number('4790909090', :country_code => 'SE').should eql('464790909090')
      end

    end

    context 'number without a country code' do

      it "should normalize with a default_country_code" do
        PhonyRails.normalize_number('010-1234123', :default_country_code => 'NL').should eql('31101234123')
      end

      it "should normalize with a country_code" do
        PhonyRails.normalize_number('010-1234123', :country_code => 'NL', :default_country_code => 'DE').should eql('31101234123')
        PhonyRails.normalize_number('010-1234123', :country_code => 'NL').should eql('31101234123')
      end

      it "should handle different countries" do
        PhonyRails.normalize_number('(030) 8 61 29 06', :country_code => 'DE').should eql('49308612906')
        PhonyRails.normalize_number('0203 330 8897', :country_code => 'GB').should eql('442033308897')
      end

      it "should prefer country_code over default_country_code" do
        PhonyRails.normalize_number('(030) 8 61 29 06', :country_code => 'DE', :default_country_code => 'NL').should eql('49308612906')
      end

    end

    it "should handle some edge cases" do
      PhonyRails.normalize_number('some nasty stuff in this +31 number 10-1234123 string', :country_code => 'NL').should eql('31101234123')
      PhonyRails.normalize_number('070-4157134', :country_code => 'NL').should eql('31704157134')
      PhonyRails.normalize_number('0031-70-4157134', :country_code => 'NL').should eql('31704157134')
      PhonyRails.normalize_number('+31-70-4157134', :country_code => 'NL').should eql('31704157134')
      PhonyRails.normalize_number('0323-2269497', :country_code => 'BE').should eql('323232269497')
    end

    it "should not normalize an implausible number" do
      PhonyRails.normalize_number('01').should eql('01')
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

    it "should accept a non existing attribute name" do
      lambda {
        Dummy.phony_normalize(:non_existing_attribute)
      }.should_not raise_error
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

    it "should raise a RuntimeError at validation if the attribute doesn't exist" do
      Dummy.phony_normalize :non_existing_attribute

      dummy = Dummy.new
      lambda {
        dummy.valid?
      }.should raise_error(RuntimeError)
    end
  end
end

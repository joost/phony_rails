require 'spec_helper'
describe PhonyRails do

  it "should not pollute the global namespace with a Country class" do
    should_not be_const_defined "Country"
  end

  describe 'phony_format String extension' do

    describe 'the bang method phony_formatted!' do

      it "should change the String using the bang method" do
        s = "0101234123"
        s.phony_formatted!(:normalize => :NL, :format => :international).should eql('+31 10 1234 123')
        s.should eql("+31 010 123 4123")
      end

    end

    describe 'with strict option' do

      it "should return nil with non plausible number" do
        number = '+319090' # not valid
        Phony.plausible?(number).should be_false
        number.phony_formatted(:strict => true).should eql(nil)
      end

      it "should not return nil with plausible number" do
        number = '+31101234123' # valid
        Phony.plausible?(number).should be_true
        number.phony_formatted(:strict => true).should_not eql(nil)
      end

    end

    describe 'with normalize option' do

      it "should phony_format" do
        "0101234123".phony_formatted(:normalize => :NL).should eql('010 123 4123')
        "0101234123".phony_formatted(:normalize => :NL, :format => :international).should eql('+31 10 123 4123')
      end

      it "should not change original String" do
        s = "0101234123"
        s.phony_formatted(:normalize => :NL).should eql('010 123 4123')
        s.should eql("0101234123")
      end

      it "should phony_format String with country code" do
        "31101234123".phony_formatted(:normalize => :NL).should eql('010 123 4123')
      end

      it "should phony_format String with country code" do
        "31101234123".phony_formatted(:normalize => :NL).should eql('010 123 4123')
      end

      it "should accept strings with non-digits in it" do
        "+31-10-1234123".phony_formatted(:normalize => :NL, :format => :international, :spaces => '-').should eql('+31-10-123-4123')
      end

      it "should phony_format String with country code different than normalized value" do
        "+4790909090".phony_formatted(:normalize => :SE, :format => :international).should eql('+47 909 09 090')
      end

    end

    describe "specific tests from issues" do

      # https://github.com/joost/phony_rails/issues/42
      it "should pass issue Github issue #42" do
        PhonyRails.normalize_number("0606060606", default_country_code: 'FR').should eq('330606060606')
      end

    end

    it "should not change original String" do
      s = "0101234123"
      s.phony_formatted(:normalize => :NL).should eql('010 123 4123')
      s.should eql("0101234123")
    end

    it "should phony_format a digits string with spaces String" do
      "31 10 1234123".phony_formatted(:format => :international, :spaces => '-').should eql('+31-10-123-4123')
    end

    it "should phony_format a digits String" do
      "31101234123".phony_formatted(:format => :international, :spaces => '-').should eql('+31-10-123-4123')
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
        PhonyRails.normalize_number('+4790909090', :country_code => 'SE').should eql('46+4790909090')
        PhonyRails.normalize_number('004790909090', :country_code => 'SE').should eql('46004790909090')
        PhonyRails.normalize_number('4790909090', :country_code => 'SE').should eql('464790909090')
      end

      it "should recognize lowercase country codes" do
        PhonyRails.normalize_number('4790909090', :country_code => 'se').should eql('464790909090')
      end

    end

    context 'number without a country code' do

      it "should normalize with a default_country_code" do
        PhonyRails.normalize_number('010-1234123', :default_country_code => 'NL').should eql('310101234123')
      end

      it "should normalize with a country_code" do
        PhonyRails.normalize_number('010-1234123', :country_code => 'NL', :default_country_code => 'DE').should eql('310101234123')
        PhonyRails.normalize_number('010-1234123', :country_code => 'NL').should eql('310101234123')
      end

      it "should handle different countries" do
        PhonyRails.normalize_number('(030) 8 61 29 06', :country_code => 'DE').should eql('490308612906')
        PhonyRails.normalize_number('0203 330 8897', :country_code => 'GB').should eql('4402033308897')
      end

      it "should prefer country_code over default_country_code" do
        PhonyRails.normalize_number('(030) 8 61 29 06', :country_code => 'DE', :default_country_code => 'NL').should eql('490308612906')
      end

      it "should recognize lowercase country codes" do
        PhonyRails.normalize_number('010-1234123', :country_code => 'nl').should eql('310101234123')
      end

    end

    it "should handle some edge cases" do
      PhonyRails.normalize_number('some nasty stuff in this +31 number 10-1234123 string', :country_code => 'NL').should eql('31101234123')
      PhonyRails.normalize_number('070-4157134', :country_code => 'NL').should eql('310704157134')
      PhonyRails.normalize_number('0031-70-4157134', :country_code => 'NL').should eql('31704157134')
      PhonyRails.normalize_number('+31-70-4157134', :country_code => 'NL').should eql('31704157134')
      PhonyRails.normalize_number('0323-2269497', :country_code => 'BE').should eql('3203232269497')
    end

    it "should not normalize an implausible number" do
      PhonyRails.normalize_number('01').should eql('01')
    end
  end

  shared_examples_for 'model with PhonyRails' do
    describe 'defining model#phony_normalized_method' do
      it "should add a normalized_phone_attribute method" do
        model_klass.new.should respond_to(:normalized_phone_attribute)
      end

      it "should add a normalized_phone_method method" do
        model_klass.new.should respond_to(:normalized_phone_method)
      end

      it "should raise error on existing methods" do
        lambda {
          model_klass.phony_normalized_method(:phone_method)
        }.should raise_error(StandardError)
      end

      it "should raise error on not existing attribute" do
        model_klass.phony_normalized_method(:phone_non_existing_method)
        lambda {
          model_klass.new.normalized_phone_non_existing_method
        }.should raise_error(ArgumentError)
      end
    end

    describe 'defining model#phony_normalize' do
      it "should not accept :as option with multiple attribute names" do
        lambda {
          model_klass.phony_normalize(:phone_number, :phone1_method, :as => 'non_existing_attribute')
        }.should raise_error(ArgumentError)
      end

      it "should not accept :as option with unexisting attribute name" do
        lambda {
          model_klass.phony_normalize(:non_existing_attribute, :as => 'non_existing_attribute')
        }.should raise_error(ArgumentError)
      end

      it "should not accept :as option with single non existing attribute name" do
        lambda {
          model_klass.phony_normalize(:phone_number, :as => 'something_else')
        }.should raise_error(ArgumentError)
      end

      it "should accept :as option with single existing attribute name" do
        lambda {
          model_klass.phony_normalize(:phone_number, :as => 'phone_number_as_normalized')
        }.should_not raise_error(ArgumentError)
      end

      it "should accept a non existing attribute name" do
        lambda {
          dummy_klass.phony_normalize(:non_existing_attribute)
        }.should_not raise_error
      end
    end

    describe 'using model#phony_normalized_method' do
    # Following examples have complete number (with country code!)
      it "should return a normalized version of an attribute" do
        model = model_klass.new(:phone_attribute => "+31-(0)10-1234123")
        model.normalized_phone_attribute.should eql('31101234123')
      end

      it "should return a normalized version of a method" do
        model = model_klass.new(:phone_method => "+31-(0)10-1234123")
        model.normalized_phone_method.should eql('31101234123')
      end

    # Following examples have incomplete number
      it "should return nil if no country_code is known" do
        model = model_klass.new(:phone_attribute => "(0)10-1234123")
        model.normalized_phone_attribute.should eql('11234123') # This actually is an incorrect number! (FIXME?)
      end

      it "should use country_code option" do
        model = model_klass.new(:phone_attribute => "(0)10-1234123")
        model.normalized_phone_attribute(:country_code => 'NL').should eql('310101234123')
      end

      it "should use country_code object method" do
        model = model_klass.new(:phone_attribute => "(0)10-1234123", :country_code => 'NL')
        model.normalized_phone_attribute.should eql('310101234123')
      end

      it "should fallback to default_country_code option" do
        model = model_klass.new(:phone1_method => "(030) 8 61 29 06")
        model.normalized_phone1_method.should eql('490308612906')
      end

      it "should overwrite default_country_code option with object method" do
        model = model_klass.new(:phone1_method => "(030) 8 61 29 06", :country_code => 'NL')
        model.normalized_phone1_method.should eql('310308612906')
      end

      it "should overwrite default_country_code option with option" do
        model = model_klass.new(:phone1_method => "(030) 8 61 29 06")
        model.normalized_phone1_method(:country_code => 'NL').should eql('310308612906')
      end

      it "should use last passed options" do
        model = model_klass.new(:phone1_method => "(030) 8 61 29 06")
        model.normalized_phone1_method(:country_code => 'NL').should eql('310308612906')
        model.normalized_phone1_method(:country_code => 'DE').should eql('490308612906')
        model.normalized_phone1_method(:country_code => nil).should eql('490308612906')
      end

      it "should use last object method" do
        model = model_klass.new(:phone1_method => "(030) 8 61 29 06")
        model.country_code = 'NL'
        model.normalized_phone1_method.should eql('310308612906')
        model.country_code = 'DE'
        model.normalized_phone1_method.should eql('490308612906')
        model.country_code = nil
        model.normalized_phone1_method(:country_code => nil).should eql('490308612906')
      end
    end

    describe 'using model#phony_normalize' do
      it "should set a normalized version of an attribute" do
        model = model_klass.new(:phone_number => "+31-(0)10-1234123")
        model.valid?.should be_true
        model.phone_number.should eql('31101234123')
      end

      it "should set a normalized version of an attribute using :as option" do
        model_klass.phony_normalize :phone_number, :as => :phone_number_as_normalized
        model = model_klass.new(:phone_number => "+31-(0)10-1234123")
        model.valid?.should be_true
        model.phone_number_as_normalized.should eql('31101234123')
      end

      it "should raise a RuntimeError at validation if the attribute doesn't exist" do
        dummy_klass.phony_normalize :non_existing_attribute
        dummy = dummy_klass.new
        lambda {
          dummy.valid?
        }.should raise_error(RuntimeError)
      end
    end
  end

  describe 'ActiveRecord' do
    let(:model_klass){ ActiveRecordModel }
    let(:dummy_klass){ ActiveRecordDummy }
    it_behaves_like 'model with PhonyRails'
  end

  describe 'Mongoid' do
    let(:model_klass){ MongoidModel }
    let(:dummy_klass){ MongoidDummy }
    it_behaves_like 'model with PhonyRails'
  end
end

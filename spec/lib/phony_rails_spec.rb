require 'spec_helper'
describe PhonyRails do

  it "should not pollute the global namespace with a Country class" do
    should_not be_const_defined "Country"
  end

  describe 'phony_format String extension' do

    describe 'the phony_formatted method' do

      describe 'with the bang!' do

        it "should change the String using the bang method" do
          s = "0101234123"
          s.phony_formatted!(:normalize => :NL, :format => :international).should eql('+31 10 123 4123')
          s.should eql("+31 10 123 4123")
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
          "101234123".phony_formatted(:normalize => :NL).should eql('010 123 4123')
          "101234123".phony_formatted(:normalize => :NL, :format => :international).should eql('+31 10 123 4123')
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

      describe 'with raise option' do

        # https://github.com/joost/phony_rails/issues/79

        context 'when raise is true' do
          it "should raise the error" do
            lambda {
              "8887716095".phony_formatted(format: :international, raise: true)
            }.should raise_error(NoMethodError)
          end
        end

        context 'when raise is false (default)' do
          it "should return original String on exception" do
            "8887716095".phony_formatted(format: :international).should eq('8887716095')
          end
        end

      end

      describe "specific tests from issues" do

        # https://github.com/joost/phony_rails/issues/79
        it "should pass issue Github issue #42" do
          "8887716095".phony_formatted(format: :international, normalize: 'US', raise: true).should eq('+1 888 771 6095')
        end

        # https://github.com/joost/phony_rails/issues/42
        it "should pass issue Github issue #42" do
          PhonyRails.normalize_number("0606060606", default_country_code: 'FR').should eq('+33606060606')
        end

        it "should pass issue Github issue #85" do
          PhonyRails.normalize_number("47386160",  default_country_code: 'NO').should eq('+4747386160')
          PhonyRails.normalize_number("47386160",  country_number: '47').should eq('+4747386160')
        end
      end

      it "should not change original String" do
        s = '0101234123'
        s.phony_formatted(:normalize => :NL).should eql('010 123 4123')
        s.should eql('0101234123')
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

    describe 'the phony_normalized method' do

      it "returns blank on blank string" do
        "".phony_normalized.should be_nil
      end

      context "when String misses a country_code" do
        it "should normalize with :country_code option" do
          "010 1231234".phony_normalized(:country_code => :NL).should eql("+31101231234")
        end

        it "should normalize without :country_code option" do
          "010 1231234".phony_normalized.should eql("101231234")
        end
      end

      it "should normalize a String" do
        "+31 (0)10 1231234".phony_normalized.should eql("+31101231234")
      end

    end

  end

  describe 'PhonyRails#normalize_number' do
    context 'number with a country code' do

      it "should not add default_country_code" do
        PhonyRails.normalize_number('+4790909090', :default_country_code => 'SE').should eql('+4790909090') # SE = +46
        PhonyRails.normalize_number('004790909090', :default_country_code => 'SE').should eql('+4790909090')
        PhonyRails.normalize_number('4790909090', :default_country_code => 'NO').should eql('+4790909090') # NO = +47
      end

      it "should force add country_code" do
        PhonyRails.normalize_number('+4790909090', :country_code => 'SE').should eql('+464790909090')
        PhonyRails.normalize_number('004790909090', :country_code => 'SE').should eql('+4604790909090') # FIXME: differs due to Phony.normalize in v2.7.1?!
        PhonyRails.normalize_number('4790909090', :country_code => 'SE').should eql('+464790909090')
      end

      it "should recognize lowercase country codes" do
        PhonyRails.normalize_number('4790909090', :country_code => 'se').should eql('+464790909090')
      end

    end

    context 'number without a country code' do

      it "should normalize with a default_country_code" do
        PhonyRails.normalize_number('010-1234123', :default_country_code => 'NL').should eql('+31101234123')
      end

      it "should normalize with a country_code" do
        PhonyRails.normalize_number('010-1234123', :country_code => 'NL', :default_country_code => 'DE').should eql('+31101234123')
        PhonyRails.normalize_number('010-1234123', :country_code => 'NL').should eql('+31101234123')
      end

      it "should handle different countries" do
        PhonyRails.normalize_number('(030) 8 61 29 06', :country_code => 'DE').should eql('+49308612906')
        PhonyRails.normalize_number('0203 330 8897', :country_code => 'GB').should eql('+442033308897')
      end

      it "should prefer country_code over default_country_code" do
        PhonyRails.normalize_number('(030) 8 61 29 06', :country_code => 'DE', :default_country_code => 'NL').should eql('+49308612906')
      end

      it "should recognize lowercase country codes" do
        PhonyRails.normalize_number('010-1234123', :country_code => 'nl').should eql('+31101234123')
      end

    end

    it "should handle some edge cases (with country_code)" do
      PhonyRails.normalize_number('some nasty stuff in this +31 number 10-1234123 string', :country_code => 'NL').should eql('+31101234123')
      PhonyRails.normalize_number('070-4157134', :country_code => 'NL').should eql('+31704157134')
      PhonyRails.normalize_number('0031-70-4157134', :country_code => 'NL').should eql('+31704157134')
      PhonyRails.normalize_number('+31-70-4157134', :country_code => 'NL').should eql('+31704157134')
      PhonyRails.normalize_number('0322-69497', :country_code => 'BE').should eql('+3232269497')
      PhonyRails.normalize_number('+32 3 226 94 97', :country_code => 'BE').should eql('+3232269497')
      PhonyRails.normalize_number('0450 764 000', :country_code => 'AU').should eql('+61450764000')
    end

    it "should handle some edge cases (with default_country_code)" do
      PhonyRails.normalize_number('some nasty stuff in this +31 number 10-1234123 string', :country_code => 'NL').should eql('+31101234123')
      PhonyRails.normalize_number('070-4157134', :default_country_code => 'NL').should eql('+31704157134')
      PhonyRails.normalize_number('0031-70-4157134', :default_country_code => 'NL').should eql('+31704157134')
      PhonyRails.normalize_number('+31-70-4157134', :default_country_code => 'NL').should eql('+31704157134')
      PhonyRails.normalize_number('0322-69497', :default_country_code => 'BE').should eql('+3232269497')
      PhonyRails.normalize_number('+32 3 226 94 97', :default_country_code => 'BE').should eql('+3232269497')
      PhonyRails.normalize_number('0450 764 000', :default_country_code => 'AU').should eql('+61450764000')
    end

    it "should normalize even an implausible number" do
      PhonyRails.normalize_number('01').should eql('1')
    end
  end

  describe 'PhonyRails#plausible_number?' do
    let(:valid_number) { '1 555 555 5555' }
    let(:invalid_number) { '123456789 123456789 123456789 123456789' }
    let(:normalizable_number) { '555 555 5555' }
    let(:formatted_french_number_with_country_code) { '+33 627899541' }
    let(:empty_number) { '' }
    let(:nil_number) { nil }

    it "should return true for a valid number" do
      PhonyRails.plausible_number?(valid_number, country_code: 'US').should be_true
    end

    it "should return false for an invalid number" do
      PhonyRails.plausible_number?(invalid_number, country_code: 'US').should be_false
    end

    it "should return true for a normalizable number" do
      PhonyRails.plausible_number?(normalizable_number, country_code: 'US').should be_true
    end

    it "should return false for a valid number with the wrong country code" do
      PhonyRails.plausible_number?(valid_number, country_code: 'FR').should be_false
    end

    it "should return true for a well formatted valid number" do
      PhonyRails.plausible_number?(formatted_french_number_with_country_code, country_code: 'FR').should be_true
    end

    it "should return false for an empty number" do
      PhonyRails.plausible_number?(empty_number, country_code: 'US').should be_false
    end

    it "should return false for a nil number" do
      PhonyRails.plausible_number?(nil_number, country_code: 'US').should be_false
    end

    it "should return false when no country code is supplied" do
      PhonyRails.plausible_number?(normalizable_number).should be_false
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

      it "should accept :as option with non existing attribute name" do
        lambda {
          dummy_klass.phony_normalize(:non_existing_attribute, :as => 'non_existing_attribute')
        }.should_not raise_error
      end

      it "should accept :as option with single non existing attribute name" do
        lambda {
          dummy_klass.phony_normalize(:phone_number, :as => 'something_else')
        }.should_not raise_error
      end

      it "should accept :as option with single existing attribute name" do
        lambda {
          model_klass.phony_normalize(:phone_number, :as => 'phone_number_as_normalized')
        }.should_not raise_error
      end

      it "should accept a non existing attribute name" do
        lambda {
          dummy_klass.phony_normalize(:non_existing_attribute)
        }.should_not raise_error
      end

      it "should accept supported options" do
        options = [:country_number, :default_country_number, :country_code, :default_country_code, :add_plus, :as]
        options.each do |option_sym|
          lambda {
            dummy_klass.phony_normalize(:phone_number, option_sym => false)
          }.should_not raise_error
        end
      end

      it "should not accept unsupported options" do
        lambda {
          dummy_klass.phony_normalize(:phone_number, unsupported_option: false)
        }.should raise_error(ArgumentError)
      end
    end

    describe 'using model#phony_normalized_method' do
    # Following examples have complete number (with country code!)
      it "should return a normalized version of an attribute" do
        model = model_klass.new(:phone_attribute => "+31-(0)10-1234123")
        model.normalized_phone_attribute.should eql('+31101234123')
      end

      it "should return a normalized version of a method" do
        model = model_klass.new(:phone_method => "+31-(0)10-1234123")
        model.normalized_phone_method.should eql('+31101234123')
      end

    # Following examples have incomplete number
      it "should normalize even a unplausible number (no country code)" do
        model = model_klass.new(:phone_attribute => "(0)10-1234123")
        model.normalized_phone_attribute.should eql('101234123')
      end

      it "should use country_code option" do
        model = model_klass.new(:phone_attribute => "(0)10-1234123")
        model.normalized_phone_attribute(:country_code => 'NL').should eql('+31101234123')
      end

      it "should use country_code object method" do
        model = model_klass.new(:phone_attribute => "(0)10-1234123", :country_code => 'NL')
        model.normalized_phone_attribute.should eql('+31101234123')
      end

      it "should fallback to default_country_code option" do
        model = model_klass.new(:phone1_method => "(030) 8 61 29 06")
        model.normalized_phone1_method.should eql('+49308612906')
      end

      it "should overwrite default_country_code option with object method" do
        model = model_klass.new(:phone1_method => "(030) 8 61 29 06", :country_code => 'NL')
        model.normalized_phone1_method.should eql('+31308612906')
      end

      it "should overwrite default_country_code option with option" do
        model = model_klass.new(:phone1_method => "(030) 8 61 29 06")
        model.normalized_phone1_method(:country_code => 'NL').should eql('+31308612906')
      end

      it "should use last passed options" do
        model = model_klass.new(:phone1_method => "(030) 8 61 29 06")
        model.normalized_phone1_method(:country_code => 'NL').should eql('+31308612906')
        model.normalized_phone1_method(:country_code => 'DE').should eql('+49308612906')
        model.normalized_phone1_method(:country_code => nil).should eql('+49308612906')
      end

      it "should use last object method" do
        model = model_klass.new(:phone1_method => "(030) 8 61 29 06")
        model.country_code = 'NL'
        model.normalized_phone1_method.should eql('+31308612906')
        model.country_code = 'DE'
        model.normalized_phone1_method.should eql('+49308612906')
        model.country_code = nil
        model.normalized_phone1_method(:country_code => nil).should eql('+49308612906')
      end
    end

    describe 'using model#phony_normalize' do
      it "should not change normalized numbers (see #76)" do
        model = model_klass.new(:phone_number => "+31-(0)10-1234123")
        model.valid?.should be_true
        model.phone_number.should eql('+31101234123')

      end

      it "should set a normalized version of an attribute using :as option" do
        model_klass.phony_normalize :phone_number, :as => :phone_number_as_normalized
        model = model_klass.new(:phone_number => "+31-(0)10-1234123")
        model.valid?.should be_true
        model.phone_number_as_normalized.should eql('+31101234123')
      end

      it "should not add a + using :add_plus option" do
        model_klass.phony_normalize :phone_number, :add_plus => false
        model = model_klass.new(:phone_number => "+31-(0)10-1234123")
        model.valid?.should be_true
        model.phone_number.should eql('31101234123')
      end

      it "should raise a RuntimeError at validation if the attribute doesn't exist" do
        dummy_klass.phony_normalize :non_existing_attribute
        dummy = dummy_klass.new
        lambda {
          dummy.valid?
        }.should raise_error(RuntimeError)
      end

      it "should raise a RuntimeError at validation if the :as option attribute doesn't exist" do
        dummy_klass.phony_normalize :phone_number, :as => :non_existing_attribute
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

    it "should correctly keep a hard set country_code" do
      model = model_klass.new(:fax_number => '+1 978 555 0000')
      model.valid?.should be_true
      model.fax_number.should eql('+19785550000')
      model.save.should be_true
      model.save.should be_true # revalidate
      model.reload
      model.fax_number.should eql('+19785550000')
      model.fax_number = '(030) 8 61 29 06'
      model.save.should be_true # revalidate
      model.reload
      model.fax_number.should eql('+61308612906')
    end
  end

  describe 'Mongoid' do
    let(:model_klass){ MongoidModel }
    let(:dummy_klass){ MongoidDummy }
    it_behaves_like 'model with PhonyRails'
  end
end

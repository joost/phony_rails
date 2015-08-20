require 'spec_helper'
describe PhonyRails do

  it "should not pollute the global namespace with a Country class" do
    should_not be_const_defined "Country"
  end

  describe 'phony_format String extension' do

    describe 'the phony_formatted method' do

      it 'should not modify the original options Hash' do
        options = {:normalize => :NL, :format => :international}
        "0101234123".phony_formatted(options)
        expect(options).to eql({:normalize => :NL, :format => :international})
      end

      describe 'with the bang!' do

        it "should change the String using the bang method" do
          s = "0101234123"
          expect(s.phony_formatted!(:normalize => :NL, :format => :international)).to eql('+31 10 123 4123')
          expect(s).to eql("+31 10 123 4123")
        end

      end

      describe 'with strict option' do

        it "should return nil with non plausible number" do
          number = '+319090' # not valid
          expect(Phony.plausible?(number)).to be false
          expect(number.phony_formatted(:strict => true)).to eql(nil)
        end

        it "should not return nil with plausible number" do
          number = '+31101234123' # valid
          expect(Phony.plausible?(number)).to be true
          expect(number.phony_formatted(:strict => true)).to_not eql(nil)
        end

      end

      describe 'with normalize option' do

        it "should phony_format" do
          expect("101234123".phony_formatted(:normalize => :NL)).to eql('010 123 4123')
          expect("101234123".phony_formatted(:normalize => :NL, :format => :international)).to eql('+31 10 123 4123')
        end

        it "should not change original String" do
          s = "0101234123"
          expect(s.phony_formatted(:normalize => :NL)).to eql('010 123 4123')
          expect(s).to eql("0101234123")
        end

        it "should phony_format String with country code" do
          expect("31101234123".phony_formatted(:normalize => :NL)).to eql('010 123 4123')
        end

        it "should phony_format String with country code" do
          expect("31101234123".phony_formatted(:normalize => :NL)).to eql('010 123 4123')
        end

        it "should accept strings with non-digits in it" do
          expect("+31-10-1234123".phony_formatted(:normalize => :NL, :format => :international, :spaces => '-')).to eql('+31-10-123-4123')
        end

        it "should phony_format String with country code different than normalized value" do
          expect("+4790909090".phony_formatted(:normalize => :SE, :format => :international)).to eql('+47 909 09 090')
        end

      end

      describe 'with raise option' do

        # https://github.com/joost/phony_rails/issues/79

        context 'when raise is true' do
          it "should raise the error" do
            expect(lambda {
              "8887716095".phony_formatted(format: :international, raise: true)
            }).to raise_error(NoMethodError)
          end
        end

        context 'when raise is false (default)' do
          it "should return original String on exception" do
            expect("8887716095".phony_formatted(format: :international)).to eq('8887716095')
          end
        end

      end

      describe "specific tests from issues" do

        # https://github.com/joost/phony_rails/issues/79
        it "should pass Github issue #42" do
          expect("8887716095".phony_formatted(format: :international, normalize: 'US', raise: true)).to eq('+1 (888) 771-6095')
        end

        # https://github.com/joost/phony_rails/issues/42
        it "should pass Github issue #42" do
          expect(PhonyRails.normalize_number("0606060606", default_country_code: 'FR')).to eq('+33606060606')
        end

        it "should pass Github issue #85" do
          expect(PhonyRails.normalize_number("47386160",  default_country_code: 'NO')).to eq('+4747386160')
          expect(PhonyRails.normalize_number("47386160",  country_number: '47')).to eq('+4747386160')
        end

        it "should pass Github issue #87" do
          expect(PhonyRails.normalize_number('2318725305', country_code: 'US')).to eq('+12318725305')
          expect(PhonyRails.normalize_number('2318725305', default_country_code: 'US')).to eq('+12318725305')
          expect(PhonyRails.normalize_number('+2318725305', default_country_code: 'US')).to eq('+2318725305')
        end

        it "should pass Github issue #89" do
          number = '+33 (0)6 87 36 18 75'
          expect(Phony.plausible?(number)).to be true
          expect(PhonyRails.normalize_number(number, country_code: 'FR')).to eq('+33687361875')
        end

        it "should pass Github issue #90" do
           number = '(0)30 1234 123'
           expect(number.phony_normalized(country_code: 'NL')).to eq('+31301234123')
        end

        it "should pass Github issue #107" do
           number = '04575700834'
           expect(number.phony_normalized(country_code: 'FI')).to eq('+3584575700834')
           # Seems this number can be interpreted as from multiple countries, following fails:
           # expect(number.phony_normalized(default_country_code: 'FI')).to eq('+3584575700834')
           # expect("04575700834".phony_formatted(normalize: 'FI', format: :international)).to eql('+358 45 757 00 834')
        end

        it "should pass Github issue #113" do
          number = "(951) 703-593"
          expect(lambda {
            number.phony_formatted!(normalize: 'US', :spaces => '-', strict: true)
          }).to raise_error(ArgumentError)
        end

      end

      it "should not change original String" do
        s = '0101234123'
        expect(s.phony_formatted(:normalize => :NL)).to eql('010 123 4123')
        expect(s).to eql('0101234123')
      end

      it "should phony_format a digits string with spaces String" do
        expect("31 10 1234123".phony_formatted(:format => :international, :spaces => '-')).to eql('+31-10-123-4123')
      end

      it "should phony_format a digits String" do
        expect("31101234123".phony_formatted(:format => :international, :spaces => '-')).to eql('+31-10-123-4123')
      end

      it "returns nil if implausible phone" do
        expect("this is not a phone".phony_formatted).to be_nil
      end

      it "returns nil on blank string" do
        expect("".phony_formatted).to be_nil
      end

    end

    describe 'the phony_normalized method' do

      it "returns blank on blank string" do
        expect("".phony_normalized).to be_nil
      end

      it 'should not modify the original options Hash' do
        options = {:normalize => :NL, :format => :international}
        "0101234123".phony_normalized(options)
        expect(options).to eql({:normalize => :NL, :format => :international})
      end

      context "when String misses a country_code" do
        it "should normalize with :country_code option" do
          expect("010 1231234".phony_normalized(:country_code => :NL)).to eql("+31101231234")
        end

        it "should normalize without :country_code option" do
          expect("010 1231234".phony_normalized).to eql("101231234")
        end

        it "should normalize with :add_plus option" do
          expect("010 1231234".phony_normalized(:country_code => :NL, :add_plus => false)).to eql("31101231234")
        end

      end

      it "should normalize with :add_plus option" do
        expect("+31 (0)10 1231234".phony_normalized(:add_plus => false)).to eql("31101231234")
      end

      it "should normalize a String" do
        expect("+31 (0)10 1231234".phony_normalized).to eql("+31101231234")
      end

    end

  end

  describe 'PhonyRails#normalize_number' do
    context 'number with a country code' do

      it "should not add default_country_code" do
        expect(PhonyRails.normalize_number('+4790909090', :default_country_code => 'SE')).to eql('+4790909090') # SE = +46
        expect(PhonyRails.normalize_number('004790909090', :default_country_code => 'SE')).to eql('+4790909090')
        expect(PhonyRails.normalize_number('4790909090', :default_country_code => 'NO')).to eql('+4790909090') # NO = +47
      end

      it "should force add country_code" do
        expect(PhonyRails.normalize_number('+4790909090', :country_code => 'SE')).to eql('+464790909090')
        expect(PhonyRails.normalize_number('004790909090', :country_code => 'SE')).to eql('+4604790909090') # FIXME: differs due to Phony.normalize in v2.7.1?!
        expect(PhonyRails.normalize_number('4790909090', :country_code => 'SE')).to eql('+464790909090')
      end

      it "should recognize lowercase country codes" do
        expect(PhonyRails.normalize_number('4790909090', :country_code => 'se')).to eql('+464790909090')
      end

    end

    context 'number without a country code' do

      it "should normalize with a default_country_code" do
        expect(PhonyRails.normalize_number('010-1234123', :default_country_code => 'NL')).to eql('+31101234123')
      end

      it "should normalize with a country_code" do
        expect(PhonyRails.normalize_number('010-1234123', :country_code => 'NL', :default_country_code => 'DE')).to eql('+31101234123')
        expect(PhonyRails.normalize_number('010-1234123', :country_code => 'NL')).to eql('+31101234123')
      end

      it "should handle different countries" do
        expect(PhonyRails.normalize_number('(030) 8 61 29 06', :country_code => 'DE')).to eql('+49308612906')
        expect(PhonyRails.normalize_number('0203 330 8897', :country_code => 'GB')).to eql('+442033308897')
      end

      it "should prefer country_code over default_country_code" do
        expect(PhonyRails.normalize_number('(030) 8 61 29 06', :country_code => 'DE', :default_country_code => 'NL')).to eql('+49308612906')
      end

      it "should recognize lowercase country codes" do
        expect(PhonyRails.normalize_number('010-1234123', :country_code => 'nl')).to eql('+31101234123')
      end

    end

    it "should handle some edge cases (with country_code)" do
      expect(PhonyRails.normalize_number('some nasty stuff in this +31 number 10-1234123 string', :country_code => 'NL')).to eql('+31101234123')
      expect(PhonyRails.normalize_number('070-4157134', :country_code => 'NL')).to eql('+31704157134')
      expect(PhonyRails.normalize_number('0031-70-4157134', :country_code => 'NL')).to eql('+31704157134')
      expect(PhonyRails.normalize_number('+31-70-4157134', :country_code => 'NL')).to eql('+31704157134')
      expect(PhonyRails.normalize_number('0322-69497', :country_code => 'BE')).to eql('+3232269497')
      expect(PhonyRails.normalize_number('+32 3 226 94 97', :country_code => 'BE')).to eql('+3232269497')
      expect(PhonyRails.normalize_number('0450 764 000', :country_code => 'AU')).to eql('+61450764000')
    end

    it "should handle some edge cases (with default_country_code)" do
      expect(PhonyRails.normalize_number('some nasty stuff in this +31 number 10-1234123 string', :country_code => 'NL')).to eql('+31101234123')
      expect(PhonyRails.normalize_number('070-4157134', :default_country_code => 'NL')).to eql('+31704157134')
      expect(PhonyRails.normalize_number('0031-70-4157134', :default_country_code => 'NL')).to eql('+31704157134')
      expect(PhonyRails.normalize_number('+31-70-4157134', :default_country_code => 'NL')).to eql('+31704157134')
      expect(PhonyRails.normalize_number('0322-69497', :default_country_code => 'BE')).to eql('+3232269497')
      expect(PhonyRails.normalize_number('+32 3 226 94 97', :default_country_code => 'BE')).to eql('+3232269497')
      expect(PhonyRails.normalize_number('0450 764 000', :default_country_code => 'AU')).to eql('+61450764000')
    end

    it "should normalize even an implausible number" do
      expect(PhonyRails.normalize_number('01')).to eql('1')
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
      expect(PhonyRails.plausible_number?(valid_number, country_code: 'US')).to be true
    end

    it "should return false for an invalid number" do
      expect(PhonyRails.plausible_number?(invalid_number, country_code: 'US')).to be false
    end

    it "should return true for a normalizable number" do
      expect(PhonyRails.plausible_number?(normalizable_number, country_code: 'US')).to be true
    end

    it "should return false for a valid number with the wrong country code" do
      expect(PhonyRails.plausible_number?(valid_number, country_code: 'FR')).to be false
    end

    it "should return true for a well formatted valid number" do
      expect(PhonyRails.plausible_number?(formatted_french_number_with_country_code, country_code: 'FR')).to be true
    end

    it "should return false for an empty number" do
      expect(PhonyRails.plausible_number?(empty_number, country_code: 'US')).to be false
    end

    it "should return false for a nil number" do
      expect(PhonyRails.plausible_number?(nil_number, country_code: 'US')).to be false
    end

    it "should return false when no country code is supplied" do
      expect(PhonyRails.plausible_number?(normalizable_number)).to be false
    end
  end

  shared_examples_for 'model with PhonyRails' do
    describe 'defining model#phony_normalized_method' do
      it "should add a normalized_phone_attribute method" do
        expect(model_klass.new).to respond_to(:normalized_phone_attribute)
      end

      it "should add a normalized_phone_method method" do
        expect(model_klass.new).to respond_to(:normalized_phone_method)
      end

      it "should raise error on existing methods" do
        expect(lambda {
          model_klass.phony_normalized_method(:phone_method)
        }).to raise_error(StandardError)
      end

      it "should raise error on not existing attribute" do
        model_klass.phony_normalized_method(:phone_non_existing_method)
        expect(lambda {
          model_klass.new.normalized_phone_non_existing_method
        }).to raise_error(ArgumentError)
      end
    end

    describe 'defining model#phony_normalize' do
      it "should not accept :as option with multiple attribute names" do
        expect(lambda {
          model_klass.phony_normalize(:phone_number, :phone1_method, :as => 'non_existing_attribute')
        }).to raise_error(ArgumentError)
      end

      it "should accept :as option with non existing attribute name" do
        expect(lambda {
          dummy_klass.phony_normalize(:non_existing_attribute, :as => 'non_existing_attribute')
        }).to_not raise_error
      end

      it "should accept :as option with single non existing attribute name" do
        expect(lambda {
          dummy_klass.phony_normalize(:phone_number, :as => 'something_else')
        }).to_not raise_error
      end

      it "should accept :as option with single existing attribute name" do
        expect(lambda {
          model_klass.phony_normalize(:phone_number, :as => 'phone_number_as_normalized')
        }).to_not raise_error
      end

      it "should accept a non existing attribute name" do
        expect(lambda {
          dummy_klass.phony_normalize(:non_existing_attribute)
        }).to_not raise_error
      end

      it "should accept supported options" do
        options = [:country_number, :default_country_number, :country_code, :default_country_code, :add_plus, :as, :enforce_record_country]
        options.each do |option_sym|
          expect(lambda {
            dummy_klass.phony_normalize(:phone_number, option_sym => false)
          }).to_not raise_error
        end
      end

      it "should not accept unsupported options" do
        expect(lambda {
          dummy_klass.phony_normalize(:phone_number, unsupported_option: false)
        }).to raise_error(ArgumentError)
      end
    end

    describe 'using model#phony_normalized_method' do
    # Following examples have complete number (with country code!)
      it "should return a normalized version of an attribute" do
        model = model_klass.new(:phone_attribute => "+31-(0)10-1234123")
        expect(model.normalized_phone_attribute).to eql('+31101234123')
      end

      it "should return a normalized version of a method" do
        model = model_klass.new(:phone_method => "+31-(0)10-1234123")
        expect(model.normalized_phone_method).to eql('+31101234123')
      end

    # Following examples have incomplete number
      it "should normalize even a unplausible number (no country code)" do
        model = model_klass.new(:phone_attribute => "(0)10-1234123")
        expect(model.normalized_phone_attribute).to eql('101234123')
      end

      it "should use country_code option" do
        model = model_klass.new(:phone_attribute => "(0)10-1234123")
        expect(model.normalized_phone_attribute(:country_code => 'NL')).to eql('+31101234123')
      end

      it "should use country_code object method" do
        model = model_klass.new(:phone_attribute => "(0)10-1234123", :country_code => 'NL')
        expect(model.normalized_phone_attribute).to eql('+31101234123')
      end

      it "should fallback to default_country_code option" do
        model = model_klass.new(:phone1_method => "(030) 8 61 29 06")
        expect(model.normalized_phone1_method).to eql('+49308612906')
      end

      it "should overwrite default_country_code option with object method" do
        model = model_klass.new(:phone1_method => "(030) 8 61 29 06", :country_code => 'NL')
        expect(model.normalized_phone1_method).to eql('+31308612906')
      end

      it "should overwrite default_country_code option with option" do
        model = model_klass.new(:phone1_method => "(030) 8 61 29 06")
        expect(model.normalized_phone1_method(:country_code => 'NL')).to eql('+31308612906')
      end

      it "should use last passed options" do
        model = model_klass.new(:phone1_method => "(030) 8 61 29 06")
        expect(model.normalized_phone1_method(:country_code => 'NL')).to eql('+31308612906')
        expect(model.normalized_phone1_method(:country_code => 'DE')).to eql('+49308612906')
        expect(model.normalized_phone1_method(:country_code => nil)).to eql('+49308612906')
      end

      it "should use last object method" do
        model = model_klass.new(:phone1_method => "(030) 8 61 29 06")
        model.country_code = 'NL'
        expect(model.normalized_phone1_method).to eql('+31308612906')
        model.country_code = 'DE'
        expect(model.normalized_phone1_method).to eql('+49308612906')
        model.country_code = nil
        expect(model.normalized_phone1_method(:country_code => nil)).to eql('+49308612906')
      end
    end

    describe 'using model#phony_normalize' do
      it "should not change normalized numbers (see #76)" do
        model = model_klass.new(:phone_number => "+31-(0)10-1234123")
        expect(model.valid?).to be true
        expect(model.phone_number).to eql('+31101234123')
      end

      it "should set a normalized version of an attribute using :as option" do
        model_klass.phony_normalize :phone_number, :as => :phone_number_as_normalized
        model = model_klass.new(:phone_number => "+31-(0)10-1234123")
        expect(model.valid?).to be true
        expect(model.phone_number_as_normalized).to eql('+31101234123')
      end

      it "should not add a + using :add_plus option" do
        model_klass.phony_normalize :phone_number, :add_plus => false
        model = model_klass.new(:phone_number => "+31-(0)10-1234123")
        expect(model.valid?).to be true
        expect(model.phone_number).to eql('31101234123')
      end

      it "should raise a RuntimeError at validation if the attribute doesn't exist" do
        dummy_klass.phony_normalize :non_existing_attribute
        dummy = dummy_klass.new
        expect(lambda {
          dummy.valid?
        }).to raise_error(RuntimeError)
      end

      it "should raise a RuntimeError at validation if the :as option attribute doesn't exist" do
        dummy_klass.phony_normalize :phone_number, :as => :non_existing_attribute
        dummy = dummy_klass.new
        expect(lambda {
          dummy.valid?
        }).to raise_error(RuntimeError)
      end
    end
  end

  describe 'ActiveRecord' do
    let(:model_klass){ ActiveRecordModel }
    let(:dummy_klass){ ActiveRecordDummy }
    it_behaves_like 'model with PhonyRails'

    it "should correctly keep a hard set country_code" do
      model = model_klass.new(:fax_number => '+1 978 555 0000')
      expect(model.valid?).to be true
      expect(model.fax_number).to eql('+19785550000')
      expect(model.save).to be true
      expect(model.save).to be true # revalidate
      model.reload
      expect(model.fax_number).to eql('+19785550000')
      model.fax_number = '(030) 8 61 29 06'
      expect(model.save).to be true # revalidate
      model.reload
      expect(model.fax_number).to eql('+61308612906')
    end

    context 'when enforce_record_country is turned off' do
      let(:model_klass)  { RelaxedActiveRecordModel }
      let(:record)       { model_klass.new }

      before {
        record.phone_number = phone_number
        record.country_code = 'DE'
        record.valid? # run the empty validation chain to execute the before hook (normalized the number)
      }

      context 'when the country_code attribute does not match the country number' do
        context 'when the number is prefixed with a country number and a plus' do
          let(:phone_number) { '+436601234567' }

          it 'should not add the records country number' do
            expect(record.phone_number).to eql('+436601234567')
          end
        end

        # In this case it's not clear if there is a country number, so it should be added
        context 'when the number is prefixed with a country number' do
          let(:phone_number) { '436601234567' }

          it 'should add the records country number' do
            expect(record.phone_number).to eql('+49436601234567')
          end
        end
      end

      # This should be the case anyways
      context 'when the country_code attribute matches the country number' do
        context 'when the number includes a country number and a plus' do
          let(:phone_number) { '+491721234567' }

          it 'should not add the records country number' do
            expect(record.phone_number).to eql('+491721234567')
          end
        end

        context 'when the number has neither country number nor plus' do
          let(:phone_number) { '01721234567' }

          it 'should not add the records country number' do
            expect(record.phone_number).to eql('+491721234567')
          end
        end
      end
    end
  end

  describe 'Mongoid' do
    let(:model_klass){ MongoidModel }
    let(:dummy_klass){ MongoidDummy }
    it_behaves_like 'model with PhonyRails'
  end
end

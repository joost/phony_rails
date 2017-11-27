# frozen_string_literal: true

class String
  # Usage:
  #   "+31 (0)30 1234 123".phony_normalized # => '+31301234123'
  #   "(0)30 1234 123".phony_normalized # => '301234123'
  #   "(0)30 1234 123".phony_normalized(country_code: 'NL') # => '301234123'
  def phony_normalized(options = {})
    raise ArgumentError, "Expected options to be a Hash, got #{options.inspect}" unless options.is_a?(Hash)
    options = options.dup
    PhonyRails.normalize_number(self, options)
  end

  # Add a method to the String class so we can easily format phone numbers.
  # This enables:
  #   "31612341234".phony_formatted # => '06 12341234'
  #   "31612341234".phony_formatted(:spaces => '-') # => '06-12341234'
  # To first normalize a String use:
  #   "010-12341234".phony_formatted(:normalize => :NL)
  # To return nil when a number is not correct (checked using Phony.plausible?) use
  #   "010-12341234".phony_formatted(strict: true)
  # When an error occurs during conversion it will return the original String.
  # To raise an error use:
  #   "somestring".phone_formatted(raise: true)
  def phony_formatted(options = {})
    raise ArgumentError, "Expected options to be a Hash, got #{options.inspect}" unless options.is_a?(Hash)
    options = options.dup
    normalize_country_code = options.delete(:normalize)
    s, ext = PhonyRails.extract_extension(self)
    s = (normalize_country_code ? PhonyRails.normalize_number(s, default_country_code: normalize_country_code.to_s, add_plus: false) : s.gsub(/\D/, ''))
    return if s.blank?
    return if options[:strict] && !Phony.plausible?(s)
    PhonyRails.format_extension(Phony.format(s, options.reverse_merge(format: :national)), ext)
  rescue StandardError
    raise if options[:raise]
    s
  end

  # The bang method
  def phony_formatted!(options = {})
    raise ArgumentError, 'The :strict options is only supported in the phony_formatted (non bang) method.' if options[:strict]
    replace(phony_formatted(options))
  end
end

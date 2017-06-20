# Change Log

## [v0.14.6](https://github.com/joost/phony_rails/tree/v0.14.6) (2017-06-20)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.14.5...v0.14.6)

**Closed issues:**

- Fail validation on raw input [\#161](https://github.com/joost/phony_rails/issues/161)
- Extension example in README does not work [\#155](https://github.com/joost/phony_rails/issues/155)
- Switching the dependancy from `ActiveRecord::Base` to `ActiveModel::Model` breaks support for Rails 3 apps [\#147](https://github.com/joost/phony_rails/issues/147)

**Merged pull requests:**

- Conditional Normalization [\#166](https://github.com/joost/phony_rails/pull/166) ([Ross-Hunter](https://github.com/Ross-Hunter))
- Fixed belongs\_to\_required\_by\_default in Rails 5 [\#158](https://github.com/joost/phony_rails/pull/158) ([olivierpichon](https://github.com/olivierpichon))
- `subbed` always return number [\#157](https://github.com/joost/phony_rails/pull/157) ([mrclmrvn](https://github.com/mrclmrvn))

## [v0.14.5](https://github.com/joost/phony_rails/tree/v0.14.5) (2017-02-08)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.14.4...v0.14.5)

**Closed issues:**

- phone number not being validated [\#154](https://github.com/joost/phony_rails/issues/154)
- Make phony\_normalize optional, on condition [\#149](https://github.com/joost/phony_rails/issues/149)

**Merged pull requests:**

- Fix Rails 3 compatibility in issue \#147 [\#156](https://github.com/joost/phony_rails/pull/156) ([wvanheerde](https://github.com/wvanheerde))
- Support of phone numbers with extension in validator [\#153](https://github.com/joost/phony_rails/pull/153) ([Kukunin](https://github.com/Kukunin))

## [v0.14.4](https://github.com/joost/phony_rails/tree/v0.14.4) (2016-10-10)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.14.2...v0.14.4)

**Closed issues:**

- Add support for internal Russian phone style \(8 926 ... instead of +7 926 ...\) [\#148](https://github.com/joost/phony_rails/issues/148)
- is it necessary to extend ActiveRecord::Base instead of ActiveModel::Model ? [\#143](https://github.com/joost/phony_rails/issues/143)

**Merged pull requests:**

- Bundle updates and fixes Travis [\#151](https://github.com/joost/phony_rails/pull/151) ([joost](https://github.com/joost))

## [v0.14.2](https://github.com/joost/phony_rails/tree/v0.14.2) (2016-06-16)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.14.1...v0.14.2)

**Merged pull requests:**

- Do not use insecure multiline regex in examples [\#146](https://github.com/joost/phony_rails/pull/146) ([bdewater](https://github.com/bdewater))
- support for ActiveModel::Model alternative to database-backed models only [\#144](https://github.com/joost/phony_rails/pull/144) ([brandondees](https://github.com/brandondees))

## [v0.14.1](https://github.com/joost/phony_rails/tree/v0.14.1) (2016-05-08)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.14.0...v0.14.1)

**Closed issues:**

- Pull request \#139 \(released in 0.14.0\) breaks message: :improbable\_phone option [\#140](https://github.com/joost/phony_rails/issues/140)

**Merged pull requests:**

- Fixed a bug that prevents a normalized attribute from being set to nil [\#142](https://github.com/joost/phony_rails/pull/142) ([kylerippey](https://github.com/kylerippey))
- Read message value directly from options [\#141](https://github.com/joost/phony_rails/pull/141) ([monfresh](https://github.com/monfresh))

## [v0.14.0](https://github.com/joost/phony_rails/tree/v0.14.0) (2016-04-21)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.13.0...v0.14.0)

**Closed issues:**

- In normalize\_number, .clone is being used, which preserves "frozenness", causing method to fail sometimes [\#136](https://github.com/joost/phony_rails/issues/136)
- question Is thr any way to find country code from mobile no? [\#135](https://github.com/joost/phony_rails/issues/135)
- invalid number assumed to be valid [\#130](https://github.com/joost/phony_rails/issues/130)
- Split fails when a + is present [\#123](https://github.com/joost/phony_rails/issues/123)

**Merged pull requests:**

- Adds ability to pass symbols as option values to phony model helpers [\#139](https://github.com/joost/phony_rails/pull/139) ([jonathan-wheeler](https://github.com/jonathan-wheeler))
- Add support for phone numbers with extensions [\#138](https://github.com/joost/phony_rails/pull/138) ([jerryclinesmith](https://github.com/jerryclinesmith))
- Add support for a default country code [\#137](https://github.com/joost/phony_rails/pull/137) ([jerryclinesmith](https://github.com/jerryclinesmith))
- Added first RuboCop stuff. [\#134](https://github.com/joost/phony_rails/pull/134) ([joost](https://github.com/joost))

## [v0.13.0](https://github.com/joost/phony_rails/tree/v0.13.0) (2016-03-12)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.12.11...v0.13.0)

**Closed issues:**

- Adding country code twice for Luxemburg numbers [\#128](https://github.com/joost/phony_rails/issues/128)
- Unexpected result when calling normalize\_number multiple times with country\_code option [\#126](https://github.com/joost/phony_rails/issues/126)
- No method find\_by\_normalized\_phone\_number [\#125](https://github.com/joost/phony_rails/issues/125)
- Invalid number is valid? [\#124](https://github.com/joost/phony_rails/issues/124)
- Can it validate mobile phone? [\#122](https://github.com/joost/phony_rails/issues/122)

**Merged pull requests:**

- Do not raise NoMethodError when an illegal country code is set [\#133](https://github.com/joost/phony_rails/pull/133) ([klaustopher](https://github.com/klaustopher))
- only assigned normalize values if there is one [\#132](https://github.com/joost/phony_rails/pull/132) ([Smcchoi](https://github.com/Smcchoi))
- Adding Kosovo phone code [\#131](https://github.com/joost/phony_rails/pull/131) ([Xanders](https://github.com/Xanders))
- Add Dutch translation for invalid number [\#129](https://github.com/joost/phony_rails/pull/129) ([bdewater](https://github.com/bdewater))

## [v0.12.11](https://github.com/joost/phony_rails/tree/v0.12.11) (2015-11-12)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.12.9...v0.12.11)

**Closed issues:**

- French formatting [\#121](https://github.com/joost/phony_rails/issues/121)
- French phony\_normalize [\#120](https://github.com/joost/phony_rails/issues/120)
- Correct phone number failed the validatiton [\#115](https://github.com/joost/phony_rails/issues/115)
- 'no implicit conversion of nil into String' from phony\_formatted!\(spaces: '-', strict: true\) with invalid numbers [\#113](https://github.com/joost/phony_rails/issues/113)
- Can i skip a validation with another number? [\#110](https://github.com/joost/phony_rails/issues/110)
- Consider dropping the dependency on the countries gem and using a YAML file instead [\#108](https://github.com/joost/phony_rails/issues/108)
- Some Finnish mobile numbers are formatted wrong [\#107](https://github.com/joost/phony_rails/issues/107)
- undefined method `\[\]' for Data:Class [\#106](https://github.com/joost/phony_rails/issues/106)
- Phony is out of date [\#102](https://github.com/joost/phony_rails/issues/102)

**Merged pull requests:**

- Update readme [\#117](https://github.com/joost/phony_rails/pull/117) ([toydestroyer](https://github.com/toydestroyer))
- Add uk, ru error message translations [\#114](https://github.com/joost/phony_rails/pull/114) ([shhavel](https://github.com/shhavel))
- Update phony\_rails.gemspec [\#112](https://github.com/joost/phony_rails/pull/112) ([Agsiegert](https://github.com/Agsiegert))
- Don't re-parse country codes YAML file every time it's needed. [\#111](https://github.com/joost/phony_rails/pull/111) ([jcoleman](https://github.com/jcoleman))
- Replace countries dependency with YAML file [\#109](https://github.com/joost/phony_rails/pull/109) ([monfresh](https://github.com/monfresh))

## [v0.12.9](https://github.com/joost/phony_rails/tree/v0.12.9) (2015-07-13)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.12.8...v0.12.9)

**Closed issues:**

- Countries 0.11.5 introduces a breaking change [\#103](https://github.com/joost/phony_rails/issues/103)

**Merged pull requests:**

- Get country data in a more straight forward way [\#105](https://github.com/joost/phony_rails/pull/105) ([humancopy](https://github.com/humancopy))
- Replace Data with Setup.data [\#104](https://github.com/joost/phony_rails/pull/104) ([monfresh](https://github.com/monfresh))

## [v0.12.8](https://github.com/joost/phony_rails/tree/v0.12.8) (2015-06-22)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.12.7...v0.12.8)

**Closed issues:**

- activerecord dependency [\#99](https://github.com/joost/phony_rails/issues/99)
- Using a number different from the country [\#97](https://github.com/joost/phony_rails/issues/97)
- UK 0203 numbers not handled correctly [\#95](https://github.com/joost/phony_rails/issues/95)
- Consider keeping a Changelog for changes in each version. [\#91](https://github.com/joost/phony_rails/issues/91)
- Phone numbers with extensions [\#78](https://github.com/joost/phony_rails/issues/78)

**Merged pull requests:**

- remove active\_record dependency [\#100](https://github.com/joost/phony_rails/pull/100) ([sbounmy](https://github.com/sbounmy))
- Add enforce\_record\_country option to phony\_normalize method [\#98](https://github.com/joost/phony_rails/pull/98) ([phillipp](https://github.com/phillipp))

## [v0.12.7](https://github.com/joost/phony_rails/tree/v0.12.7) (2015-06-18)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.12.6...v0.12.7)

**Closed issues:**

- inconsistent normalization [\#93](https://github.com/joost/phony_rails/issues/93)

**Merged pull requests:**

- Adding default error translation for the Hebrew language [\#96](https://github.com/joost/phony_rails/pull/96) ([pazaricha](https://github.com/pazaricha))

## [v0.12.6](https://github.com/joost/phony_rails/tree/v0.12.6) (2015-05-11)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.12.5...v0.12.6)

**Closed issues:**

- Nil return values for normalize cause validations to pass [\#92](https://github.com/joost/phony_rails/issues/92)

**Merged pull requests:**

- pass all options from String\#phony\_normalized to PhonyRails.normalize\_number [\#94](https://github.com/joost/phony_rails/pull/94) ([krukgit](https://github.com/krukgit))

## [v0.12.5](https://github.com/joost/phony_rails/tree/v0.12.5) (2015-04-30)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.12.4...v0.12.5)

**Closed issues:**

- phony\_normalize strips parentheses from NDC part [\#89](https://github.com/joost/phony_rails/issues/89)
- Does not normalize when validations are skipped [\#88](https://github.com/joost/phony_rails/issues/88)

## [v0.12.4](https://github.com/joost/phony_rails/tree/v0.12.4) (2015-04-05)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.12.2...v0.12.4)

## [v0.12.2](https://github.com/joost/phony_rails/tree/v0.12.2) (2015-04-05)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.12.1...v0.12.2)

**Closed issues:**

- Some numbers not normalizing properly as of 0.12.1 [\#87](https://github.com/joost/phony_rails/issues/87)
- Something wrong with normalization of NO phones [\#85](https://github.com/joost/phony_rails/issues/85)

## [v0.12.1](https://github.com/joost/phony_rails/tree/v0.12.1) (2015-04-01)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.12.0...v0.12.1)

**Closed issues:**

- Validate a phone number format, but don't require the presence [\#84](https://github.com/joost/phony_rails/issues/84)
- Simple question about creating a record [\#83](https://github.com/joost/phony_rails/issues/83)

## [v0.12.0](https://github.com/joost/phony_rails/tree/v0.12.0) (2015-03-26)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.11.0...v0.12.0)

**Closed issues:**

- Allow validating against multiple countries [\#81](https://github.com/joost/phony_rails/issues/81)

**Merged pull requests:**

- allow all valid options [\#82](https://github.com/joost/phony_rails/pull/82) ([zzma](https://github.com/zzma))

## [v0.11.0](https://github.com/joost/phony_rails/tree/v0.11.0) (2015-03-04)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.10.1...v0.11.0)

**Closed issues:**

- Method phony\_formatted return "undefined method `split' for 1:Fixnum" [\#79](https://github.com/joost/phony_rails/issues/79)

**Merged pull requests:**

- Fix incorrect Japanese translation [\#80](https://github.com/joost/phony_rails/pull/80) ([ykzts](https://github.com/ykzts))

## [v0.10.1](https://github.com/joost/phony_rails/tree/v0.10.1) (2015-01-21)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.10.0...v0.10.1)

**Closed issues:**

- PhonyRails.normalize\_number is removing unexpected zero  [\#77](https://github.com/joost/phony_rails/issues/77)
- support for arrays in postgres [\#59](https://github.com/joost/phony_rails/issues/59)
- Phone extension support [\#57](https://github.com/joost/phony_rails/issues/57)

## [v0.10.0](https://github.com/joost/phony_rails/tree/v0.10.0) (2015-01-21)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.9.0...v0.10.0)

**Closed issues:**

- Already normalized numbers have default country code prepended [\#76](https://github.com/joost/phony_rails/issues/76)

## [v0.9.0](https://github.com/joost/phony_rails/tree/v0.9.0) (2015-01-13)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.8.2...v0.9.0)

**Merged pull requests:**

- change kh to km [\#75](https://github.com/joost/phony_rails/pull/75) ([Samda](https://github.com/Samda))
- update phony [\#74](https://github.com/joost/phony_rails/pull/74) ([Samda](https://github.com/Samda))
- add Khmer language translation [\#73](https://github.com/joost/phony_rails/pull/73) ([Samda](https://github.com/Samda))
- Add PhonyRails.plausible\_number? [\#72](https://github.com/joost/phony_rails/pull/72) ([marcantonio](https://github.com/marcantonio))

## [v0.8.2](https://github.com/joost/phony_rails/tree/v0.8.2) (2014-12-18)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.8.0...v0.8.2)

**Closed issues:**

- uninitialized constant Listen::Turnstile [\#69](https://github.com/joost/phony_rails/issues/69)
- Issue with brazilian numbers [\#68](https://github.com/joost/phony_rails/issues/68)
- Phony is now at 2.8.x [\#67](https://github.com/joost/phony_rails/issues/67)
- Update to latest phony version? [\#65](https://github.com/joost/phony_rails/issues/65)

**Merged pull requests:**

- Remove depreciation warnings while running tests. [\#71](https://github.com/joost/phony_rails/pull/71) ([jmera](https://github.com/jmera))
- Update guard to handle change in listen dependency [\#70](https://github.com/joost/phony_rails/pull/70) ([JonMidhir](https://github.com/JonMidhir))

## [v0.8.0](https://github.com/joost/phony_rails/tree/v0.8.0) (2014-11-07)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.7.3...v0.8.0)

**Closed issues:**

- Update README [\#66](https://github.com/joost/phony_rails/issues/66)

## [v0.7.3](https://github.com/joost/phony_rails/tree/v0.7.3) (2014-10-23)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.7.2...v0.7.3)

**Merged pull requests:**

- Ability to validate against the normalized input [\#64](https://github.com/joost/phony_rails/pull/64) ([dimroc](https://github.com/dimroc))

## [v0.7.2](https://github.com/joost/phony_rails/tree/v0.7.2) (2014-10-15)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.7.1...v0.7.2)

**Merged pull requests:**

- Add italian translations [\#63](https://github.com/joost/phony_rails/pull/63) ([philipgiuliani](https://github.com/philipgiuliani))

## [v0.7.1](https://github.com/joost/phony_rails/tree/v0.7.1) (2014-10-01)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.7.0...v0.7.1)

## [v0.7.0](https://github.com/joost/phony_rails/tree/v0.7.0) (2014-09-30)
[Full Changelog](https://github.com/joost/phony_rails/compare/v0.6.0...v0.7.0)

**Closed issues:**

- TAG on release [\#62](https://github.com/joost/phony_rails/issues/62)
- Unable to run migrations if "as" attribute added [\#60](https://github.com/joost/phony_rails/issues/60)
- Rails not recognizing phony\_rails method [\#58](https://github.com/joost/phony_rails/issues/58)
- Validation fails if record country code does not match code in phone number [\#55](https://github.com/joost/phony_rails/issues/55)
- Phony 2.2.3 breaks test [\#51](https://github.com/joost/phony_rails/issues/51)
- Country code not set when first two digits eq country code [\#50](https://github.com/joost/phony_rails/issues/50)
- Phony 2.1 incompatibility related to country codes/numbers [\#48](https://github.com/joost/phony_rails/issues/48)
- Clarify Indended Functionality and Require a Default Country Code [\#43](https://github.com/joost/phony_rails/issues/43)
- Use Phony 2.0 [\#28](https://github.com/joost/phony_rails/issues/28)

**Merged pull requests:**

- Raise runtime errors not argument errors when :as attr undefined [\#61](https://github.com/joost/phony_rails/pull/61) ([chelsea](https://github.com/chelsea))
- Fixes \#55 - Validation fails if record country code does not match code ... [\#56](https://github.com/joost/phony_rails/pull/56) ([juanpaco](https://github.com/juanpaco))
- Add turkish locale file. [\#54](https://github.com/joost/phony_rails/pull/54) ([onurozgurozkan](https://github.com/onurozgurozkan))
- Translate german [\#53](https://github.com/joost/phony_rails/pull/53) ([toxix](https://github.com/toxix))
- Fix country code being incorrectly passed to phony [\#49](https://github.com/joost/phony_rails/pull/49) ([pjg](https://github.com/pjg))

## [v0.6.0](https://github.com/joost/phony_rails/tree/v0.6.0) (2014-01-28)
**Closed issues:**

- French normalized number isn't good [\#42](https://github.com/joost/phony_rails/issues/42)
- Invalid numbers should not be formatted [\#41](https://github.com/joost/phony_rails/issues/41)
- Error when formatting invalid numbers [\#40](https://github.com/joost/phony_rails/issues/40)
- License missing from gemspec [\#38](https://github.com/joost/phony_rails/issues/38)
- Expose Country objects, and allow national-to-international conversion [\#34](https://github.com/joost/phony_rails/issues/34)
- default\_country\_code forces country code [\#33](https://github.com/joost/phony_rails/issues/33)
- "translation missing" when using validator on non-activerecord backed models [\#30](https://github.com/joost/phony_rails/issues/30)
- Error when normalizing long telephone numbers with default country code [\#29](https://github.com/joost/phony_rails/issues/29)
- Fix default\_country\_number appending repeatedly [\#25](https://github.com/joost/phony_rails/issues/25)
- Detect if phone number has country code specified and use that [\#22](https://github.com/joost/phony_rails/issues/22)
- problem with v 0.2.1 [\#21](https://github.com/joost/phony_rails/issues/21)
- Error with phony\_normalize on migration [\#19](https://github.com/joost/phony_rails/issues/19)
- Mongoid Error Message [\#18](https://github.com/joost/phony_rails/issues/18)
- Make dependency on newer version of phony [\#11](https://github.com/joost/phony_rails/issues/11)
- add a wiki [\#7](https://github.com/joost/phony_rails/issues/7)
- validator not included [\#4](https://github.com/joost/phony_rails/issues/4)
- Country Number out of Country gem [\#3](https://github.com/joost/phony_rails/issues/3)

**Merged pull requests:**

- Add support for phony version ~\> 2.1 [\#45](https://github.com/joost/phony_rails/pull/45) ([pjg](https://github.com/pjg))
- In the validator: add country code & number handling  [\#44](https://github.com/joost/phony_rails/pull/44) ([robink](https://github.com/robink))
- PhonyRails.country\_number\_for should accept case agnostic country code [\#39](https://github.com/joost/phony_rails/pull/39) ([ahegyi](https://github.com/ahegyi))
- option for country code validation in helper [\#37](https://github.com/joost/phony_rails/pull/37) ([fareastside](https://github.com/fareastside))
- Fix phone number formatting method call in README [\#36](https://github.com/joost/phony_rails/pull/36) ([pjg](https://github.com/pjg))
- Better attribute accessor pattern + Japanese translation [\#35](https://github.com/joost/phony_rails/pull/35) ([johnnyshields](https://github.com/johnnyshields))
- Cleanup for better Mongoid support [\#32](https://github.com/joost/phony_rails/pull/32) ([johnnyshields](https://github.com/johnnyshields))
- add activemodel validation translation [\#31](https://github.com/joost/phony_rails/pull/31) ([ghiculescu](https://github.com/ghiculescu))
- use default\_country\_code when normalizing [\#27](https://github.com/joost/phony_rails/pull/27) ([espen](https://github.com/espen))
- update Gemfile.lock with lastest version [\#26](https://github.com/joost/phony_rails/pull/26) ([espen](https://github.com/espen))
- Raise only an exception at validation for non-existing attributes \(\#19\) [\#20](https://github.com/joost/phony_rails/pull/20) ([k4nar](https://github.com/k4nar))
- Do not normalize an implausible phone [\#16](https://github.com/joost/phony_rails/pull/16) ([Jell](https://github.com/Jell))
- Override the default loading of the "countries" gem so that the Country class isn't unqualified. [\#15](https://github.com/joost/phony_rails/pull/15) ([jcoleman](https://github.com/jcoleman))
- Mongoid support. [\#14](https://github.com/joost/phony_rails/pull/14) ([siong1987](https://github.com/siong1987))
- Do not pollute the global namespace with a Country class [\#13](https://github.com/joost/phony_rails/pull/13) ([Jell](https://github.com/Jell))
- Address issue \#11 - need to use a newer version of phony for additional countries [\#12](https://github.com/joost/phony_rails/pull/12) ([rjhaveri](https://github.com/rjhaveri))
- Compatibility with Ruby 1.8.7 [\#10](https://github.com/joost/phony_rails/pull/10) ([triskweline](https://github.com/triskweline))
- remove cause for warning: already initialized constant VERSION [\#9](https://github.com/joost/phony_rails/pull/9) ([triskweline](https://github.com/triskweline))
- validator translation [\#8](https://github.com/joost/phony_rails/pull/8) ([ddidier](https://github.com/ddidier))
- refactored tests and added options to validates\_plausible\_phone [\#6](https://github.com/joost/phony_rails/pull/6) ([ddidier](https://github.com/ddidier))
- some tests and a helper method [\#5](https://github.com/joost/phony_rails/pull/5) ([ddidier](https://github.com/ddidier))
- Bumped Phony dependency to the latest [\#2](https://github.com/joost/phony_rails/pull/2) ([Rodeoclash](https://github.com/Rodeoclash))
- Changed the remaining references to phony\_number to phony\_rails. [\#1](https://github.com/joost/phony_rails/pull/1) ([floere](https://github.com/floere))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
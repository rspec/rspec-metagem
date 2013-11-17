require 'spec_helper'

module RSpec::Expectations
  describe EncodedString do
    let(:target_encoding) { 'UTF-8' }

    if String.method_defined?(:encoding)

      describe '#source_encoding' do
        it 'knows the original encoding of the string' do
          str = EncodedString.new("abc".encode('ASCII-8BIT'), "UTF-8")
          expect( str.source_encoding.to_s ).to eq('ASCII-8BIT')
        end
      end

      describe '#<<' do
        context 'with strings that can be converted to the target encoding' do
          it 'encodes and appends the string' do
            valid_ascii_string = "abc".force_encoding("ASCII-8BIT")
            valid_unicode_string = "\xE2\x82\xAC".force_encoding('UTF-8')

            resulting_string = build_encoded_string(valid_unicode_string, target_encoding) << valid_ascii_string
            expect(resulting_string).to eq "\xE2\x82\xACabc".force_encoding('UTF-8')
          end
        end

        context 'with a string that cannot be converted to the target encoding' do
          it 'replaces undefined characters with either a ? or a unicode ?' do
            ascii_string = "\xAE".force_encoding("ASCII-8BIT")
            valid_unicode_string = "\xE2\x82\xAC".force_encoding('UTF-8')

            resulting_string = build_encoded_string(valid_unicode_string, target_encoding) << ascii_string
            expected_bytes = [226, 130, 172, "?".unpack("c").first]
            actual_bytes = resulting_string.each_byte.to_a

            expect(actual_bytes).to eq(expected_bytes)
          end
        end

        context 'with two ascii strings with a target encoding of UTF-8 ' do
          it 'has an encoding of UTF-8' do
            ascii_string = 'abc'.force_encoding("ASCII-8BIT")
            other_ascii_string = '123'.force_encoding("ASCII-8BIT")

            resulting_string = build_encoded_string(ascii_string, target_encoding) << other_ascii_string
            expect(resulting_string.encoding.to_s).to eq 'UTF-8'
          end
        end
      end

      describe '#split' do
        it 'splits the string based on the delimiter accounting for encoding' do
          wrapped_string = "aaaaaaaaaaa\xAEaaaaa".force_encoding("ASCII-8BIT")

          expect {
            build_encoded_string(wrapped_string, target_encoding).split("\xE2\x82\xAC".force_encoding("UTF-8"))
          }.not_to raise_error
        end
      end

      def build_encoded_string(string, target_encoding)
        EncodedString.new(string, target_encoding)
      end
    else

      describe '#source_encoding' do
        it 'defaults to US-ASCII' do
          str = EncodedString.new("abc", "UTF-8")
          expect( str.source_encoding ).to eq('US-ASCII')
        end
      end
    end
  end
end

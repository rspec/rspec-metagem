require 'spec_helper'

module RSpec::Expectations
  describe EncodedString do
    let(:target_encoding) { 'UTF-8' }

    it 'is a true delegator' do
      wrapped_object = double(:wrapped_object, :encode => double(:i_do_not_exist => :return_val))
      expect(EncodedString.new(wrapped_object).i_do_not_exist).to be :return_val
    end

    describe '#<<' do
      context 'with strings that can be converted to the target encoding' do
        it 'encodes and appends the string' do
          valid_ascii_string = "abc"
          valid_unicode_string = "\xE2\x82\xAC".force_encoding('UTF-8')

          resulting_string = build_encoded_string(valid_unicode_string, target_encoding) << valid_ascii_string
          expect(resulting_string).to eq "\xE2\x82\xACabc".force_encoding('UTF-8')
        end
      end

      context 'with a string that cannot be converted to the target encoding' do
        it 'replaces undefined characters' do
          ascii_string = "\xAE".unpack("A").first
          valid_unicode_string = "\xE2\x82\xAC".force_encoding('UTF-8')

          resulting_string = build_encoded_string(valid_unicode_string, target_encoding) << ascii_string
          expected_bytes = [226, 130, 172, 239, 191, 189]
          expect(resulting_string.each_byte.to_a).to eq expected_bytes
        end
      end

      context 'with two ascii strings with a target encoding of UTF-8 ' do
        it 'has an encoding of UTF-8' do
          ascii_string = 'abc'
          other_ascii_string = '123'

          resulting_string = build_encoded_string(ascii_string, target_encoding) << other_ascii_string
          expect(resulting_string.encoding.to_s).to eq 'UTF-8'
        end
      end
    end

    describe '#split' do
      it 'splits the string based on the delimiter accounting for encoding' do
        wrapped_string = "aaaaaaaaaaa\xAEaaaaa"

        expect {
          build_encoded_string(wrapped_string, target_encoding).split("\xE2\x82\xAC")
        }.not_to raise_error
      end
    end

    def build_encoded_string(string, target_encoding)
      EncodedString.new(string, target_encoding)
    end
  end
end

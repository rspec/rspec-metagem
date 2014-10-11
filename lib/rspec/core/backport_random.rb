module RSpec
  module Core
    # @private
    #
    # Methods used internally by the backports.
    #
    # This code was (mostly) ported from the backports gem found at
    # https://github.com/marcandre/backports which is subject to this license:
    #
    # =========================================================================
    #
    # Copyright (c) 2009 Marc-Andre Lafortune
    #
    # Permission is hereby granted, free of charge, to any person obtaining
    # a copy of this software and associated documentation files (the
    # "Software"), to deal in the Software without restriction, including
    # without limitation the rights to use, copy, modify, merge, publish,
    # distribute, sublicense, and/or sell copies of the Software, and to
    # permit persons to whom the Software is furnished to do so, subject to
    # the following conditions:
    #
    # The above copyright notice and this permission notice shall be
    # included in all copies or substantial portions of the Software.
    #
    # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    # EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    # LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    # OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    # WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    #
    # =========================================================================
    #
    # The goal is to provide a random number generator in Ruby versions that do
    # not have one. This was added to support localization of random spec
    # ordering.
    #
    # These were in multiple files in backports, but merged into one here.
    module Backports
      # Helper method to coerce a value into a specific class.
      # Raises a TypeError if the coercion fails or the returned value
      # is not of the right class.
      # (from Rubinius)
      def self.coerce_to(obj, cls, meth)
        return obj if obj.kind_of?(cls)

        begin
          ret = obj.__send__(meth)
        rescue Exception => e
          raise TypeError, "Coercion error: #{obj.inspect}.#{meth} => #{cls} failed:\n" \
                           "(#{e.message})"
        end
        raise TypeError, "Coercion error: obj.#{meth} did NOT return a #{cls} (was #{ret.class})" unless ret.kind_of? cls
        ret
      end

      # @private
      def self.coerce_to_int(obj)
        coerce_to(obj, Integer, :to_int)
      end

      # Used internally to make it easy to deal with optional arguments.
      # (from Rubinius)
      Undefined = Object.new

      # @private
      class Random
        # @private
        # An implementation of Mersenne Twister MT19937 in Ruby.
        class MT19937
          STATE_SIZE = 624
          LAST_STATE = STATE_SIZE - 1
          PAD_32_BITS = 0xffffffff

          # See seed=
          def initialize(seed)
            self.seed = seed
          end

          LAST_31_BITS = 0x7fffffff
          OFFSET = 397

          # Generates a completely new state out of the previous one.
          def next_state
            STATE_SIZE.times do |i|
              mix = @state[i] & 0x80000000 | @state[i+1 - STATE_SIZE] & 0x7fffffff
              @state[i] = @state[i+OFFSET - STATE_SIZE] ^ (mix >> 1)
              @state[i] ^= 0x9908b0df if mix.odd?
            end
            @last_read = -1
          end

          # Seed must be either an Integer (only the first 32 bits will be used)
          # or an Array of Integers (of which only the first 32 bits will be
          # used).
          #
          # No conversion or type checking is done at this level.
          def seed=(seed)
            case seed
            when Integer
              @state = Array.new(STATE_SIZE)
              @state[0] = seed & PAD_32_BITS
              (1..LAST_STATE).each do |i|
                @state[i] = (1812433253 * (@state[i-1]  ^ @state[i-1]>>30) + i)& PAD_32_BITS
              end
              @last_read = LAST_STATE
            when Array
              self.seed = 19650218
              i=1
              j=0
              [STATE_SIZE, seed.size].max.times do
                @state[i] = (@state[i] ^ (@state[i-1] ^ @state[i-1]>>30) * 1664525) + j + seed[j] & PAD_32_BITS
                if (i+=1) >= STATE_SIZE
                  @state[0] = @state[-1]
                  i = 1
                end
                j = 0 if (j+=1) >= seed.size
              end
              (STATE_SIZE-1).times do
                @state[i] = (@state[i] ^ (@state[i-1] ^ @state[i-1]>>30) * 1566083941) - i & PAD_32_BITS
                if (i+=1) >= STATE_SIZE
                  @state[0] = @state[-1]
                  i = 1
                end
              end
              @state[0] = 0x80000000
            else
              raise ArgumentError, "Seed must be an Integer or an Array"
            end
          end

          # Returns a random Integer from the range 0 ... (1 << 32).
          def random_32_bits
            next_state if @last_read >= LAST_STATE
            @last_read += 1
            y = @state[@last_read]
            # Tempering
            y ^= (y >> 11)
            y ^= (y << 7) & 0x9d2c5680
            y ^= (y << 15) & 0xefc60000
            y ^= (y >> 18)
          end

          # Supplement the MT19937 class with methods to do
          # conversions the same way as MRI.
          # No argument checking is done here either.

          FLOAT_FACTOR = 1.0/9007199254740992.0
          # Generates a random number on [0, 1) with 53-bit resolution.
          def random_float
            ((random_32_bits >> 5) * 67108864.0 + (random_32_bits >> 6)) * FLOAT_FACTOR;
          end

          # Returns an integer within 0...upto.
          def random_integer(upto)
            n = upto - 1
            nb_full_32 = 0
            while n > PAD_32_BITS
              n >>= 32
              nb_full_32 += 1
            end
            mask = mask_32_bits(n)
            begin
              rand = random_32_bits & mask
              nb_full_32.times do
                rand <<= 32
                rand |= random_32_bits
              end
            end until rand < upto
            rand
          end

          def random_bytes(nb)
            nb_32_bits = (nb + 3) / 4
            random = nb_32_bits.times.map { random_32_bits }
            random.pack("L" * nb_32_bits)[0, nb]
          end

          def state_as_bignum
            b = 0
            @state.each_with_index do |val, i|
              b |= val << (32 * i)
            end
            b
          end

          def left # It's actually the number of words left + 1, as per MRI...
            MT19937::STATE_SIZE - @last_read
          end

          def marshal_dump
            [state_as_bignum, left]
          end

          def marshal_load(ary)
            b, left = ary
            @last_read = MT19937::STATE_SIZE - left
            @state = Array.new(STATE_SIZE)
            STATE_SIZE.times do |i|
              @state[i] = b & PAD_32_BITS
              b >>= 32
            end
          end

          # Convert an Integer seed of arbitrary size to either a single 32 bit
          # integer, or an Array of 32 bit integers.
          def self.convert_seed(seed)
            seed = seed.abs
            long_values = []
            begin
              long_values << (seed & PAD_32_BITS)
              seed >>= 32
            end until seed == 0

            # Done to allow any kind of sequence of integers.
            long_values.pop if long_values[-1] == 1 && long_values.size > 1

            long_values.size > 1 ? long_values : long_values.first
          end

          def self.[](seed)
            new(convert_seed(seed))
          end

          private

          MASK_BY = [1,2,4,8,16]
          def mask_32_bits(n)
            MASK_BY.each do |shift|
              n |= n >> shift
            end
            n
          end
        end

        # @private
        # Implementation corresponding to the actual Random class of Ruby
        # The actual random generator (mersenne twister) is in MT19937.
        # Ruby specific conversions are handled in bits_and_bytes.
        # The high level stuff (argument checking) is done here.
        module Implementation
          attr_reader :seed

          def initialize(seed = 0)
            super()
            seed_rand seed
          end

          def seed_rand(new_seed = 0)
            new_seed = Backports.coerce_to_int(new_seed)
            @seed = nil unless defined?(@seed)
            old, @seed = @seed, new_seed.nonzero? || Random.new_seed
            @mt = MT19937[ @seed ]
            old
          end

          def rand(limit = Backports::Undefined)
            case limit
              when Backports::Undefined
                @mt.random_float
              when Float
                limit * @mt.random_float unless limit <= 0
              when Range
                _rand_range(limit)
              else
                limit = Backports.coerce_to_int(limit)
                @mt.random_integer(limit) unless limit <= 0
            end || raise(ArgumentError, "invalid argument #{limit}")
          end

          def bytes(nb)
            nb = Backports.coerce_to_int(nb)
            raise ArgumentError, "negative size" if nb < 0
            @mt.random_bytes(nb)
          end

          def ==(other)
            other.is_a?(Random) &&
              seed == other.seed &&
              left == other.send(:left) &&
              state == other.send(:state)
          end

          def marshal_dump
            @mt.marshal_dump << @seed
          end

          def marshal_load(ary)
            @seed = ary.pop
            @mt = MT19937.allocate
            @mt.marshal_load(ary)
          end

          private

          def state
            @mt.state_as_bignum
          end

          def left
            @mt.left
          end

          def _rand_range(limit)
            range = limit.end - limit.begin
            if (!range.is_a?(Float)) && range.respond_to?(:to_int) && range = Backports.coerce_to_int(range)
              range += 1 unless limit.exclude_end?
              limit.begin + @mt.random_integer(range) unless range <= 0
            elsif range = Backports.coerce_to(range, Float, :to_f)
              if range < 0
                nil
              elsif limit.exclude_end?
                limit.begin + @mt.random_float * range unless range <= 0
              else
                # cheat a bit... this will reduce the nb of random bits
                loop do
                  r = @mt.random_float * range * 1.0001
                  break limit.begin + r unless r > range
                end
              end
            end
          end
        end

        def self.new_seed
          (2 ** 62) + Kernel.rand(2 ** 62)
        end
      end

      class Random
        include Implementation
        class << self
          include Implementation
        end
      end
    end
  end
end

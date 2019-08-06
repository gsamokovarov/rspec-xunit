# frozen_string_literal: true

module RSpec
  module XUnit
    # Assertions contains the XUnit friendly assertions to be used in RSpec
    # examples.
    module Assertions
      class << self
        # Assertion match converts RSpec matchers into an XUnit friendly
        # assertions.
        #
        # For example: `assertion_match :eq` will create an `assert_eq` method
        # behaving in the same way as:
        #
        # `expect(action).to eq(expected)`
        def assertion_match(matcher, suffix = guess_assertion_suffix(matcher))
          define_method "assert_#{suffix}" do |value, *args, &block|
            begin
              expect(value).to send(matcher, *args, &block)
            rescue Expectations::ExpectationNotMetError => e
              raise e, e.message, adjust_for_better_failure_message(e.backtrace), cause: nil
            end
          end
        end

        # Assertion match block converts RSpec block matchers into XUnit
        # friendly assertions.
        #
        # For example: `assertion_match_block :raises, :raise_error` will
        # create an `assert_raises` method behaving in the same way as:
        #
        # `expect { bloc }.to raise_error`
        def assertion_match_block(matcher, suffix = guess_assertion_suffix(matcher))
          define_method "assert_#{suffix}" do |*args, &block|
            begin
              expect(&block).to send(matcher, *args)
            rescue Expectations::ExpectationNotMetError => e
              raise e, e.message, adjust_for_better_failure_message(e.backtrace), cause: nil
            end
          end
        end

        private

        MATCHER_CRUFT_REGEX = /((?:be_)|(?:have_))(.*)/.freeze

        def guess_assertion_suffix(matcher_name)
          MATCHER_CRUFT_REGEX.match(matcher_name) do |match|
            match[2]
          end || matcher_name
        end
      end

      assertion_match :be_truthy
      assertion_match :be_falsy
      assertion_match :be_nil
      assertion_match :be
      assertion_match :be_a, :is_a
      assertion_match :be_kind_of
      assertion_match :be_instance_of
      assertion_match :be_between
      assertion_match :be_within
      assertion_match :contain_exactly
      assertion_match :cover
      assertion_match :end_with
      assertion_match :eq
      assertion_match :eql
      assertion_match :exist
      assertion_match :have_attributes
      assertion_match :include
      assertion_match :all
      assertion_match :match
      assertion_match :match_array
      assertion_match :respond_to
      assertion_match :satisfy
      assertion_match :start_with
      assertion_match :throw_symbol, :throw
      assertion_match :yield_control
      assertion_match :yield_with_no_args
      assertion_match :yield_successive_args

      assertion_match_block :change
      assertion_match_block :raise_error, :raise
      assertion_match_block :raise_error, :raises
      assertion_match_block :output

      def assert(value = Expectations::ExpectationTarget::UndefinedValue, &block)
        Expectations::ExpectationTarget.for(value, block)
      end

      private

      ASSERTION_PREDICATE_REGEX = /^assert_(.*)\?$/.freeze

      def method_missing(method, *args, &block)
        ASSERTION_PREDICATE_REGEX.match(method.to_s) do |match|
          expect(args.shift).to BuiltIn::BePredicate.new(match[1], *args, &block)
        end || super
      end

      def respond_to_missing?(method, *)
        method =~ ASSERTION_PREDICATE_REGEX || super
      end

      # TODO(genadi): Figure out where exactly the code shown in the failure
      # message is extracted.
      def adjust_for_better_failure_message(backtrace)
        backtrace.drop_while { |trace| !trace.include?(__FILE__) }[1..-1]
      end
    end
  end
end

RSpec::Matchers.include RSpec::XUnit::Assertions

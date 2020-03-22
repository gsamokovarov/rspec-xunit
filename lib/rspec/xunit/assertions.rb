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
        # For example, `assertion_match :eq` will create two methods:
        #
        # - `assert_eq` roughly `expect(action).to eq(expected)`
        # - `assert_not_eq` roughly `expect(action).to_not eq(expected)`
        def assertion_match(matcher, suffix = matcher)
          define_method "assert_#{suffix}" do |value, *args, &block|
            expect(value).to send(matcher, *args, &block)
          rescue Expectations::ExpectationNotMetError => e
            raise e, e.message, adjust_for_better_failure_message(e.backtrace), cause: nil
          end

          define_method "assert_not_#{suffix}" do |value, *args, &block|
            expect(value).to_not send(matcher, *args, &block)
          rescue Expectations::ExpectationNotMetError => e
            raise e, e.message, adjust_for_better_failure_message(e.backtrace), cause: nil
          end
        end

        # Assertion match block converts RSpec block matchers into XUnit
        # friendly assertions.
        #
        # For example, `assertion_match_block :raises, :raise_error` will
        # generate two methods:
        #
        # - `assert_raises` roughly `expect { bloc }.to raise_error`
        # - `assert_not_raises` roughly `expect { bloc }.to_not raise_error`
        def assertion_match_block(matcher, suffix = matcher)
          define_method "assert_#{suffix}" do |*args, &block|
            expect(&block).to send(matcher, *args)
          rescue Expectations::ExpectationNotMetError => e
            raise e, e.message, adjust_for_better_failure_message(e.backtrace), cause: nil
          end

          define_method "assert_not_#{suffix}" do |*args, &block|
            expect(&block).to_not send(matcher, *args)
          rescue Expectations::ExpectationNotMetError => e
            raise e, e.message, adjust_for_better_failure_message(e.backtrace), cause: nil
          end
        end
      end

      # Useful aliaises.
      assertion_match :be_truthy, :truthy
      assertion_match :be_falsy, :falsy
      assertion_match :be_nil, :nil
      assertion_match :be_a, :is_a
      assertion_match :be_kind_of, :kind_of
      assertion_match :be_instance_of, :instance_of
      assertion_match :be_between, :between
      assertion_match :be_within, :within

      assertion_match_block :raise_error, :raise
      assertion_match_block :raise_error, :raises

      # Exceptions to the block matcher rule.
      assertion_match :satisfy

      # Assert is an alias to `expect`. Use it when all else fails or doesn't
      # feel right. The `change` assertion with a block is a good example:
      #
      # `assert! { block }.to change { value }` or
      # `assert { block }.to change { value }`
      def assert!(value = Expectations::ExpectationTarget::UndefinedValue, &block)
        Expectations::ExpectationTarget.for(value, block)
      end

      alias assert assert!

      # Mock is an XUnit alternative to the `expect` based mocking syntax.
      #
      # `mock(Post).to receive(:comments)`
      def mock(value = Expectations::ExpectationTarget::UndefinedValue, &block)
        Expectations::ExpectationTarget.for(value, block)
      end

      # Mock any instance of is an XUnit alternative to the
      # `expect_any_instance_of` based mocking syntax.
      #
      # `mock_any_instance_of(Post).to receive(:comments)`
      def mock_any_instance_of(klass)
        RSpec::Mocks::AnyInstanceExpectationTarget.new(klass)
      end

      # Stub is an XUnit alternative to the `allow` based mocking syntax.
      def stub(target)
        RSpec::Mocks::AllowanceTarget.new(target)
      end

      # Stub any instance of is an XUnit alternative to the `allow` based
      # mocking syntax.
      def stub_any_instance_of(klass)
        RSpec::Mocks::AnyInstanceAllowanceTarget.new(klass)
      end

      private

      ASSERTION_REGEX = /^assert_(.*)$/.freeze
      ASSERTION_NEGATIVE_REGEX = /^assert_not_(.*)$/.freeze
      ASSERTION_PREDICATE_REGEX = /^assert_(.*)\?$/.freeze
      ASSERTION_NEGATIVE_PREDICATE_REGEX = /^assert_not_(.*)\?$/.freeze

      def method_missing(method, *args, &block)
        return if ASSERTION_NEGATIVE_PREDICATE_REGEX.match(method.to_s) do |match|
          value = args.shift
          matcher = "be_#{match[1]}"

          expect(value).to_not Matchers::BuiltIn::BePredicate.new(matcher, *args, &block)
        end

        return if ASSERTION_PREDICATE_REGEX.match(method.to_s) do |match|
          value = args.shift
          matcher = "be_#{match[1]}"

          expect(value).to Matchers::BuiltIn::BePredicate.new(matcher, *args, &block)
        end

        return if ASSERTION_NEGATIVE_REGEX.match(method.to_s) do |match|
          matcher = match[1]

          RSpec::XUnit::Assertions.module_eval do
            if block.nil?
              assertion_match matcher
            else
              assertion_match_block matcher
            end
          end

          send "assert_not_#{match[1]}", *args, &block
        end

        return if ASSERTION_REGEX.match(method.to_s) do |match|
          matcher = match[1]

          RSpec::XUnit::Assertions.module_eval do
            if block.nil?
              assertion_match matcher
            else
              assertion_match_block matcher
            end
          end

          send "assert_#{match[1]}", *args, &block
        end

        super
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

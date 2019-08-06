# frozen_string_literal: true

require 'test_helper'

RSpec.case RSpec::XUnit::Assertions do
  test 'assert_truthy' do
    assert_truthy true
  end

  test 'assert_falsy' do
    assert_falsy false
  end

  test 'assert_nil' do
    assert_nil nil
  end

  test 'assert_eq' do
    assert_eq true, true
  end

  test 'assert_be' do
    assert_be false, false
  end

  test 'assert_between' do
    assert_between 1, 0, 3
  end

  test 'assert_satisfy' do
    assert_satisfy 5 do |n|
      n > 4
    end
  end

  test 'assert_raises' do
    assert_raises RuntimeError do
      raise 'XUnit 4 life!'
    end
  end

  test 'assert_change' do
    array = []

    assert_change array, :count do
      array << 1
    end
  end

  test 'assert fall-back' do
    array = []

    assert { array << 1 }.to change { array.count }
  end
end

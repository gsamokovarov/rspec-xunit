The RSpec you know and love with xUnit syntax.

## BDD

```ruby
require "rails_helper"

RSpec.describe Next::LoginForm do
  it "validates a user can be found by email" do
    login = Next::LoginForm.submit email: "oh@no.com", password: ":(",

    expect(login).to be_invalid
    expect(login.errors.details[:base]).to eq([error: :not_found])
  end

  it "validates a user can be authenticated" do
    user = create :user

    expect {
      login = Next::LoginForm.submit email: user.email, password: user.password

      expect(login).to be_valid
    }.to change { Session.count }.by(1)
  end
end
```

🤢

## xUnit

```ruby
require "test_helper"

RSpec.case Next::LoginForm do
  test "user cannot be found" do
    login = Next::LoginForm.submit email: "oh@no.com", password: ":("

    assert_invalid? login
    assert_eq login.errors.details[:base], [error: :not_found]
  end

  test "user authentication" do
    user = create :user

    assert_change Session, :count do
      login = Next::LoginForm.submit email: user.email, password: user.password

      assert_valid? login
    end
  end
end
```

🥳

## Installation

Add `rspec-xunit` to both the `:development` and `:test` groups of your `Gemfile`:

```ruby
group :development, :test do
  gem 'rspec-xunit'
end
```

If you want your tests in the `test` directory (as you should, my friend) put
this in your `.rspec` file:

```
-Itest
--pattern='test/**/*_test.rb'
```

## Syntax

The syntax offered by `rspec-xunit` should be familiar to xUnit testing
framework users like `minitest`.

You start a test case by `RSpec.case`. This is a simple alias of
`Rspec.describe`. You define individual tests (what you call examples in your
past life) with the `test` macro. It is an alias of `it` and it supports all
it's goodies, like skipping a test with `xtest`.

This leaves us to at the most important change in `rspec-xunit`... You no
longer write **expectations** but **assertions**!

### Assertions

Let's take a look at single RSpec BDD example:

```ruby
it "validates a user can be found by email" do
  login = Next::LoginForm.submit email: "oh@no.com", password: ":(",

  expect(login).to be_invalid
  expect(login.errors.details[:base]).to eq([error: :not_found])
end
```

The line `expect(login).to be_invalid` as an **expectation**. The `be_invalid`
part of it is a **matcher**. For every RSpec matcher, we have a corresponding
**assertion**. This is how we can rewrite the example above as a test:

```ruby
test "user cannot be found" do
  login = Next::LoginForm.submit email: "oh@no.com", password: ":("

  assert_invalid? login
  assert_eq login.errors.details[:base], [error: :not_found]
end
```

The assertions provided by `rspec-xunit` follow the pattern `assert_:matcher`,
where `:matcher` is a name of standard RSpec matcher. This way, every matcher
you expect from RSpec is already available in `rspec-xunit`. 🎉

We even support block matchers like:

```ruby
test "missing required fields" do
  assert_raise_error ActiveModel::ValidationError do
    Next::LoginForm.submit!
  end
end
```

The test above is equivalent to the example below:

```ruby
it "requires email and password present" do
  expect {
    Next::LoginForm.submit!
  }.to raise_error(ActiveModel::ValidationError)
end
```

We have the aliases of `assert_raise` and `assert_raises` to
`assert_raise_error` for that extra bittersweet xUnit feel. 🤤

Some block-level assertions are hard to convert. Take this example,
for example 😉:

```ruby
it "validates a user can be authenticated" do
  user = create :user

  expect {
    login = Next::LoginForm.submit email: user.email, password: user.password

    expect(login).to be_valid
  }.to change { Session.count }.by(1)
end
```

We cannot translate `change { Session.count }.by(1)` to a nice assertion. This
is where the `assert!` fall-back comes in:

```ruby
test "user authentication" do
  user = create :user

  assert! {
    assert_valid? login
  }.to change { Session.count }.by(1)
end
```

This looks suspiciously like `expect` because it is its alias! 🙄 Sometimes
you just gotta `expect`, I mean `assert`, you know!

Have you noticed the `assert_valid? login` line? We call it an assertion
predicate! Every assertion ending in a question-mark invokes that predicate
method on the asserted object.

```ruby
assert_empty? object_responding_to_empty_question_mark
```

### Stubs & Mocks

To write stubs and mocks in xUnit fashion, use `stub` instead of `allow` and
`mock` instead of `expect`. Everything else is the same.

# Testing Guide for Bookmark Manager

This guide explains the testing approach, tools, and best practices used in the Bookmark Manager application. It's designed to help new developers understand how to write and maintain tests.

## Table of Contents

1. [Testing Setup](#testing-setup)
2. [Directory Structure](#directory-structure)
3. [Test Types](#test-types)
4. [Factory Bot](#factory-bot)
5. [Testing Best Practices](#testing-best-practices)
6. [Common Testing Patterns](#common-testing-patterns)
7. [Troubleshooting](#troubleshooting)

## Testing Setup

The application uses RSpec as the testing framework along with several supporting gems:

- **RSpec**: Main testing framework
- **FactoryBot**: Test data generation
- **Shoulda Matchers**: Simplified test assertions for common Rails functionality
- **SimpleCov**: Test coverage reporting
- **WebMock**: HTTP request stubbing

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/bookmark_spec.rb

# Run specific test (line number)
bundle exec rspec spec/models/bookmark_spec.rb:25

# Run with format documentation for more verbose output
bundle exec rspec --format documentation
```

## Directory Structure

```
spec/
├── factories/         # Test data factories
├── models/            # Model tests
├── requests/          # Controller/API tests
├── support/           # Test configuration and helpers
├── rails_helper.rb    # Rails-specific test configuration
└── spec_helper.rb     # General RSpec configuration
```

## Test Types

### Model Tests

Model tests verify that your models work as expected, including:
- Validations
- Associations
- Scopes
- Instance methods
- Class methods

Example:
```ruby
RSpec.describe Bookmark do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:tags).through(:bookmark_tags) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:title) }
  end
  
  # Test custom validations with specific examples
  describe 'url format validation' do
    let(:user) { create(:user) }
    
    it 'is valid with http:// protocol' do
      bookmark = build(:bookmark, url: 'http://example.com', user: user)
      expect(bookmark).to be_valid
    end
    
    it 'is invalid without proper protocol' do
      bookmark = build(:bookmark, url: 'example.com', user: user)
      expect(bookmark).not_to be_valid
    end
  end
end
```

### Request Tests

Request tests verify that your controllers and API endpoints work correctly:
- HTTP status codes
- Response format and content
- Authentication/authorization
- Error handling

Example:
```ruby
RSpec.describe 'Bookmarks' do
  let(:user) { create(:user) }
  
  before do
    sign_in user
  end
  
  describe '#index' do
    before do
      create_list(:bookmark, 3, user: user)
    end
    
    it 'returns a successful response' do
      get bookmarks_path
      expect(response).to have_http_status(:ok)
    end
  end
end
```

## Factory Bot

FactoryBot is used to create test data. Factories are defined in the `spec/factories` directory.

### Basic Factory Usage

```ruby
# Create an instance and save it to the database
user = create(:user)

# Build an instance without saving
bookmark = build(:bookmark)

# Create with custom attributes
bookmark = create(:bookmark, title: 'Custom Title', url: 'https://example.com')

# Create multiple instances
create_list(:bookmark, 3, user: user)
```

### Factory Associations

Factories can define associations with other factories:

```ruby
factory :bookmark do
  title { "Example Bookmark" }
  url { "https://example.com" }
  user  # This will use the user factory
end
```

## Testing Best Practices

### 1. Use `before` Blocks Appropriately

- Use `before` blocks for setup code that's shared across multiple tests
- Avoid `let!` for setup that doesn't directly reference test objects (use `before` instead)
- And `bookmarks.reload` when used in specific tests where you need the latest data

```ruby
# Good
before do
  create_list(:bookmark, 3, user: user)
end

# Avoid when not directly referenced
let(:bookmarks) { create_list(:bookmark, 3, user: user) }
```

### 2. Use Descriptive Context and Example Names

```ruby
# Good
describe '#create' do
  context 'with valid parameters' do
    it 'creates a new bookmark' do
      # test code
    end
  end
  
  context 'with invalid parameters' do
    it 'returns error messages' do
      # test code
    end
  end
end
```

### 3. Test Edge Cases and Error Conditions

Always test both happy paths and error conditions:

```ruby
it 'handles errors from LinkPreviewService gracefully' do
  allow(LinkPreviewService).to receive(:fetch_thumbnail).and_raise(StandardError)
  
  put bookmark_path(bookmark), params: valid_attributes
  expect(response).to have_http_status(:ok)
end
```

### 4. Mock External Services

Use WebMock or stubs to avoid making real external API calls:

```ruby
stub_request(:get, <url>).with(headers: <request-headers>).to_return(status: 200, body: <mock-response>)

```

### 5. Test Authentication and Authorization

```ruby
context 'when user is not authenticated' do
  before { sign_out user }
  
  it 'redirects to the login page' do
    get bookmarks_path
    expect(response).to redirect_to(new_user_session_path)
  end
end

context 'when bookmark does not belong to user' do
  it 'returns 404 not found' do
    other_user_bookmark = create(:bookmark, user: create(:user))
    delete bookmark_path(other_user_bookmark)
    expect(response).to have_http_status(:not_found)
  end
end
```

## Common Testing Patterns

### Testing Validations

```ruby
# Using shoulda-matchers
it { is_expected.to validate_presence_of(:title) }
it { is_expected.to validate_uniqueness_of(:url).scoped_to(:user_id).case_insensitive }

# For custom validations
it 'validates URL format' do
  bookmark = build(:bookmark, url: 'invalid-url')
  expect(bookmark).not_to be_valid
  expect(bookmark.errors[:url]).to include('is invalid')
end
```

### Testing Associations

```ruby
it { is_expected.to belong_to(:user) }
it { is_expected.to have_many(:bookmark_tags).dependent(:destroy) }
it { is_expected.to have_many(:tags).through(:bookmark_tags) }
```

### Testing Scopes

```ruby
describe '.for_user' do
  it 'returns bookmarks for the specified user only' do
    user_bookmark = create(:bookmark, user: user)
    other_bookmark = create(:bookmark, user: create(:user))
    
    bookmarks = described_class.for_user(user)
    expect(bookmarks).to include(user_bookmark)
    expect(bookmarks).not_to include(other_bookmark)
  end
end
```

### Testing API Responses

```ruby
it 'returns a JSON response with the new bookmark' do
  post bookmarks_path, params: valid_attributes, as: :json
  expect(response).to have_http_status(:created)
  
  json_response = response.parsed_body
  expect(json_response['title']).to eq(valid_attributes[:bookmark][:title])
end
```

## Troubleshooting

### Common Issues

1. **Test Database Issues**
   - Run `rails db:test:prepare` to ensure your test database is up to date

2. **Authentication in Tests**
   - Use `sign_in user` for Devise authentication in request specs
   - Ensure the Devise test helpers are included in your test setup

3. **Factory Bot Errors**
   - Check for circular dependencies in your factories
   - Ensure required attributes are provided

4. **WebMock Errors**
   - If you see "Real HTTP connections are disabled", you need to stub the request
   - Use `allow(LinkPreviewService).to receive(:fetch_thumbnail)` for service methods

### Handling API Keys in Tests

For services that require API keys (like LinkPreviewService):

```ruby
# In your service
def self.fetch_thumbnail(url)
  return {} if ENV['LINK_PREVIEW_API_KEY'].blank?
  # API call logic
end

# In your test
before do
  allow(ENV).to receive(:[]).with('LINK_PREVIEW_API_KEY').and_return('fake-key')
  # Or stub the service method directly
  allow(LinkPreviewService).to receive(:fetch_thumbnail).and_return(thumbnail_data)
end
```

---

For more detailed information on RSpec, refer to the [RSpec documentation](https://rspec.info/documentation/).

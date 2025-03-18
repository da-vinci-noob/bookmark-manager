# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:bookmark_tags).dependent(:destroy) }
    it { is_expected.to have_many(:bookmarks).through(:bookmark_tags) }
  end

  describe 'validations' do
    subject { build(:tag, user: user) }

    let(:user) { create(:user) }

    it { is_expected.to validate_presence_of(:name) }

    context 'with uniqueness' do
      before { create(:tag, name: 'Ruby', user: user) }

      it 'is invalid with duplicate name for the same user' do
        tag = build(:tag, name: 'Ruby', user: user)
        expect(tag).not_to be_valid
        expect(tag.errors[:name]).to include('has already been taken')
      end

      it 'is valid with same name for different user' do
        other_user = create(:user)
        tag = build(:tag, name: 'Ruby', user: other_user)
        expect(tag).to be_valid
      end
    end

    context 'with color format' do
      it 'is valid with a 3-digit hex color' do
        tag = build(:tag, color: '#abc', user: user)
        expect(tag).to be_valid
      end

      it 'is valid with a 6-digit hex color' do
        tag = build(:tag, color: '#abcdef', user: user)
        expect(tag).to be_valid
      end

      it 'is valid with blank color' do
        tag = build(:tag, color: '', user: user)
        expect(tag).to be_valid
      end

      it 'is invalid with non-hex color format' do
        tag = build(:tag, color: 'red', user: user)
        expect(tag).not_to be_valid
        expect(tag.errors[:color]).to include('is invalid')
      end

      it 'is invalid with hex color missing # prefix' do
        tag = build(:tag, color: 'abcdef', user: user)
        expect(tag).not_to be_valid
        expect(tag.errors[:color]).to include('is invalid')
      end

      it 'is invalid with hex color of wrong length' do
        tag = build(:tag, color: '#abcd', user: user)
        expect(tag).not_to be_valid
        expect(tag.errors[:color]).to include('is invalid')
      end
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:user_tag) { create(:tag, user: user) }
    let!(:other_tag) { create(:tag, user: other_user) }

    describe '.for_user' do
      it 'returns tags for the specified user only' do
        tags = described_class.for_user(user)
        expect(tags).to include(user_tag)
        expect(tags).not_to include(other_tag)
      end
    end

    describe '.with_bookmarks' do
      it 'includes bookmarks and bookmark_tags associations' do
        expect(described_class.with_bookmarks.includes_values).to include(:bookmarks, :bookmark_tags)
      end
    end
  end
end

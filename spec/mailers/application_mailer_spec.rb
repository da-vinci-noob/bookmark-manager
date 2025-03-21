# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationMailer do
  it 'is a mailer' do
    expect(described_class.itself).to eq described_class
  end
end

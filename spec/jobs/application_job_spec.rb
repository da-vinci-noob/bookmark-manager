# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationJob do
  it 'is a job' do
    expect(described_class.itself).to eq described_class
  end
end

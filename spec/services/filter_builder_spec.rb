# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FilterBuilder, type: :service do
  describe '.determine_active_filter_keys' do
    it 'marks datetime_range filters active when gteq/lteq params are present' do
      filters = FilterBuilder.build_filters_for_model(User, [
        { attribute: :created_at, type: :datetime_range }
      ])

      params = {
        'created_at_gteq' => '2025-09-01T00:04',
        'created_at_lteq' => '2025-09-24T23:01'
      }

      active = FilterBuilder.determine_active_filter_keys(filters, params)
      expect(active).to include(:created_at)
    end

    it 'does not mark filters without params as active' do
      filters = FilterBuilder.build_filters_for_model(User, [
        { attribute: :created_at, type: :datetime_range }
      ])

      params = {}
      active = FilterBuilder.determine_active_filter_keys(filters, params)
      expect(active).to_not include(:created_at)
    end
  end
end

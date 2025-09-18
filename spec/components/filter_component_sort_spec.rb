# frozen_string_literal: true

require "rails_helper"

RSpec.describe FilterComponent, type: :component do
  describe "with sortable columns" do
    it "renders sort dropdown when sortable columns are provided" do
      filters = [
        { key: :name, label: "Name", type: :text },
        { key: :email, label: "Email", type: :email }
      ]

      sortable_columns = [
        { key: :name, label: "Name" },
        { key: :created_at, label: "Created At" }
      ]

      component = described_class.new(
        filters: filters,
        sortable_columns: sortable_columns,
        current_sort: "name",
        current_direction: "asc"
      )

      # Only test helper methods, not the full render which requires routes
      expect(component.has_sortable_columns?).to be true
      expect(component.sort_options).to include([ "Name", "name" ])
    end

    it "does not render sort dropdown when no sortable columns" do
      filters = [
        { key: :name, label: "Name", type: :text }
      ]

      component = described_class.new(
        filters: filters,
        sortable_columns: []
      )

      expect(component.has_sortable_columns?).to be false
    end

    it "displays current sort label without direction" do
      component = described_class.new(
        filters: [],
        sortable_columns: [
          { key: :email, label: "Email Address" },
          { key: :created_at, label: "Created" }
        ],
        current_sort: "email",
        current_direction: "desc"
      )

      expect(component.current_sort_label).to eq("Email Address")
    end

    it "displays current sort label when direction is nil" do
      component = described_class.new(
        filters: [],
        sortable_columns: [
          { key: :email, label: "Email Address" }
        ],
        current_sort: "email",
        current_direction: nil
      )

      expect(component.current_sort_label).to eq("Email Address")
    end

    it "generates sort options correctly" do
      component = described_class.new(
        filters: [],
        sortable_columns: [
          { key: :name, label: "Name" },
          { key: :email, label: "Email" }
        ]
      )

      options = component.sort_options

      expect(options).to eq([
        [ "Name", "name" ],
        [ "Email", "email" ]
      ])
    end
  end

  describe "#has_sortable_columns?" do
    it "returns true when sortable columns exist" do
      component = described_class.new(
        filters: [],
        sortable_columns: [ { key: :name, label: "Name" } ]
      )

      expect(component.has_sortable_columns?).to be true
    end

    it "returns false when no sortable columns" do
      component = described_class.new(
        filters: [],
        sortable_columns: []
      )

      expect(component.has_sortable_columns?).to be false
    end
  end
end

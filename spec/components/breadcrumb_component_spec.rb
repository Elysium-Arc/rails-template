# frozen_string_literal: true

require "rails_helper"

RSpec.describe BreadcrumbComponent, type: :component do
  describe "rendering" do
    it "renders a simple breadcrumb" do
      component = described_class.new(
        items: [
          { label: "Home", url: "/" },
          { label: "Users", url: "/users" },
          { label: "Profile", active: true }
        ]
      )

      render_inline(component)

      expect(page).to have_css("nav.breadcrumbs")
      expect(page).to have_text("Home")
      expect(page).to have_text("Users")
      expect(page).to have_text("Profile")
    end

    it "renders breadcrumb with icons" do
      component = described_class.new(
        items: [
          { label: "Home", url: "/", icon: "house" },
          { label: "Settings", url: "/settings", icon: "settings" },
          { label: "Profile", active: true, icon: "user" }
        ]
      )

      render_inline(component)

      expect(page).to have_css("nav.breadcrumbs")
      expect(page).to have_text("Home")
      expect(page).to have_text("Settings")
      expect(page).to have_text("Profile")
    end

    it "renders links for non-active items" do
      component = described_class.new(
        items: [
          { label: "Home", url: "/" },
          { label: "Current", active: true }
        ]
      )

      render_inline(component)

      expect(page).to have_link("Home", href: "/")
      expect(page).to have_text("Current")
      expect(page).not_to have_link("Current")
    end

    it "uses custom separator" do
      component = described_class.new(
        items: [
          { label: "Home", url: "/" },
          { label: "Users", active: true }
        ],
        separator: "slash"
      )

      render_inline(component)

      expect(page).to have_css("nav.breadcrumbs")
    end

    it "handles items without URLs" do
      component = described_class.new(
        items: [
          { label: "Dashboard" },
          { label: "Settings", active: true }
        ]
      )

      render_inline(component)

      expect(page).to have_text("Dashboard")
      expect(page).to have_text("Settings")
      expect(page).not_to have_link("Dashboard")
      expect(page).not_to have_link("Settings")
    end
  end

  describe "BreadcrumbItem" do
    let(:item_class) { described_class::BreadcrumbItem }

    it "initializes with label and url" do
      item = item_class.new(label: "Test", url: "/test")

      expect(item.label).to eq("Test")
      expect(item.url).to eq("/test")
      expect(item.active?).to be false
      expect(item.has_url?).to be true
    end

    it "handles active state" do
      item = item_class.new(label: "Active", active: true)

      expect(item.active?).to be true
    end

    it "handles icon" do
      item = item_class.new(label: "Test", icon: "house")

      expect(item.has_icon?).to be true
      expect(item.icon).to eq("house")
    end

    it "accepts alternative keys (title, path)" do
      item = item_class.new(title: "Alt Title", path: "/alt-path")

      expect(item.label).to eq("Alt Title")
      expect(item.url).to eq("/alt-path")
    end
  end
end

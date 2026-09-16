# frozen_string_literal: true

require_relative "page_objects/components/side_composer"

RSpec.describe "Composer peek" do
  FULL_WIDTH_COMPONENT_PATH = ENV.fetch(
    "SIDE_COMPOSER_FULL_WIDTH_COMPONENT_PATH",
    File.expand_path("../fixtures/full-width-component", __dir__),
  )

  fab!(:current_user) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:staff_user) { Fabricate(:admin, refresh_auto_groups: true) }
  fab!(:topic, :topic_with_op)

  let(:composer) { PageObjects::Components::Composer.new }
  let(:side_composer) { PageObjects::Components::SideComposer.new }
  let(:sidebar) { PageObjects::Components::NavigationMenu::Sidebar.new }
  let(:topic_page) { PageObjects::Pages::Topic.new }

  def upload_full_width_fixture
    full_width = RemoteTheme.import_theme_from_directory(FULL_WIDTH_COMPONENT_PATH)
    Theme.find(SiteSetting.default_theme_id).child_themes << full_width
    full_width
  end

  def open_composer
    topic_page.visit_topic(topic)
    topic_page.click_footer_reply
    expect(composer).to be_opened
  end

  def set_sidebar_visibility(visible)
    return if side_composer.sidebar_page? == visible

    side_composer.click_sidebar_toggle
    if visible
      expect(sidebar).to be_visible
    else
      expect(sidebar).to be_not_visible
    end

    expect(side_composer.sidebar_page?).to eq(visible)
  end

  context "when Full Width is installed" do
    let!(:full_width) { upload_full_width_fixture }
    let!(:side_composer_theme) { upload_theme_component }

    before { sign_in(current_user) }

    it "lets the user switch to side mode and keep the choice after navigation and refresh" do
      open_composer

      resize_window(width: 1380) do
        expect(side_composer).to have_peek_toggle
        expect(side_composer).to be_full_width_enabled
        expect(side_composer).to have_no_dependency_warning
        expect(side_composer.peek_toggle_title).to eq(I18n.t("js.composer.peek_mode_toggle"))

        side_composer.toggle_peek_mode
        expect(side_composer).to be_peek_mode_active

        page.refresh
        topic_page.visit_topic_and_open_composer(topic)
        expect(side_composer).to be_peek_mode_active

        side_composer.toggle_peek_mode
        expect(side_composer).to be_peek_mode_inactive

        page.refresh
        topic_page.visit_topic_and_open_composer(topic)
        expect(side_composer).to be_peek_mode_inactive
      end
    end

    it "lets the user coordinate side mode with the native preview" do
      open_composer

      resize_window(width: 1380) do
        expect(composer).to have_composer_preview

        side_composer.toggle_peek_mode
        expect(composer).to have_no_composer_preview
        expect(side_composer).to be_peek_mode_active

        side_composer.click_preview_toggle
        expect(composer).to have_composer_preview
        expect(side_composer).to be_peek_mode_inactive

        side_composer.click_preview_toggle
        expect(composer).to have_no_composer_preview
        expect(side_composer).to be_peek_mode_active
      end
    end

    it "keeps the composer in its normal bottom layout below the wide-screen breakpoint" do
      open_composer

      resize_window(width: 600) do
        expect(side_composer).to have_no_peek_toggle
        expect(composer).to be_opened
      end
    end

    it "hides side mode while fullscreen and restores it after fullscreen" do
      open_composer

      resize_window(width: 1380) do
        side_composer.toggle_peek_mode
        expect(side_composer).to be_peek_mode_active

        side_composer.click_fullscreen_toggle
        expect(side_composer).to be_fullscreen
        expect(side_composer).to have_no_peek_toggle

        side_composer.click_fullscreen_toggle
        expect(side_composer).not_to be_fullscreen
        expect(side_composer).to have_peek_toggle
        expect(side_composer).to be_peek_mode_active
      end
    end

    it "keeps the main content beside the composer as the sidebar changes" do
      open_composer

      resize_window(width: 1440) do
        set_sidebar_visibility(true)
        side_composer.toggle_peek_mode
        expect(side_composer).to be_sidebar_page

        sidebar_layout = side_composer.layout_metrics
        expect(sidebar_layout[:main_right]).to be <= sidebar_layout[:composer_left]
        expect(sidebar_layout[:horizontal_overflow]).to be(false)

        set_sidebar_visibility(false)
        expect(side_composer.sidebar_page?).to be(false)

        no_sidebar_layout = side_composer.layout_metrics
        expect(no_sidebar_layout[:main_right]).to be <= no_sidebar_layout[:composer_left]
        expect(no_sidebar_layout[:horizontal_overflow]).to be(false)
      end
    end

    it "lets the user resize a normal composer after hiding preview" do
      open_composer

      resize_window(width: 1380) do
        side_composer.click_preview_toggle
        expect(composer).to have_no_composer_preview
        expect(side_composer).to be_peek_mode_inactive

        initial_height = composer.height
        composer.drag_resize_by(50)

        expect(composer).to have_applied_height(initial_height + 50)
      end
    end
  end

  context "when Full Width is not installed" do
    let!(:side_composer_theme) { upload_theme_component }

    it "shows the dependency notice to staff without offering side mode" do
      sign_in(staff_user)
      open_composer

      resize_window(width: 1380) do
        expect(side_composer).to have_dependency_warning
        expect(side_composer).not_to be_full_width_enabled
        expect(side_composer).to have_no_peek_toggle
        expect(side_composer).to be_peek_mode_inactive
      end
    end

    it "does not show the dependency notice or side mode to regular users" do
      sign_in(current_user)
      open_composer

      resize_window(width: 1380) do
        expect(side_composer).to have_no_dependency_warning
        expect(side_composer).to have_no_peek_toggle
      end
    end
  end
end

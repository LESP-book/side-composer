# frozen_string_literal: true

module PageObjects
  module Components
    class SideComposer < PageObjects::Components::Base
      COMPOSER_SELECTOR = "#reply-control"
      DEPENDENCY_WARNING_SELECTOR = ".alert-peek-mode-dependency"
      PEEK_MODE_SELECTOR = "body.peek-mode-active"
      PEEK_TOGGLE_SELECTOR = ".peek-mode-toggle"

      def toggle_peek_mode
        find(PEEK_TOGGLE_SELECTOR).click
        self
      end

      def click_preview_toggle
        find("#{COMPOSER_SELECTOR} .toggle-preview").click
        self
      end

      def click_fullscreen_toggle
        find("#{COMPOSER_SELECTOR} .toggle-fullscreen").click
        self
      end

      def click_sidebar_toggle
        find(".header-sidebar-toggle .btn").click(force: true)
        self
      end

      def peek_toggle_title
        find(PEEK_TOGGLE_SELECTOR)["title"]
      end

      def has_peek_toggle?
        page.has_css?(PEEK_TOGGLE_SELECTOR)
      end

      def has_no_peek_toggle?
        page.has_no_css?(PEEK_TOGGLE_SELECTOR)
      end

      def peek_mode_active?
        page.has_css?(PEEK_MODE_SELECTOR, visible: :all)
      end

      def peek_mode_inactive?
        page.has_no_css?(PEEK_MODE_SELECTOR, visible: :all)
      end

      def has_dependency_warning?
        page.has_css?(DEPENDENCY_WARNING_SELECTOR)
      end

      def has_no_dependency_warning?
        page.has_no_css?(DEPENDENCY_WARNING_SELECTOR)
      end

      def fullscreen?
        page.evaluate_script(
          "document.documentElement.classList.contains('fullscreen-composer')"
        )
      end

      def full_width_enabled?
        page.evaluate_script("document.body.classList.contains('full-width-enabled')")
      end

      def sidebar_page?
        page.evaluate_script(
          "document.body.classList.contains('has-sidebar-page')"
        )
      end

      def layout_metrics
        page.evaluate_script(<<~JS).transform_keys(&:to_sym)
          (() => {
            const main = document.querySelector("#main-outlet").getBoundingClientRect();
            const composer = document.querySelector("#reply-control").getBoundingClientRect();

            return {
              composer_left: composer.left,
              composer_right: composer.right,
              composer_width: composer.width,
              main_left: main.left,
              main_right: main.right,
              main_width: main.width,
              viewport_width: window.innerWidth,
              horizontal_overflow: document.documentElement.scrollWidth > window.innerWidth + 1,
            };
          })();
        JS
      end
    end
  end
end

# frozen_string_literal: true

module ApplicationHelper
  BIGBAG_STORE_TITLE = "BIGBAG Store".freeze

  def page_title(header_title: "")
    header_title.present? ? "#{header_title} - #{BIGBAG_STORE_TITLE}" : BIGBAG_STORE_TITLE
  end
end

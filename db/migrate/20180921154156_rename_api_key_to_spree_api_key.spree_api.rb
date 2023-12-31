# This migration comes from spree_api (originally 20120530054546)
# frozen_string_literal: true

class RenameApiKeyToSpreeApiKey < ActiveRecord::Migration[4.2]
  def change
    return if defined?(User)

    rename_column :spree_users, :api_key, :spree_api_key
  end
end

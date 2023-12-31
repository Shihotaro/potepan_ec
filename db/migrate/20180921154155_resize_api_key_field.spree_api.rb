# This migration comes from spree_api (originally 20120411123334)
# frozen_string_literal: true

class ResizeApiKeyField < ActiveRecord::Migration[4.2]
  def change
    return if defined?(User)

    change_column :spree_users, :api_key, :string, limit: 48
  end
end

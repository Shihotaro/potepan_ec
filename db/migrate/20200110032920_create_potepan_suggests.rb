# frozen_string_literal: true

class CreatePotepanSuggests < ActiveRecord::Migration[5.2]
  def change
    create_table :potepan_suggests do |t|
      t.string :keyword

      t.timestamps
    end
  end
end

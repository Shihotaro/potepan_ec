module Potepan
  class CategoriesController < ApplicationController
    def show
      @taxonomies = Spree::Taxonomy.all
      @taxon = Spree::Taxon.find(params[:taxon_id])
      @products = @taxon.all_products.includes(
        master: [:default_price, { images: [{ attachment_attachment: :blob }] }]
      )
    end
  end
end

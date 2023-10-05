module Potepan
  class ProductsController < ApplicationController
    MAX_RELATED_PRODUCTS_COUNT = 4

    def show
      @product = Spree::Product.includes(
        master: [:default_price, { images: [{ attachment_attachment: :blob }] }]
      ).find(params[:id])

      @related_products = @product.related_products.includes(
        master: [:default_price, { images: [{ attachment_attachment: :blob }] }]
      ).limit(MAX_RELATED_PRODUCTS_COUNT)
    end
  end
end

module ProductDecorator
  def related_products
    self.class.joins(:taxons).
      where(spree_taxons: { id: taxons }).
      where.not(id: id).
      distinct
  end
end

Spree::Product.prepend(ProductDecorator)

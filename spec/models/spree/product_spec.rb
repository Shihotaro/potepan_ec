require 'rails_helper'

RSpec.describe Spree::Product, type: :model do
  describe '#related_products' do
    let(:taxon) { create(:taxon) }
    let(:product) { create(:product, taxons: [taxon]) }
    let!(:related_product) { create(:product, name: "Double Product", taxons: [taxon]) }
    let!(:duplicated_product) { create(:product, name: "Double Product") }
    let!(:unrelated_product) { create(:product) }

    it '関連商品に自身の商品が含まれていないこと' do
      expect(product.related_products).not_to include(product)
    end

    it '自身と関連しない商品が含まれていないこと' do
      expect(product.related_products).not_to include(unrelated_product)
    end

    it "関連商品がdistinctになっていること" do
      expect(product.related_products).not_to include(duplicated_product)
    end
  end
end

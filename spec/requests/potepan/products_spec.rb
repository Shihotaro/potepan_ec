require 'rails_helper'

RSpec.describe "Potepan::Products", type: :request do
  describe "GET /potepan/products/:id" do
    let(:taxon) { create(:taxon, name: "Test T-Shirts") }
    let(:another_taxon) { create(:taxon, name: "Test Cap") }
    let(:product) do
      create(:product, name: "T-Shirt", price: "20.00", description: "text", taxons: [taxon])
    end
    let!(:not_related_product) { create(:product, taxons: [another_taxon]) }
    let!(:related_products) do
      create_list(:product, 5, taxons: [taxon]).each do |related_product|
        related_product.images << create(:image)
      end
    end

    before do
      get potepan_product_path(product.id)
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status(200)
    end

    it "商品名が含まれていること" do
      expect(response.body).to include("T-Shirt")
    end

    it "価格が含まれていること" do
      expect(response.body).to include("$20.00")
    end

    it "商品詳細が含まれていること" do
      expect(response.body).to include("text")
    end

    it "関連商品に異なるtaxonの商品が含まれていないこと" do
      expect(response.body).not_to include(not_related_product.name)
    end

    it "関連商品が4つ含まれていること" do
      expect(related_products.first(4).all? do |related_product|
               response.body.include?(related_product.name)
             end).to be true
    end

    it "5つ目の関連商品が含まれていないこと" do
      expect(response.body).not_to include(related_products[4].name)
    end
  end
end

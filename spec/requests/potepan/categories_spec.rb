require 'rails_helper'

RSpec.describe "Potepan::Categories", type: :request do
  describe "GET /potepan/Categories/:taxon_id" do
    let(:taxonomy) { create(:taxonomy, name: "Categories") }
    let(:taxon) { create(:taxon, name: "T-Shirts", taxonomy: taxonomy) }
    let(:product) { create(:product, taxons: [taxon]) }
    let!(:no_taxon_product) { create(:product) }
    let(:another_taxon) { create(:taxon, name: "T-Shirts", taxonomy: taxonomy) }
    let!(:another_taxon_product) { create(:product, taxons: [another_taxon]) }
    let(:image) { create(:image) }

    before do
      product.images << image
      get potepan_category_path(taxon.id)
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to have_http_status(200)
    end

    it "カテゴリー名が含まれていること" do
      expect(response.body).to include(taxonomy.name)
    end

    it "サブカテゴリー名が含まれていること" do
      expect(response.body).to include(taxon.name)
    end

    it "商品名が含まれていること" do
      expect(response.body).to include(product.name)
    end

    it "商品価格が含まれていること" do
      expect(response.body).to include(product.display_price.to_s)
    end

    it "カテゴリーに含まれない商品が含まれていないこと" do
      expect(response.body).not_to include(no_taxon_product.name)
    end

    it "別のカテゴリーの商品が含まれていないこと" do
      expect(response.body).not_to include(another_taxon_product.name)
    end
  end
end

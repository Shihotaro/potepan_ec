require 'rails_helper'

RSpec.describe "Products system spec", type: :system do
  let(:taxon) { create(:taxon, name: "Test T-Shirts") }
  let!(:product) { create(:product, taxons: [taxon]) }
  let!(:related_products) do
    create_list(:product, 5, taxons: [taxon]).each_with_index do |related_product, index|
      related_product.images << create(:image)
      related_product.master.update(price: (index + 1) * 100)
    end
  end

  before do
    product.images << create(:image)
    visit potepan_product_path(product.id)
  end

  it "一覧に戻るボタン押下後、商品に紐づくカテゴリーページが表示できること" do
    click_on "一覧ページへ戻る"

    expect(page).to have_content product.name
    expect(current_path).to eq(potepan_category_path(taxon.id))
  end

  it "関連商品を押下後、その商品の詳細ページが表示できること" do
    click_on related_products[0].name

    expect(page).to have_content related_products[0].name
    expect(current_path).to eq(potepan_product_path(related_products[0].id))
  end

  it "5つ目の関連商品が表示されないこと" do
    expect(page).not_to have_content related_products[4].name
  end

  it "関連商品の情報(商品名や値段など)が表示されていること" do
    expect(page).to have_content product.name
    expect(page).to have_content product.display_price

    related_products.first(4).each do |related_product|
      expect(page).to have_content related_product.name
      expect(page).to have_content related_product.display_price
    end
  end

  it "関連商品に自身が表示されていないこと" do
    within('.row.productsContent') do
      expect(page).not_to have_content product.name
    end
  end
end

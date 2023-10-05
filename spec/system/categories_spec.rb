require 'rails_helper'

RSpec.describe "Categories system spec", type: :system do
  let(:initial_taxon) { create(:taxon) }
  let(:taxonomy) { create(:taxonomy, name: "Test Categories") }
  let(:taxon) { create(:taxon, name: "Test T-Shirts", taxonomy: taxonomy) }
  let(:product) { create(:product, taxons: [taxon]) }
  let(:image) { create(:image) }

  before do
    product.images << image
  end

  it "カテゴリーを押下した時にカテゴリーに紐づく商品が表示されること" do
    visit potepan_category_path(taxon_id: initial_taxon.id)
    expect(page).not_to have_content product.name

    click_on taxonomy.name
    click_on taxon.name

    expect(page).to have_content product.name
    expect(current_path).to eq(potepan_category_path(taxon.id))
  end

  it "商品を押した時に商品詳細画面に遷移すること" do
    visit potepan_category_path(taxon_id: taxon.id)

    click_on product.name

    expect(page).to have_content product.name
    expect(current_path).to eq(potepan_product_path(product.id))
  end

  it "サイドバーに表示されている商品数と実際に表示されている商品数が一致していること" do
    visit potepan_category_path(taxon_id: initial_taxon.id)

    click_on taxonomy.name
    click_on taxon.name

    all_products = all(".productBox")

    expect(all_products.count).to eq(taxon.products.count)
  end
end

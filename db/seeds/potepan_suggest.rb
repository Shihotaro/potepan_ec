# frozen_string_literal: true

[
  'apache',
  'apache for women',
  'apache for men',
  'bag',
  'bag for women',
  'bag for men',
  'mug',
  'shirt',
  'shirt for women',
  'shirt for men',
  't-shirt',
  'ruby',
  'ruby for women',
  'ruby for men',
  'rails',
  'rails for women',
  'rails for men',
  'RUBY ON RAILS',
  'RUBY ON RAILS bag',
  'RUBY ON RAILS t-shirt',
  'TOTE'
].each do |keyword|
  Potepan::Suggest.create!(keyword: keyword)
end

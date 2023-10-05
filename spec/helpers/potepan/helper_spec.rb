require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "#page_title" do
    it "引数を指定した場合に、引数の文字列に '- BIGBAG Store'を足したものを返すこと" do
      header_title = "Dummy Title"
      expect(page_title(header_title: header_title)).to eq("#{header_title} - BIGBAG Store")
    end

    it "引数がnilの場合は、'BIGBAG Store'を返すこと" do
      header_title = nil
      expect(page_title(header_title: header_title)).to eq("BIGBAG Store")
    end

    it "引数が空文字の場合は、'BIGBAG Store'を返すこと" do
      expect(page_title(header_title: "")).to eq("BIGBAG Store")
    end
  end
end

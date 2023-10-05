require 'rails_helper'

RSpec.describe "Potepan::Samples", type: :request do
  describe "GET /potepan/index" do
    it "正常にレスポンスを返すこと" do
      get potepan_home_path
      expect(response).to have_http_status(200)
    end
  end
end

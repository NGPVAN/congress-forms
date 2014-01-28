require 'spec_helper'

describe "Main controller" do
  it "should receive 200 status from index" do
    get '/'
    expect(last_response.status).to eq(200)
  end

  describe "route /retrieve-from-elements" do
    before do
      @route = :'retrieve-form-elements'
    end

    it "should not raise an exception for nonexistent congress members when requesting form elements from /retrieve-form-elements" do
      expect do
        post_json @route, {"bio_ids" => ["B000243", "D000563"]}.to_json
      end.not_to raise_exception
      expect(JSON.load(last_response.body)).to eq({})
    end

    it "should retrieve form elements successfully from /retrieve-form-elements" do
      c = create :congress_member_with_actions
      post_json @route, {"bio_ids" => [c.bioguide_id]}.to_json
      expect(JSON.load(last_response.body)[c.bioguide_id]).not_to be_nil
    end

    it "should retrieve form elements successfully with multiple congress members from /retrieve-form-elements" do
      c = create :congress_member_with_actions
      c2 = create :congress_member_with_actions, bioguide_id: "A111111"
      post_json @route, {"bio_ids" => [c.bioguide_id, c2.bioguide_id]}.to_json

      last_response_json = JSON.load(last_response.body)
      expect(last_response_json[c.bioguide_id]).not_to be_nil
      expect(last_response_json[c2.bioguide_id]).not_to be_nil
    end
  end

  describe "route /fill-out-form" do
    before do
      @route = :'fill-out-form'
      @uid = "someuid"
    end

    it "should return json indicating an error when trying to fill out form for an undefined congress member" do
      post_json @route, {
        "bio_id" => "TEST",
        "fields" => MOCK_VALUES,
        "uid" => @uid
      }.to_json
      expect(JSON.load(last_response.body)["status"]).to eq("error")
      expect(JSON.load(last_response.body)["message"]).not_to be_nil # don't be brittle
    end

    it "should fill out a form when provided with the required values from /fill-out-form" do
      c = create :congress_member_with_actions
      post_json @route, {
        "bio_id" => c.bioguide_id,
        "fields" => MOCK_VALUES,
        "uid" => @uid
      }.to_json
      expect(last_response.status).to eq(200)
      expect(JSON.load(last_response.body)["status"]).to eq("success")
    end

    describe "with a captcha" do
      before do
        c = create :congress_member_with_actions_and_captcha
        post_json @route, {
          "bio_id" => c.bioguide_id,
          "fields" => MOCK_VALUES,
          "uid" => @uid
        }.to_json
      end

      it "should result in a status of 'captcha_needed'" do
        expect(last_response.status).to eq(200)
        expect(JSON.load(last_response.body)["status"]).to eq("captcha_needed")
      end

      it "should result in 'success' with the right answer given to /fill-out-captcha" do
        post_json :'fill-out-captcha', {
          "uid" => @uid,
          "answer" => "placeholder"
        }.to_json
        expect(last_response.status).to eq(200)
        expect(JSON.load(last_response.body)["status"]).to eq("success")
      end

      it "should result in 'error' with the wrong answer given to /fill-out-captcha" do
        post_json :'fill-out-captcha', {
          "uid" => @uid,
          "answer" => "wrong"
        }.to_json
        expect(last_response.status).to eq(200)
        expect(JSON.load(last_response.body)["status"]).to eq("error")
      end

      it "should destroy the fiber after giving an answer to /fill-out-captcha" do
        post_json :'fill-out-captcha', {
          "uid" => @uid,
          "answer" => "placeholder"
        }.to_json
        post_json :'fill-out-captcha', {
          "uid" => @uid,
          "answer" => "placeholder"
        }.to_json
        last_response_json = JSON.load(last_response.body)
        expect(last_response_json["status"]).to eq("error")
        expect(last_response_json["message"]).to eq("The unique id provided was not found.")
      end

    end
  end
end
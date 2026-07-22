# frozen_string_literal: true

require "spec_helper"

RSpec.describe RbSplash::WrapSplashApi do
  let(:bearer_token) { "test-bearer-token" }
  let(:api) { described_class.new }

  before do
    api.init(bearer_token: bearer_token)
  end

  describe "#init" do
    it "initializes with bearer token and sets authorization headers" do
      stub_request(:get, "https://api.unsplash.com/me")
        .to_return(status: 200, body: '{"username":"testuser"}')

      api.get_current_user_profile.value!

      expect(api.instance_variable_get(:@headers)["Authorization"]).to eq("Bearer #{bearer_token}")
      expect(api.instance_variable_get(:@headers)["X-WrapSplash-Header"]).to be_a(String)
    end

    it "throws a WrapSplashError for missing initialization values" do
      client = described_class.new
      expect { client.init(access_key: "abc", secret_key: "def") }.to raise_error(RbSplash::WrapSplashError, "Redirect URI missing!")
    end

    it "initializes with Client-ID auth for access_key credentials" do
      client = described_class.new
      client.init(
        access_key: "access-key",
        secret_key: "secret-key",
        redirect_uri: "https://example.com/callback",
        code: "auth-code"
      )

      expect(client.instance_variable_get(:@headers)["Authorization"]).to eq("Client-ID access-key")
    end
  end

  describe "#get_current_user_profile" do
    it "requests the me endpoint" do
      stub_request(:get, "https://api.unsplash.com/me")
        .to_return(status: 200, body: '{"username":"testuser"}')

      response = api.get_current_user_profile.value!
      expect(response).to eq({"username" => "testuser"})
    end
  end

  describe "#update_current_user_profile" do
    it "sends the correct PUT payload" do
      stub_request(:put, "https://api.unsplash.com/me")
        .with(query: hash_including("username" => "mock-user", "first_name" => "Mock"))
        .to_return(status: 200, body: '{"username":"mock-user"}')

      response = api.update_current_user_profile(
        username: "mock-user",
        first_name: "Mock",
        last_name: "User",
        email: "mock@example.com",
        url: "https://example.com",
        location: "Earth",
        bio: "Testing",
        instagram_username: "mock_insta"
      ).value!

      expect(response["username"]).to eq("mock-user")
    end
  end

  describe "#get_public_profile" do
    it "uses username and width/height query parameters" do
      stub_request(:get, "https://api.unsplash.com/users/sandeepv")
        .with(query: { "w" => "200", "h" => "300" })
        .to_return(status: 200, body: '{"username":"sandeepv"}')

      response = api.get_public_profile("sandeepv", width: 200, height: 300).value!
      expect(response["username"]).to eq("sandeepv")
    end

    it "throws when username is empty" do
      expect { api.get_public_profile("") }.to raise_error(
        RbSplash::WrapSplashError, "Parameter : username is required and cannot be empty!"
      )
    end
  end

  describe "#get_user_portfolio" do
    it "requests the correct portfolio endpoint" do
      stub_request(:get, "https://api.unsplash.com/users/sandeepv/portfolio")
        .to_return(status: 200, body: '{"url":"https://example.com"}')

      response = api.get_user_portfolio("sandeepv").value!
      expect(response["url"]).to eq("https://example.com")
    end
  end

  describe "#get_user_photos" do
    it "sends default pagination and stats parameters" do
      stub_request(:get, "https://api.unsplash.com/users/sandeepv/photos")
        .with(query: hash_including("page" => "1", "per_page" => "10"))
        .to_return(status: 200, body: '[]')

      response = api.get_user_photos("sandeepv").value!
      expect(response).to eq([])
    end

    it "throws for unsupported order_by values" do
      expect {
        api.get_user_photos("sandeepv", order_by: "invalid_order")
      }.to raise_error(RbSplash::WrapSplashError, "Parameter : order_by has an unsupported value!")
    end
  end

  describe "#get_user_liked_photos" do
    it "supports custom order_by values" do
      stub_request(:get, "https://api.unsplash.com/users/sandeepv/likes")
        .with(query: { "page" => "2", "per_page" => "5", "order_by" => "popular" })
        .to_return(status: 200, body: '[]')

      response = api.get_user_liked_photos("sandeepv", page: 2, per_page: 5, order_by: "popular").value!
      expect(response).to eq([])
    end

    it "throws for unsupported order_by values" do
      expect {
        api.get_user_liked_photos("sandeepv", order_by: "bad_order")
      }.to raise_error(RbSplash::WrapSplashError, "Parameter : order_by has an unsupported value!")
    end
  end

  describe "#get_user_collections" do
    it "uses default page and per_page values" do
      stub_request(:get, "https://api.unsplash.com/users/sandeepv/collections")
        .with(query: { "page" => "1", "per_page" => "10" })
        .to_return(status: 200, body: '[]')

      response = api.get_user_collections("sandeepv").value!
      expect(response).to eq([])
    end
  end

  describe "#get_user_statistics" do
    it "sends default resolution and quantity" do
      stub_request(:get, "https://api.unsplash.com/users/sandeepv/statistics")
        .with(query: { "resolution" => "days", "quantity" => "30" })
        .to_return(status: 200, body: '{"downloads":100}')

      response = api.get_user_statistics("sandeepv").value!
      expect(response["downloads"]).to eq(100)
    end
  end

  describe "#list_photos" do
    it "sends the correct request" do
      stub_request(:get, "https://api.unsplash.com/photos")
        .with(query: { "page" => "1", "per_page" => "10", "order_by" => "latest" })
        .to_return(status: 200, body: '[]')

      response = api.list_photos.value!
      expect(response).to eq([])
    end
  end

  describe "#list_curated_photos" do
    it "sends the correct request" do
      stub_request(:get, "https://api.unsplash.com/photos/curated")
        .with(query: { "page" => "1", "per_page" => "10", "order_by" => "latest" })
        .to_return(status: 200, body: '[]')

      response = api.list_curated_photos.value!
      expect(response).to eq([])
    end
  end

  describe "#get_a_photo / #get_photo" do
    it "builds width, height, and rect query parameters" do
      stub_request(:get, "https://api.unsplash.com/photos/g3PyXO4A0yc")
        .with(query: { "w" => "100", "h" => "200", "rect" => "0,0,100,200" })
        .to_return(status: 200, body: '{"id":"g3PyXO4A0yc"}')

      response = api.get_a_photo("g3PyXO4A0yc", width: 100, height: 200, rect: "0,0,100,200").value!
      expect(response["id"]).to eq("g3PyXO4A0yc")
    end

    it "get_photo alias works" do
      stub_request(:get, "https://api.unsplash.com/photos/g3PyXO4A0yc")
        .to_return(status: 200, body: '{"id":"g3PyXO4A0yc"}')

      response = api.get_photo("g3PyXO4A0yc").value!
      expect(response["id"]).to eq("g3PyXO4A0yc")
    end

    it "throws when id is missing" do
      expect { api.get_a_photo("") }.to raise_error(
        RbSplash::WrapSplashError, "Parameter : id is required!"
      )
    end
  end

  describe "#get_a_random_photo / #get_random_photo" do
    it "includes collection, featured, orientation, and count parameters" do
      stub_request(:get, "https://api.unsplash.com/photos/random")
        .with(query: hash_including("orientation" => "portrait", "count" => "2"))
        .to_return(status: 200, body: '{"id":"random1"}')

      response = api.get_a_random_photo(
        collections: "123", featured: true, username: "sandeepv",
        query: "nature", width: 400, height: 300,
        orientation: "portrait", count: 2
      ).value!
      expect(response["id"]).to eq("random1")
    end

    it "get_random_photo alias works" do
      stub_request(:get, "https://api.unsplash.com/photos/random")
        .with(query: hash_including("count" => "1", "featured" => "false", "orientation" => "landscape"))
        .to_return(status: 200, body: '{"id":"random2"}')

      response = api.get_random_photo.value!
      expect(response["id"]).to eq("random2")
    end

    it "throws for unsupported orientation values" do
      expect {
        api.get_a_random_photo(orientation: "invalid_orientation")
      }.to raise_error(RbSplash::WrapSplashError, "Parameter : orientation has an unsupported value!")
    end
  end

  describe "#get_photo_statistics" do
    it "sends the correct photo-specific request" do
      stub_request(:get, "https://api.unsplash.com/photos/g3PyXO4A0yc/statistics")
        .with(query: { "resolution" => "weeks", "quantity" => "10" })
        .to_return(status: 200, body: '{"downloads":50}')

      response = api.get_photo_statistics("g3PyXO4A0yc", resolution: "weeks", quantity: 10).value!
      expect(response["downloads"]).to eq(50)
    end
  end

  describe "#get_photo_link" do
    it "requests the download link endpoint" do
      stub_request(:get, "https://api.unsplash.com/photos/g3PyXO4A0yc/download")
        .to_return(status: 200, body: '{"url":"https://example.com/photo.jpg"}')

      response = api.get_photo_link("g3PyXO4A0yc").value!
      expect(response["url"]).to eq("https://example.com/photo.jpg")
    end
  end

  describe "#update_photo" do
    it "sends location and exif query parameters" do
      stub_request(:put, /api\.unsplash\.com\/photos\/g3PyXO4A0yc/)
        .to_return(status: 200, body: '{"id":"g3PyXO4A0yc"}')

      response = api.update_photo(
        "g3PyXO4A0yc",
        location: { latitude: 10.1, longitude: 20.2, name: "Test" },
        exif: { make: "Canon", model: "EOS", iso_speed_ratings: 100 }
      ).value!

      expect(response["id"]).to eq("g3PyXO4A0yc")
    end
  end

  describe "#like_photo / #unlike_photo" do
    it "like_photo requests the correct endpoint" do
      stub_request(:post, "https://api.unsplash.com/photos/g3PyXO4A0yc/like")
        .to_return(status: 200, body: '{"liked_by_user":true}')

      response = api.like_photo("g3PyXO4A0yc").value!
      expect(response["liked_by_user"]).to eq(true)
    end

    it "unlike_photo requests the correct endpoint" do
      stub_request(:delete, "https://api.unsplash.com/photos/g3PyXO4A0yc/like")
        .to_return(status: 204, body: "")

      response = api.unlike_photo("g3PyXO4A0yc").value!
      expect(response[:message]).to eq("Content Deleted")
    end
  end

  describe "#search" do
    it "sends the right query parameters" do
      stub_request(:get, "https://api.unsplash.com/search/photos")
        .with(query: { "query" => "ocean", "page" => "2", "per_page" => "15", "collections" => "123", "orientation" => "landscape" })
        .to_return(status: 200, body: '{"results":[]}')

      response = api.search("ocean", page: 2, per_page: 15, collections: "123", orientation: "landscape").value!
      expect(response["results"]).to eq([])
    end

    it "throws when query is missing" do
      expect { api.search("") }.to raise_error(
        RbSplash::WrapSplashError, "Parameter : query is missing!"
      )
    end
  end

  describe "#search_collections" do
    it "sends the right query parameters" do
      stub_request(:get, "https://api.unsplash.com/search/collections")
        .with(query: { "query" => "travel", "page" => "3", "per_page" => "20" })
        .to_return(status: 200, body: '{"results":[]}')

      response = api.search_collections("travel", page: 3, per_page: 20).value!
      expect(response["results"]).to eq([])
    end
  end

  describe "#search_users" do
    it "sends the right query parameters" do
      stub_request(:get, "https://api.unsplash.com/search/users")
        .with(query: { "query" => "john", "page" => "4", "per_page" => "5" })
        .to_return(status: 200, body: '{"results":[]}')

      response = api.search_users("john", page: 4, per_page: 5).value!
      expect(response["results"]).to eq([])
    end
  end

  describe "stats endpoints" do
    it "#get_stats_totals" do
      stub_request(:get, "https://api.unsplash.com/stats/total")
        .to_return(status: 200, body: '{"downloads":1000}')

      response = api.get_stats_totals.value!
      expect(response["downloads"]).to eq(1000)
    end

    it "#get_stats_month" do
      stub_request(:get, "https://api.unsplash.com/stats/month")
        .to_return(status: 200, body: '{"downloads":500}')

      response = api.get_stats_month.value!
      expect(response["downloads"]).to eq(500)
    end
  end

  describe "collection endpoints" do
    it "#list_collections" do
      stub_request(:get, "https://api.unsplash.com/collections")
        .with(query: { "page" => "1", "per_page" => "10" })
        .to_return(status: 200, body: '[]')

      response = api.list_collections.value!
      expect(response).to eq([])
    end

    it "#list_featured_collections" do
      stub_request(:get, "https://api.unsplash.com/collections/featured")
        .with(query: { "page" => "2", "per_page" => "8" })
        .to_return(status: 200, body: '[]')

      response = api.list_featured_collections(page: 2, per_page: 8).value!
      expect(response).to eq([])
    end

    it "#list_curated_collections" do
      stub_request(:get, "https://api.unsplash.com/collections/curated")
        .with(query: { "page" => "3", "per_page" => "9" })
        .to_return(status: 200, body: '[]')

      response = api.list_curated_collections(page: 3, per_page: 9).value!
      expect(response).to eq([])
    end

    it "#get_collection" do
      stub_request(:get, "https://api.unsplash.com/collections/collection-id")
        .to_return(status: 200, body: '{"id":"collection-id"}')

      response = api.get_collection("collection-id").value!
      expect(response["id"]).to eq("collection-id")
    end

    it "#get_curated_collection" do
      stub_request(:get, "https://api.unsplash.com/collections/curated/curated-id")
        .to_return(status: 200, body: '{"id":"curated-id"}')

      response = api.get_curated_collection("curated-id").value!
      expect(response["id"]).to eq("curated-id")
    end

    it "#get_collection_photos" do
      stub_request(:get, "https://api.unsplash.com/collections/collection-id/photos")
        .with(query: { "page" => "4", "per_page" => "12" })
        .to_return(status: 200, body: '[]')

      response = api.get_collection_photos("collection-id", page: 4, per_page: 12).value!
      expect(response).to eq([])
    end

    it "#get_curated_collection_photos" do
      stub_request(:get, "https://api.unsplash.com/collections/curated/curated-id/photos")
        .with(query: { "page" => "5", "per_page" => "13" })
        .to_return(status: 200, body: '[]')

      response = api.get_curated_collection_photos("curated-id", page: 5, per_page: 13).value!
      expect(response).to eq([])
    end

    it "#list_related_collections" do
      stub_request(:get, "https://api.unsplash.com/collections/collection-id/related")
        .to_return(status: 200, body: '[]')

      response = api.list_related_collections("collection-id").value!
      expect(response).to eq([])
    end
  end

  describe "collection CRUD" do
    it "#create_new_collection / #create_collection" do
      stub_request(:post, "https://api.unsplash.com/collections")
        .with(query: { "title" => "My Collection", "description" => "desc", "private" => "true" })
        .to_return(status: 200, body: '{"title":"My Collection"}')

      response = api.create_new_collection("My Collection", description: "desc", private_collection: true).value!
      expect(response["title"]).to eq("My Collection")
    end

    it "#create_collection alias works" do
      stub_request(:post, "https://api.unsplash.com/collections")
        .with(query: { "title" => "Test", "private" => "false" })
        .to_return(status: 200, body: '{"title":"Test"}')

      response = api.create_collection("Test").value!
      expect(response["title"]).to eq("Test")
    end

    it "#update_existing_collection / #update_collection" do
      stub_request(:put, "https://api.unsplash.com/collections/cid")
        .with(query: { "title" => "Title", "description" => "desc2", "private" => "false" })
        .to_return(status: 200, body: '{"title":"Title"}')

      response = api.update_existing_collection("cid", "Title", description: "desc2").value!
      expect(response["title"]).to eq("Title")
    end

    it "#update_collection alias works" do
      stub_request(:put, "https://api.unsplash.com/collections/cid")
        .with(query: { "title" => "Updated", "private" => "false" })
        .to_return(status: 200, body: '{"title":"Updated"}')

      response = api.update_collection("cid", "Updated").value!
      expect(response["title"]).to eq("Updated")
    end

    it "#delete_collection" do
      stub_request(:delete, "https://api.unsplash.com/collections/cid")
        .to_return(status: 204, body: "")

      response = api.delete_collection("cid").value!
      expect(response[:message]).to eq("Content Deleted")
    end

    it "#add_photo_to_collection" do
      stub_request(:post, "https://api.unsplash.com/collections/cid/add")
        .with(query: { "photo_id" => "pid" })
        .to_return(status: 200, body: '{"id":"cid"}')

      response = api.add_photo_to_collection("cid", "pid").value!
      expect(response["id"]).to eq("cid")
    end

    it "#remove_photo_from_collection" do
      stub_request(:delete, "https://api.unsplash.com/collections/cid/remove")
        .with(query: { "photo_id" => "pid" })
        .to_return(status: 200, body: '{"id":"cid"}')

      response = api.remove_photo_from_collection("cid", "pid").value!
      expect(response["id"]).to eq("cid")
    end
  end

  describe "#generate_bearer_token" do
    it "sends correct OAuth token request in POST body after init with access credentials" do
      client = described_class.new
      client.init(
        access_key: "access-key",
        secret_key: "secret-key",
        redirect_uri: "https://example.com/callback",
        code: "authorization-code"
      )

      stub_request(:post, "https://unsplash.com/oauth/token")
        .with(body: hash_including("client_id" => "access-key", "code" => "authorization-code"))
        .to_return(status: 200, body: '{"access_token":"bearer-token"}')

      response = client.generate_bearer_token.value!
      expect(response["access_token"]).to eq("bearer-token")
    end

    it "clears credentials after generating bearer token" do
      client = described_class.new
      client.init(
        access_key: "access-key",
        secret_key: "secret-key",
        redirect_uri: "https://example.com/callback",
        code: "authorization-code"
      )

      stub_request(:post, "https://unsplash.com/oauth/token")
        .to_return(status: 200, body: '{"access_token":"bearer-token"}')

      client.generate_bearer_token.value!

      expect(client.instance_variable_get(:@access_key)).to be_nil
      expect(client.instance_variable_get(:@secret_key)).to be_nil
      expect(client.instance_variable_get(:@redirect_uri)).to be_nil
      expect(client.instance_variable_get(:@code)).to be_nil
    end
  end

  describe "error handling" do
    it "wraps request failures in a WrapSplashError" do
      stub_request(:get, "https://api.unsplash.com/me")
        .to_return(status: 500, body: '{"error":"server error"}')

      expect { api.get_current_user_profile.value! }.to raise_error(RbSplash::WrapSplashError)
    end

    it "handles 204 status as Content Deleted" do
      stub_request(:delete, "https://api.unsplash.com/photos/g3PyXO4A0yc/like")
        .to_return(status: 204, body: "")

      response = api.unlike_photo("g3PyXO4A0yc").value!
      expect(response[:status]).to eq(204)
      expect(response[:message]).to eq("Content Deleted")
    end

    it "handles 403 status as Rate Limit Exceeded" do
      stub_request(:get, "https://api.unsplash.com/me")
        .to_return(status: 403, body: "")

      expect { api.get_current_user_profile.value! }.to raise_error(RbSplash::WrapSplashError, /HTTP 403/)
    end
  end
end

defmodule WishlistBridge.AmazonClientTest do
  use ExUnit.Case
  doctest WishlistBridge.AmazonClient

  test "url_for_isbn contains ISBN" do
    isbn = "1234"
    url = WishlistBridge.AmazonClient.url_for_isbn(isbn)

    url_parts = URI.parse(url)
    query = URI.decode_query(url_parts.query)

    assert query["ItemId"] == isbn
  end

  test "url_for_isbn contains a formatted ISO8601 timestamp" do
    isbn = "1234"
    url = WishlistBridge.AmazonClient.url_for_isbn(isbn)

    url_parts = URI.parse(url)
    query = URI.decode_query(url_parts.query)

    # Timestamp format: 2016-12-04T18%3A51%3A04.359130
    assert String.match?(query["Timestamp"], ~r/\A\d{4}-\d{2}-\d{2}T/)
  end

  test "url_for_isbn contains a signature (does not verify it here)" do
    isbn = "1234"
    url = WishlistBridge.AmazonClient.url_for_isbn(isbn)

    url_parts = URI.parse(url)
    query = URI.decode_query(url_parts.query)

    assert Map.has_key?(query, "Signature")
  end
end

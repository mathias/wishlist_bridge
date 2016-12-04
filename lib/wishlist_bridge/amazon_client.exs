defmodule WishlistBridge.AmazonClient do
  @moduledoc """
  Build signed Amazon search URLs like:
    http://webservices.amazon.com/onca/xml?
      Service=AWSECommerceService
      &Operation=ItemLookup
      &ResponseGroup=Large
      &SearchIndex=All
      &IdType=ISBN
      &ItemId=076243631X
      &AWSAccessKeyId=[Your_AWSAccessKeyID]
      &AssociateTag=[Your_AssociateTag]
      &Timestamp=[YYYY-MM-DDThh:mm:ssZ]
      &Signature=[Request_Signature]
  and request them
  """
  use HTTPoison.Base
  use Timex

  @scheme      "https"
  @host        "webservices.amazon.com"
  @path        "/onca/xml"
  @service     "AWSECommerceService"
  @http_method "GET"

  def lookup_isbn(isbn) do
    isbn
    |> params_for_isbn
    |> combine_params
    |> percent_encode_query
    |> url_for
    |> signed_url_for
    |> HTTPoison.get!
  end

  defp signed_url_for(url) do
    region = ""

    AWSAuth.sign_url(access_key, secret_key, @http_method, url, region, @service, headers \\ Map.new)
  end

  defp url_for(query) do
    "#{@scheme}://#{@host}#{@path}/#{@service}?#{query}"
  end

  defp params_for_isbn(isbn) do
    %{
      "Service" => @service
      "Operation" => "ItemLookup",
      "ResponseGroup" => "Large",
      "SearchIndex" => "All",
      "IdType" => "ISBN",
      "ItemId" => isbn,
      "AWSAccessKeyId" => access_key,
      "AssociateTag" => associate_key
    }
  end

  defp access_key do
    Application.get_env(:amazon_product_advertising_client)
  end

  defp secret_key do
    Application.get_env(:aws_secret_access_key)
  end

  defp associate_tag do
    Application.get_env(:associate_tag)
  end

  defp combine_params(params) do
    URI.encode_query(params)
  end
end

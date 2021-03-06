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

  @scheme      "http"
  @host        "webservices.amazon.com"
  @path        "/onca/xml"
  @service     "AWSECommerceService"
  @http_method "GET"

  def lookup_isbn(isbn) do
    isbn
    |> url_for_isbn
    |> HTTPoison.get!
  end

  def url_for_isbn(isbn) do
    isbn
    |> params_for_isbn
    |> combine_params
    |> url_for
    |> signed_url_for
  end

  def lookup_title(title) do
    title
    |> url_for_title
    |> HTTPoison.get!
  end

  def url_for_title(title) do
    title
    |> params_for_title
    |> combine_params
    |> url_for
    |> signed_url_for
  end

  ### Private

  defp common_params do
    %{
      "Service" => @service,
      "Operation" => "ItemLookup",
      "SearchIndex" => "All",
      "AWSAccessKeyId" => access_key,
      "AssociateTag" => associate_tag,
      "Timestamp" => formatted_current_time
    }
  end

  defp params_for_isbn(isbn) do
    Map.merge(common_params,
      %{
        "ResponseGroup" => "Large",
        "IdType" => "ISBN",
        "ItemId" => isbn
      })
  end

  defp params_for_title(title) do
    Map.merge(common_params,
      %{
        "ResponseGroup" => "Small",
        "Title" => title,
      })
  end

  defp signed_url_for(url) do
    url_parts = URI.parse(url)

    hmac = :crypto.hmac(:sha256,
                        secret_key,
                        Enum.join(["GET", url_parts.host, url_parts.path, url_parts.query], "\n"))
    signature = Base.encode64(hmac)

    "#{url}&Signature=#{signature}"
  end

  defp url_for(query) do
    "#{@scheme}://#{@host}#{@path}?#{query}"
  end

  defp formatted_current_time do
    DateTime.utc_now
    |> DateTime.to_iso8601
  end

  defp access_key do
    Application.get_env(:wishlist_bridge, :aws_access_key_id)
  end

  defp secret_key do
    Application.get_env(:wishlist_bridge, :aws_secret_access_key)
  end

  defp associate_tag do
    Application.get_env(:wishlist_bridge, :associate_tag)
  end

  defp combine_params(params) do
    URI.encode_query(params)
  end
end

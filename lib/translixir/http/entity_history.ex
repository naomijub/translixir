defmodule Translixir.Http.EntityHistory do
  @moduledoc false
  # credo:disable-for-next-line
  @http_client Application.get_env(:translixir, :httpoison)

  @spec entity_history(binary, any, any, boolean(), :asc | :desc) :: any
  def entity_history(url, headers, entity_hash, with_docs, :asc) do
    complete_url = "#{url}/#{entity_hash}?sort-order=asc&with-docs=#{with_docs}"
    make_history_req(complete_url, headers, entity_hash)
  end

  def entity_history(url, headers, entity_hash, with_docs, :desc) do
    complete_url = "#{url}/#{entity_hash}?sort-order=desc&with-docs=#{with_docs}"
    make_history_req(complete_url, headers, entity_hash)
  end

  def entity_history(_, _, _, _, _) do
    raise "Order param should be :asc or :desc"
  end

  @spec make_history_req(binary, any, any) :: any
  def make_history_req(url, headers, entity_hash) do
    response = @http_client.get(url, headers)

    case response do
      {:ok, content} when content.status_code < 300 -> Eden.decode!(content.body)
      _ -> raise "GET at entity-history with hash #{entity_hash} did not return 200"
    end
  end
end

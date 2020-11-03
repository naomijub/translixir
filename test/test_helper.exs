ExUnit.start()
# Mox.defmock(Translixir.HttpMock, for: Translixir.Http.Adapter)
Mox.defmock(Translixir.MockHTTPoison, for: HTTPoison.Base)
HTTPoison.start()

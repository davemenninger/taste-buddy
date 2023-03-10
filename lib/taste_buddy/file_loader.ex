defmodule TasteBuddy.FileLoader do
  def load_data_from_csv() do
    "Mobile_Food_Facility_Permit.csv"
    |> File.stream!()
    |> FoodTruckParser.parse_stream(skip_headers: false)
    |> Stream.transform(nil, fn
      headers, nil -> {[], headers}
      row, headers -> {[Enum.zip(headers, row) |> Map.new()], headers}
    end)
    |> Enum.to_list()
  end
end

NimbleCSV.define(FoodTruckParser, [])

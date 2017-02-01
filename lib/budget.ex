defmodule Budget do

  alias NimbleCSV.RFC4180, as: CSV

  def list_transactions do
    # Use the version that raises if file does not exist
    File.read!("lib/transactions-jan.csv")
    |> parse 
    |> filter
    |> normalize
    |> sort
    |> print
  end

  defp parse(string) do
    CSV.parse_string(string)
  end

  # ignores first row since we don't need it
  defp filter(rows) do
    Stream.map(rows, fn(row) -> Enum.drop(row, 1) end)
  end

  defp normalize(rows) do
    Stream.map(rows, &parse_amount(&1))
  end

  defp parse_amount([date, description, amount]) do
    [date, description, parse_to_number(amount)]
  end

  # converts amount in weird string
  # format used by the bank to number
  # TODO: using floats here is not a good idea IMO.
  # Or try to use integers or use the Decimal library.
  defp parse_to_number(string) do
    # Using String.to_float since you want to raise in case of failures
    string
    |> String.trim_trailing("\r")
    |> String.to_float()
    |> abs
  end

  defp sort(rows) do
    Enum.sort(rows, &order_asc_by_amount/2)
  end
  
  defp order_asc_by_amount([_, _, prev], [_, _, next]) do
    prev < next
  end

  defp print(rows) do
    IO.puts "\nTransactions:"
    rows
    |> Stream.each(&row_to_string/1)
    |> Stream.run
  end

  defp row_to_string([date, description, amount]) do
    # using :erlang.float_to_binary to convert 1.0e3 to 1000.00
    IO.puts "#{date} #{description} $#{:erlang.float_to_binary(amount, decimals: 2)}"
  end
end

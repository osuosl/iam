# frozen_string_literal: true
# Changes the column type for value to bigint so we can store the size in bytes
# of larger databases

Sequel.migration do
  transaction
  change do
    alter_table(:db_size_measurements) do
      set_column_type(:value, 'bigint')
    end
  end
end

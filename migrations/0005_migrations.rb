# frozen_string_literal: true
Sequel.migration do
  transaction
  change do
    create_table(:skus) do
      primary_key :id
      Integer     :sku_num
      String      :name, unique: true
      String      :description
      String      :family
      Float       :rate
      Boolean     :active, default: true
    end
  end
end

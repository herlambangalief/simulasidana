class CreateDanas < ActiveRecord::Migration[7.1]
  def change
    create_table :danas do |t|
      t.integer :target_dana
      t.integer :periode
      t.float :setoran
      t.float :saldo
      t.float :bunga
      t.float :pajak_bunga
      t.float :saldo_akhir
      t.date :tanggal_pembukaan

      t.timestamps
    end
  end
end

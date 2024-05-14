class CreateDanas < ActiveRecord::Migration[7.1]
  def change
    create_table :danas do |t|
      t.date :tanggal
      t.float :saldo_sebelumnya
      t.float :setoran
      t.float :bunga
      t.float :pajak_bunga
      t.float :saldo
      t.string :kondisi

      t.timestamps
    end
  end
end

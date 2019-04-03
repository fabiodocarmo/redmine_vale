class CreateCpfCnpjs < ActiveRecord::Migration
  def change
    create_table :cpf_cnpjs do |t|
      t.text :value
      t.references :contact
    end
    add_index :cpf_cnpjs, :contact_id

    CpfCnpj.reset_column_information

    Issue.all.each do |i|
      begin
        i.set_supplier
      rescue
        p "Erro na issue: #{i.id}"
      end
    end
  end
end

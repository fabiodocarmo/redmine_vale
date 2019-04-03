class ChangeSignFromIntToString < ActiveRecord::Migration
  def change
    change_column :approvals, :sign, :string

    Approval.reset_column_information

    sign_to_num = {
      greater_than: "1",
      less_than: "2",
      equal_to: "3",
      greater_than_or_equal_to: "4",
      less_than_or_equal_to: "5",
      any: "6"
    }.with_indifferent_access

    num_to_sign = sign_to_num.invert

    Approval.all.each do |a|
      a.sign = num_to_sign[a.sign.to_s]
      a.save(validate: false)
    end

  end
end

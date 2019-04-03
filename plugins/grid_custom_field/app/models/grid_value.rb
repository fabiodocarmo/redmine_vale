class GridValue < ActiveRecord::Base
  unloadable

  belongs_to :custom_value

  #TODO: Mapear a relação com o customField para não precisar pegar no banco na hora.
  def column_custom_field
    IssueCustomField.find(column)
  end

end

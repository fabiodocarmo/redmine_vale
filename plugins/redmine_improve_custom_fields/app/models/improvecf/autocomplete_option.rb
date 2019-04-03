class Improvecf::AutocompleteOption < Improvecf

  scope :filter, ->(custom_field_id, q) { where(custom_field_id: custom_field_id).where('value like ?', "%#{q}%") }

end

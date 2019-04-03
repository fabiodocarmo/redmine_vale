class Improvecf::GroupPriority < Improvecf
  unloadable
  belongs_to :author, class_name: 'Principal'
  belongs_to :enumeration, class_name: 'Enumeration'
end

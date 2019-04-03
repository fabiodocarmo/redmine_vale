module RedmineDashboard
  module Patches
    module RolePatch
    	def self.included(base) # :nodoc:
    	  base.class_eval do
  	    unloadable
  	  	has_and_belongs_to_many :groups, :join_table => "roles_groups", :foreign_key => "role_id"
    	  end
    	end
    end
  end
end

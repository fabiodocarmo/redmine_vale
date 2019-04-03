class AddAllProjectsAndAllTrackersAndAllStatusFrom < ActiveRecord::Migration
  def change
    add_column :atribuicao_automaticas, :all_projects   , :boolean, default: false
    add_column :atribuicao_automaticas, :all_trackers   , :boolean, default: false
    add_column :atribuicao_automaticas, :all_status_from, :boolean, default: false
  end
end

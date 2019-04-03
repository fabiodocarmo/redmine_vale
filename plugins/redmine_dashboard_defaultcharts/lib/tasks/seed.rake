#encoding: utf-8

namespace :redmine do
  namespace :plugins do
    namespace :redmine_dashboard_defaultcharts do
      task seed: :environment do
        progress = DashboardWidget.create!(name: "Progresso", priority: 0)

        weekly_progress = RedmineWidget.new(source_plugin: 'redmine_dashboard_defaultcharts', name_id: 'weekly_progress', priority: 0)
        weekly_progress.dashboard_widget = progress
        weekly_progress.config = HashWithIndifferentAccess.new({ exclude_statuses: "", range_week: 8 })
        weekly_progress.save!

        new_by_tracker = RedmineWidget.new(source_plugin: 'redmine_dashboard_defaultcharts', name_id: 'new_by_tracker', priority: 10)
        new_by_tracker.dashboard_widget = progress
        new_by_tracker.config = ActiveSupport::HashWithIndifferentAccess.new({ exclude_statuses: "", range_month: 12 })
        new_by_tracker.save!

        new_by_project = RedmineWidget.new(source_plugin: 'redmine_dashboard_defaultcharts', name_id: 'new_by_project', priority: 20)
        new_by_project.dashboard_widget = progress
        new_by_project.config = ActiveSupport::HashWithIndifferentAccess.new({ exclude_statuses: "", range_month: 12 })
        new_by_project.save!

        answered_by_project = RedmineWidget.new(source_plugin: 'redmine_dashboard_defaultcharts', name_id: 'answered_by_project', priority: 30)
        answered_by_project.dashboard_widget = progress
        answered_by_project.config = ActiveSupport::HashWithIndifferentAccess.new({ exclude_statuses: "", range_month: 12 })
        answered_by_project.save!

        aging = DashboardWidget.create!(name: "Aging", priority: 10)

        aging_project = RedmineWidget.new(source_plugin: 'redmine_dashboard_defaultcharts', name_id: 'aging_project', priority: 0)
        aging_project.dashboard_widget = aging
        aging_project.config = ActiveSupport::HashWithIndifferentAccess.new({ aging: "0-2\n3-4\n5-8\n9-13\n14" })
        aging_project.save!

        aging_has_atendent = RedmineWidget.new(source_plugin: 'redmine_dashboard_defaultcharts', name_id: 'aging_has_atendent', priority: 10)
        aging_has_atendent.dashboard_widget = aging
        aging_has_atendent.config = ActiveSupport::HashWithIndifferentAccess.new({ aging: "0-2\n3-4\n5-8\n9-13\n14" })
        aging_has_atendent.save!

        aging_per_atendent = RedmineWidget.new(source_plugin: 'redmine_dashboard_defaultcharts', name_id: 'aging_per_atendent', priority: 20)
        aging_per_atendent.dashboard_widget = aging
        aging_per_atendent.config = ActiveSupport::HashWithIndifferentAccess.new({ aging: "0-2\n3-4\n5-8\n9-13\n14" })
        aging_per_atendent.save!

        aging_per_project = RedmineWidget.new(source_plugin: 'redmine_dashboard_defaultcharts', name_id: 'aging_per_project', priority: 30)
        aging_per_project.dashboard_widget = aging
        aging_per_project.config = ActiveSupport::HashWithIndifferentAccess.new({ aging: "0-2\n3-4\n5-8\n9-13\n14" })
        aging_per_project.save!

        avg_time = DashboardWidget.create!(name: "Tempo médio de resposta", priority: 20)

        average_answer_time_per_project = RedmineWidget.new(source_plugin: 'redmine_dashboard_defaultcharts', name_id: 'average_answer_time_per_project', priority: 0)
        average_answer_time_per_project.dashboard_widget = avg_time
        average_answer_time_per_project.config = ActiveSupport::HashWithIndifferentAccess.new({ })
        average_answer_time_per_project.save!

        project_average_answer_time = RedmineWidget.new(source_plugin: 'redmine_dashboard_defaultcharts', name_id: 'project_average_answer_time', priority: 10)
        project_average_answer_time.dashboard_widget = avg_time
        project_average_answer_time.config = ActiveSupport::HashWithIndifferentAccess.new({ })
        project_average_answer_time.save!

        performance = DashboardWidget.create!(name: "Produtividade", priority: 20)

        performance_per_fte = RedmineWidget.new(source_plugin: 'redmine_dashboard_defaultcharts', name_id: 'performance_per_fte', priority: 0)
        performance_per_fte.dashboard_widget = performance
        performance_per_fte.config = ActiveSupport::HashWithIndifferentAccess.new({ goal: 10, range_day: 30 })
        performance_per_fte.save!

        performance_by_project = RedmineWidget.new(source_plugin: 'redmine_dashboard_defaultcharts', name_id: 'performance_by_project', priority: 10)
        performance_by_project.dashboard_widget = performance
        performance_by_project.config = ActiveSupport::HashWithIndifferentAccess.new({ goal: 10, range_day: 30 })
        performance_by_project.save!
      end
    end
  end
end

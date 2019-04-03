class SqlReportExecution < ActiveRecord::Base
  unloadable

  enum status: [
      :pending, :finished
  ].map { |s| [s, s.to_s]}.to_h

  belongs_to :requester, class_name: 'User'
  belongs_to :sql_report

  serialize :filters
end

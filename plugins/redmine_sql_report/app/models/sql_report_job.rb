class SqlReportJob < ActiveJob::Base
  queue_as :sql_report

  def perform(*args)
    if args.size == 1
      execution = SqlReportExecution.find(args.first)

      sql_report, filters = execution.sql_report, execution.filters
    elsif args.size == 3  # compatibility to when there was no SqlReportExecution model
      sql_report = SqlReport.find(args.first)
      user = User.find(args.second)
      filters = args.third

      execution = SqlReportExecution.new(sql_report: sql_report, requester: user, filters: filters)
    else
      raise ArgumentError.new("wrong number of arguments (given #{args.size}, expected 1 or 3)")
    end

    execution.started_at = Time.zone.now
    execution.save

    result = ReportsReplicaDb.run_query(sql_report.sql, filters)

    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: "#{sql_report.name}") do |sheet|
      sheet.add_row result.columns
      result.each do |row|
        sheet.add_row(row.map do |col,val|
          result.column_types[col].send(:type_cast, val)
        end)
      end
    end

    now = Time.zone.now
    file_name = "#{sql_report.name}_#{now.strftime('%Y-%m-%d_%H-%M-%S')}.xlsx"

    package.serialize("#{SQL_REPORT_ROOT_DIRECTORY}/#{file_name}")

    execution.attributes = { finished_at: now, file_name: file_name, status: :finished }
    execution.save!

    SqlReportMailer.notify_external(execution).deliver
  end
end

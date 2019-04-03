class ReportsReplicaDb < ActiveRecord::Base
  attr_protected

  establish_connection(:reports_replica)

  def self.run_query(sql, filters)
    result = nil

    ReportsReplicaDb.connection_pool.with_connection do |connection|
      result = connection.select_all(
        ActiveRecord::Base.send(:sanitize_sql_array, [sql.gsub('%', '%%'), filters])
      )
    end

    result
  end
end

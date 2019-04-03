class ValeExportReplicaIssue < Issue
  attr_protected

  establish_connection(:reports_replica)

end

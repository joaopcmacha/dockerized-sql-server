#!/bin/bash

# Wait 180 seconds for SQL Server to start up by ensuring that 
# calling SQLCMD does not return an error code, which will ensure that sqlcmd is accessible
# and that system and user databases return "0" which means all databases are in an "online" state
# https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-databases-transact-sql?view=sql-server-2017 

DBSTATUS=1
ERRCODE=1
i=0

while (( DBSTATUS != 0 && i < 180 && ERRCODE != 0 )); do
	i=$i+1
	DBSTATUS=$(/opt/mssql-tools18/bin/sqlcmd -C -h -1 -t 1 -U sa -P $SA_PASSWORD -Q "SET NOCOUNT ON; Select SUM(state) from sys.databases")
	ERRCODE=$?
	sleep 1
done

if (( $DBSTATUS != 0 )) || (( $ERRCODE != 0 )); then 
	echo "SQL Server took more than 180 seconds to start up or one or more databases are not in an ONLINE state"
	exit 1
fi

echo "" > setup.sql
for relative_file_path in /db_files/*.mdf; do
  filename=$(basename -- "$relative_file_path")
  file_path="/db_files/$filename"
  filename_without_extension="${filename%.*}"
  log_file_path="/db_files/"$filename_without_extension"_log.ldf"
  echo "CREATE DATABASE [$filename_without_extension] ON (FILENAME = N'$file_path'), (FILENAME = N'$log_file_path') FOR ATTACH; " >> setup.sql
#  /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d master -Q "CREATE DATABASE [$filename_without_extension] ON (FILENAME = N'$file_path'), (FILENAME = N'$log_file_path') FOR ATTACH"
done

# # Run the setup script to create the DB and the schema in the DB
 /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -d master -i setup.sql
ALTER ROLE [db_owner] ADD MEMBER [CDN];


GO
ALTER ROLE [db_backupoperator] ADD MEMBER [ASP\AspComarchBackupDB];


GO
ALTER ROLE [db_backupoperator] ADD MEMBER [CDNBackup];


GO
ALTER ROLE [db_datareader] ADD MEMBER [onebi];


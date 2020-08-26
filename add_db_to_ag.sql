--Please review the scripts below to understand what they are doing, you will need to replace drive locations and the AG name at a minimum

---------------------------
----- ON PRIMARY NODE -----
---------------------------
--Skip if database already exists to the existing database code at the bottom, but this line is good for testing to ensure it runs properly on your system
--Perform a FIND & REPLACE on [Test] with your new [DatabaseName].
--CREATE DATABASE [Test]

ALTER DATABASE [Test] SET RECOVERY FULL

--Update drive location to your backup location
BACKUP DATABASE [Test] TO DISK = 'C:\Backups\Test.BAK'
BACKUP LOG [Test] TO DISK = 'C:\Backups\Test.TRN'

ALTER AVAILABILITY GROUP AG_Name ADD DATABASE [Test];


-----------------------------
----- ON SECONDARY NODE -----
-----------------------------
--Verify backup location, you  may need to copy the backup file to the second server to avoid permission issues
RESTORE DATABASE [Test] FROM DISK = '\\PrimaryNode\Backups\Test.BAK' WITH NORECOVERY
RESTORE LOG [Test] FROM DISK = '\\PrimaryNode\Backups\Test.TRN' WITH NORECOVERY

--Change AG_Name to your Availability Group Name
ALTER DATABASE [Test] SET HADR AVAILABILITY GROUP = AG_Name



------------------------------------------------
----- GENERATE CODE FOR EXISTING DATABASES -----
------------------------------------------------

--Update the drive letter to your backup location and AG_Name to your AG!
SELECT
   name
   ,[PrimaryCode] = '
      --PRIMARY
      ALTER DATABASE  ' + QUOTENAME(name) + ' SET RECOVERY FULL
      BACKUP DATABASE ' + QUOTENAME(name) + ' TO DISK = ''C:\Backups\'+name+'AG_BackupFull.BAK''
      BACKUP LOG ' + QUOTENAME(name) + ' TO DISK = ''C:\Backups\'+name+'AG_BackupLog.TRN''
      ALTER AVAILABILITY GROUP AG_Name ADD DATABASE ' + QUOTENAME(name) + ';
      '
   ,[SecondaryCode] = '
      --SECONDARY
      RESTORE DATABASE ' + QUOTENAME(name) + ' FROM DISK = ''C:\Backups\'+name+'AG_BackupFull.BAK'' WITH NORECOVERY
      RESTORE LOG ' + QUOTENAME(name) + ' FROM DISK = ''C:\Backups\'+name+'AG_BackupLog.TRN'' WITH NORECOVERY
      ALTER DATABASE ' + QUOTENAME(name) + ' SET HADR AVAILABILITY GROUP = AG_Name
      '
FROM sys.databases
WHERE database_id > 4      

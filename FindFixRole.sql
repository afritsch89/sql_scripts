/*	
	1 Find Roles Owned by User other than DBO
	To Fix: Database -> Security -> Roles -> Database Roles -> Select Role, Properties, Change Owner
*/
SELECT
	 [Role] = dp2.[name]
	,[Owner] = dp1.[name]
	,[FixScript] = 'ALTER AUTHORIZATION ON ROLE::' + QUOTENAME(dp2.[name]) + ' TO [dbo];'
FROM sys.database_principals dp1
	INNER JOIN sys.database_principals dp2 ON dp1.principal_id = dp2.owning_principal_id
WHERE dp1.[name] <> 'dbo';


/*
	2 Get Schemas and Owners
	To Fix: Database -> Security -> Schemas -> Select Schema, Properties, Change Owner
	You do not have to change the schema owner of all schemas to DBO, you would be primarily looking for individual users with ownership, not roles with ownership
*/
SELECT
* 
,[FixScript] = 'ALTER AUTHORIZATION ON SCHEMA::' + QUOTENAME(SCHEMA_NAME) + ' TO [dbo];'
FROM INFORMATION_SCHEMA.schemata;

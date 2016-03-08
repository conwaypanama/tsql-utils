CREATE PROCEDURE SPFullDatabaseBackup
@DbName nvarchar(max),
@Path nvarchar(max)

AS

DECLARE @DB nvarchar(max)
DECLARE @FullPath nvarchar(max)
DECLARE @ProdVersion varchar(32)
DECLARE @ShortProdVersion varchar(32)
DECLARE @ProdEdition nvarchar(max)
DECLARE @ShortProdEdition nvarchar(max)

SET @DB = DB_NAME(DB_ID(@DbName))
SET @FullPath = @Path + @DbName

SET @ProdVersion = CAST(SERVERPROPERTY('ProductVersion') AS varchar(max))
SET @ProdEdition = CAST(SERVERPROPERTY('Edition') AS nvarchar(max))
SET @ShortProdVersion = LEFT(@ProdVersion,
                             CHARINDEX('.', @ProdVersion, CHARINDEX('.', @ProdVersion) +1) -1
                             )
SET @ShortProdEdition = LEFT(@ProdEdition, CHARINDEX(' ', @ProdEdition) -1)

BEGIN TRY
  IF (@DB IS NULL OR @DB = '')
    RAISERROR('<< Exception >> Invalid database name. Make sure it''s name is correct', 16, 1)
  
  BACKUP DATABASE @DB TO DISK = @FullPath WITH INIT, NOFORMAT
END TRY
BEGIN CATCH
  DECLARE @ErrorMsg nvarchar(4000)
  DECLARE @ErrorSev int
  DECLARE @ErrorSte int
  
  SET @ErrorMsg = ERROR_MESSAGE()
  SET @ErrorSev = ERROR_SEVERITY()
  SET @ErrorSte = ERROR_STATE()
  
  RAISERROR(@ErrorMsg, @ErrorSev, @ErrorSte)
END CATCH
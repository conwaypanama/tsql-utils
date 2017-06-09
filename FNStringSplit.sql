IF EXISTS
    (SELECT *
FROM sys.objects
WHERE object_id = OBJECT_ID(N'FNStringSplit') AND OBJECTPROPERTY(OBJECT_ID(N'FNStringSplit'), N'IsTableFunction') = 1)

    DROP FUNCTION FNStringSplit
GO
CREATE FUNCTION FNStringSplit(@str nvarchar(max), @delm char(1) = ',')
RETURNS @splitedTableResult TABLE
(
  id int PRIMARY KEY IDENTITY(1,1),
  value nvarchar(max) NOT NULL
)
AS
BEGIN
  DECLARE @newStr nvarchar(max)
  DECLARE @firstDelmIndex bigint
  DECLARE @newStrLength bigint
  -- Eliminar los espacios en blanco
  -- Eliminar espacio en blanco innecesario entre delimitador
  SET @newStr = REPLACE(LTRIM(RTRIM(@str)), ' ', '')
  -- @ptr int Puntero al siguiente elemento que NO es el símbolo delimitador
  -- @next int Puntero al siguiente incidente coma
  DECLARE @ptr int, @next int
  SET @ptr = 1
  SET @firstDelmIndex = CHARINDEX(@delm, @newStr, @ptr)
  SET @newStrLength = LEN(@newStr)
  SET @next = IIF(@newStrLength > 0 AND @firstDelmIndex = 0, @newStrLength, @firstDelmIndex)
  
  WHILE @next != 0
  BEGIN
    SET @next = CHARINDEX(@delm, @newStr, @ptr)
    INSERT INTO @splitedTableResult
    VALUES(SUBSTRING(@newStr, @ptr, IIF(@next != 0, @next - @ptr, LEN(@newStr))))
    SET @ptr = @next + 1
  END
  RETURN
END

create procedure [dbo].[SPMakeListOfExpressions]
@str nvarchar(255),
@delm char(1) = ',',
@result nvarchar(255) output
as

/**
Separa valores dentro de una cada segun el delimitador especificado

@param str Cada de caracteres
@param [delm] Delimitador
@return Retorna una lista de valores, dentro de comillas simples, separados por coma
*/

set NOCOUNT on

declare @list nvarchar(255) = ''
declare @f int
declare @i int

set @i = 1 -- indice origen de busqueda
set @f = CHARINDEX(@delm, @str, @i) -- indice limite de busqueda

begin try
  /* Elevar excepcion en caso que el argumento */
  if RIGHT(@str, 1) = @delm or LEFT(@str, 1) = @delm
    RAISERROR('<<EXCEPTION>> A leading or trailing delimiter found in argument',
            16,
            1)
  if @f > 0
  begin
    /* Iterar argumento de entrada delimitado por el caracter especificado */
    while @f != 0
    begin
      set @f = CHARINDEX(@delm, @str, @i)

      if @f != 0
        set @list += QUOTENAME(LTRIM(RTRIM(SUBSTRING(@str, @i, @f - @i))), '''') + ','
      else
        set @list += QUOTENAME(LTRIM(RTRIM(SUBSTRING(@str, @i, LEN(@str)))), '''')

      set @i = @f + 1
    end
  end
  else
  begin
    /* Ya que no hay suficiente argumentos separados por delimitador */
    set @list += QUOTENAME(LTRIM(RTRIM(@str)), '''')
  end
end try
begin catch
  declare @errorMessage nvarchar(4000),
        @errorSeverity int,
        @errorState int

  set @errorMessage = ERROR_MESSAGE()
  set @errorSeverity = ERROR_SEVERITY()
  set @errorState = ERROR_STATE()

  RAISERROR(@errorMessage, @errorSeverity, @errorState)
end catch

set @result = @list

return
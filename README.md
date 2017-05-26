## SPFullDatabaseBackup
> Crea un respaldo completo (no-incremental) de base de dato

#### SPFullDatabaseBackup @DbName, @Path
##### @DbName
*Requerido* <br />
Tipo: `nvarchar(max)`

Nombre canonico de base de dato

##### @Path
*Requerido* <br />
Tipo: `nvarchar(max)`

Directorio *local del servidor* donde sera almacenado el respaldo. *Por ahora* es necesario que el URI termine con trailing slash, `\`; Ejemplo: `X:\RootDir\`.

### Uso
***Nota: Recomendamos crear el SP dentro de la DB master asi, puede respaldar multiples UDF-DB***

```sql
EXEC SPFullDatabaseBackup N'ArrozConPolloDB', 'P:\'
```

## SPMakeListOfExpressions
> Retorna una lista de valores, envuelva entre comillas simples, separados por coma

#### SPMakeListOfExpressions @str, [@delm], @result = output
##### @str
*Requerido* <br />
Tipo: `nvarchar(255)`

Cada de caracteres a evaluar

##### @delm
*Opcional* <br />
Tipo: `char(1)` <br />
Por defecto: `','`

Caracter delimitador de cadena de caracteres

##### output
*Requerido* <br />
Tipo: `nvarchar(255) OUTPUT`

Variable que almacena el resultado devuelto de procedimiento almacenado. Parametro `OUTPUT` no esta demas; `OUTPUT` indica que el parametro de entrada es un parametro de salida.

Para mas informacion sobre `OUTPUT` [ver documentacion](https://msdn.microsoft.com/en-us/library/ms187926.aspx).

### Uso
Mejor uso es con sentencias dinamicas.

```sql
declare @whsCodes nvarchar(255)
declare @cmd nvarchar(max)

exec SPMakeListOfExpressions N'02,03,04,05', @result = @whsCodes output

set @cmd =
N'
SELECT TOP 100 *
FROM [stocks]
WHERE ItemCode = N''AIE-010-40X40CM-R''
  AND WhsCode IN (' + @whsCodes + ')'

exec sp_executesql @cmd

/** -- Resutado --
ItemCode	    WhsCode	OnHand
AIE-010-40X40CM-R	02	0.000000
AIE-010-40X40CM-R	03	0.000000
AIE-010-40X40CM-R	04	0.000000
AIE-010-40X40CM-R	05	0.000000
*/
```

## FNStringSplit
> Devuelve una tabla con cada elemento dividido por el carácter delimitador

#### FNStringSplit(@str, [@delm])
##### @str
*Requerido* <br />
Tipo: `nvarchar(max)` <br />

Lista de cadenas separadas por el carácter delimitador.

##### @delm
*Opcional* <br />
Tipo: `char(1)` <br />
Por defecto: `','`

Carácter delimitador sirve como una __pista__. Tenga en cuenta que si `@delm` no se especifica, debe escribir `default` de todos modos.

Documentacion [oficial](https://docs.microsoft.com/en-us/sql/t-sql/statements/create-function-transact-sql#examples).

><strong>When a parameter of the function has a default value, the keyword DEFAULT must be specified when the function is called to retrieve the default value.
> 
>This behavior is different from using parameters with default values in stored procedures in which omitting the parameter also implies the default value. However, the DEFAULT keyword is not required when invoking a scalar function by using the EXECUTE statement.</strong>

#### value
Retorna: `column` <br/>
Tipo: `nvarchar(max)` <br/>

Devuelve columna de la tabla.

### Uso
La intención de esta función de valor de tabla es de imitar la función oficial [STRING_SPLIT](https://docs.microsoft.com/en-us/sql/t-sql/functions/string-split-transact-sql). Sin embargo, sólo está disponible para el modo de compatibilidad _130_, dejando así a muchos de nosotros deseando utilizar esta función impresionante.

```sql
SELECT value
FROM dbo.FNStringSplit('1,2,3,4', ',')

-- recorte de espacios
SELECT value
FROM dbo.FNStringSplit('1,2, 3,4    ', ',')
```

Resultado de las consultas anteriores.

| #   | value |
| --- | --- |
| 1   | _1_ |
| 2   | _2_ |
| 3   | _3_ |
| 4   | _4_ |

Por supuesto, ya que esta es una función de valor de tabla puede hacer consultas como de costumbre.

```sql
-- puede filtar
SELECT value
FROM dbo.FNStringSplit('1,2, 3,4    ', ',')
WHERE value IN (1, 3)
```

| #   | value |
| --- | --- |
| 1   | _1_ |
| 2   | _3_ |

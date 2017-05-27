declare @tempdb_basename varchar(max)
declare @tempdb_name varchar(max)
declare @tempdb_size int       = 50 -- MB. ej. 50MB * 1024/8-Kb paginas
declare @tempdb_filegrowth int = 50 -- MB
declare @tempdb_filepath varchar(max)
/**
* Parametros
*
* @strict [bit]       Indica numeros de archivos son calculados seguno `cpu_cores / 4` o `cpu_cores / hyperthread_ratio`
* @increments [float] Porcentaje espacio inicial
* @nf [int]           Numero de archivos `mdf` calculado segun la cantidad de CPUs
* @i [int]            Indice sufijo para cada archivo `mdf`
*/
declare @strict bit = 0
declare @increments float = 66.6
declare @nf int
declare @i int = 0
declare @sql nvarchar(max) = ''

select @nf = case @strict
  when 1 then FLOOR(cpu_count / 4)
  when 0 then FLOOR(cpu_count + hyperthread_ratio)
  else 0
end
from sys.dm_os_sys_info

select @tempdb_filepath = left(physical_name, len(physical_name) - charindex('\', reverse(physical_name))),
       @tempdb_basename = name,
       @tempdb_size     = case isnull(@tempdb_size, -1)
                          when -1 then ((size + FLOOR((size * @increments) / 100)) / 100) * 8
                          else @tempdb_size
                          end
from sys.master_files
where database_id = DB_ID('tempdb') and file_id = 1 and type = 0

while @i < @nf
begin
  set @tempdb_name = @tempdb_basename + cast(@i +1 as char)
  set @sql += N'
  alter database tempdb
  add file (
    name = ''' + rtrim(@tempdb_name) + ''',
    filename = ''' + rtrim(@tempdb_filepath) + '\' + rtrim(@tempdb_name) + '.ndf' + ''',
    size = ' + cast(@tempdb_size as varchar) + ',
    filegrowth = ' + cast(@tempdb_filegrowth as varchar) + '
  );

  '
  set @i = @i + 1
end

select @sql

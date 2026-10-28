create procedure CDN.SortOrder
as
begin
  set nocount on;
  -- utworzenie tabeli
  create table #sort1( num integer, string char(1) );
  -- wypełnienie wartosciami (zero pominiete)
  declare @counter integer;
  set @counter = 1;
  while @counter < 256
  begin
    insert into #sort1 (num, string) values( @counter, char(@counter) )
    set @counter = @counter + 1;
  end
  -- odczytanie kursorem
  declare @znak char(1);
  declare @posortowane NVARCHAR(255);
  declare SortOrder cursor local forward_only for
    select string from #sort1 order by string, num;
  set @posortowane = '';
  open SortOrder;
  fetch next from SortOrder into @znak;
  while @@FETCH_STATUS = 0
  begin
    set @posortowane = @posortowane + @znak;
    fetch next from SortOrder into @znak;
  end
  close SortOrder;
  -- zwrócenie rezultatu
  select @posortowane;
  set nocount off;
end

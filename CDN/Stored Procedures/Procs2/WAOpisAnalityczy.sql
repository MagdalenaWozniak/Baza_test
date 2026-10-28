CREATE procedure CDN.WAOpisAnalityczy
@document nvarchar(255) = NULL,
@dokumentId int = 0,
@addPozycja int = 0,
@addPercent int = 0,
@addValue int = 0
As
  SET NOCOUNT ON; SET ANSI_WARNINGS OFF;
  IF OBJECT_ID('tempdb..#cdnWymiary', 'U') IS NOT NULL
    DROP TABLE #cdnWymiary
 Declare @dokumentTyp int = 0;
 Declare @sql nvarchar(2024);
 Declare @kolumna nvarchar(255);
 select @kolumna = 'Wyy_'+kolumna,@dokumentTyp=ID from CDN.ListaDokumentowWymiarowanych()
 where nazwa = @document
 --IF OBJECT_ID('tempdb..#Wymiary', 'U') IS NOT NULL
 -- DROP TABLE #Wymiary
 --CREATE TABLE #Wymiary(Wyy_WyyID INT, Wyy_Kod VARCHAR(20))
 --Set @sql = 'select Wyy_WyyId, Wyy_Kod into #Wymiary from ( select Wyy_WyyId, Wyy_Kod from CDN.Wymiary where Wyy_Aktywny=1 and IsNull(Wyy_ParentId, 0)=0 and ' + @kolumna + ' = 1 '
    --        + 'union select WyW_WyyId, CDN.ParseWymiarFromValue(WyW_Wartosc) from CDN.WymiaryWartosci where WyW_WyyId<>0 and WyW_DokumentTyp = ' + convert(varchar, @dokumentTyp ) + ' and ' + 'WyW_DokumentId = ' + convert(varchar, @dokumentID) + ') a;';
 --Execute dbo.sp_executesql @sql
 DECLARE @WymiaryW table(Wyy_WyyID INT, Wyy_Kod VARCHAR(20))
 Set @sql = 'select Wyy_WyyId, Wyy_Kod from ( select Wyy_WyyId, Wyy_Kod from CDN.Wymiary where Wyy_Aktywny=1 and IsNull(Wyy_ParentId, 0)=0 and ' + @kolumna + ' = 1 '
            + 'union select WyW_WyyId, CDN.ParseWymiarFromValue(WyW_Wartosc) from CDN.WymiaryWartosci where WyW_WyyId<>0 and WyW_DokumentTyp = ' + convert(varchar, @dokumentTyp ) + ' and ' + 'WyW_DokumentId = ' + convert(varchar, @dokumentID) + ') a;';
 INSERT INTO @WymiaryW EXEC dbo.sp_executesql @sql
 declare @index int = 0;
 Set @sql = ' create table #cdnWymiary (Id int identity(1,1)'
 if @addPozycja <> 0
    Set @sql = @sql + ', Pozycja nvarchar(128)';
 --Declare wymiaryCursor Cursor Local Fast_Forward For Select distinct Wyy_Kod From #Wymiary
 Declare wymiaryCursor Cursor Local Fast_Forward For Select distinct Wyy_Kod From @WymiaryW
 Open wymiaryCursor
 While 1=1
 Begin
  Fetch Next From wymiaryCursor InTo @kolumna
  If @@Fetch_Status<>0 Break
  --if @index >= 1
  Set @sql = @sql + ',';
  Set @sql = @sql + @kolumna + ' nvarchar(1024)';
  Set @index = @index + 1;
 End
 Close wymiaryCursor
 Deallocate wymiaryCursor
 if @addPercent <> 0
  Set @sql = @sql + ', Procent decimal(6,2)';
 if @addValue <> 0
  Set @sql = @sql + ', Wartość decimal(15,2)';
  --drop table #Wymiary;
 --Set @sql = @sql + '); Insert into #cdnWymiary (Procent, Value) values(0,0); select * from #cdnWymiary; drop table #cdnWymiary;';
 Set @sql = @sql + '); select * from #cdnWymiary;';
 execute sp_executesql @sql;
 --SET NOCOUNT ON; SET ANSI_WARNINGS OFF;

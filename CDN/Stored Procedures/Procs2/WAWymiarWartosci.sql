CREATE procedure CDN.WAWymiarWartosci
@document nvarchar(255) = NULL,
@wymiar nvarchar(255) = NULL,
@OkresObrachunkowyId int = NULL
As
  SET NOCOUNT ON; SET ANSI_WARNINGS OFF;
 Declare @ID int = NULL;
 Declare @sql nvarchar(1024);
 Declare @kolumna nvarchar(8);
 if IsNull(@document, '') <> ''
 begin
  select @kolumna = 'Wyy_'+kolumna from CDN.ListaDokumentowWymiarowanych() where nazwa = @document
  Set @sql = 'select @ID = Wyy_WyyId from CDN.Wymiary where Wyy_Aktywny=1 and IsNull(Wyy_ParentId, 0)=0 and ' + @kolumna + ' = 1 and Wyy_Kod='''+@wymiar+'''';
 end
 else
 begin
  Set @sql = 'select @ID = Wyy_WyyId from CDN.Wymiary where Wyy_Aktywny=1 and IsNull(Wyy_ParentId, 0)=0 and Wyy_Kod='''+@wymiar+'''';
 end
 Execute dbo.sp_executesql @sql, N'@ID int OUTPUT', @ID=@ID OUTPUT
 --select @ID = Wyy_WyyId from cdnWymiary;
 --drop table cdnWymiary;
 IF OBJECT_ID('tempdb..#wymiar', 'U') IS NOT NULL
        DROP TABLE #wymiar
 IF OBJECT_ID('tempdb..#wartosci', 'U') IS NOT NULL
        DROP TABLE #wartosci
 create table #wymiar(WyyID int, Typ int, TypWymiaru int, ComplexKod nvarchar(1024), SimpleKod  nvarchar(1024), ParentId int);
 declare @hid int = 1;
 WITH Wymiar AS (
  SELECT @hid as hid, Wyy_WyyID as WyyID, Wyy_Typ as Typ, Wyy_TypWymiaru as TypWymiaru, convert(nvarchar(1024),Wyy_Kod) as ComplexKod, convert(nvarchar(1024),Wyy_Kod) as SimpleKod, Wyy_ParentID as ParentID from CDN.Wymiary
  where Wyy_WyyID = @ID
  UNION ALL
  SELECT hid+1, A.Wyy_WyyID, A.Wyy_Typ, A.Wyy_TypWymiaru, convert(nvarchar(1024),ComplexKod+'/'+Wyy_Kod), convert(nvarchar(1024),Wyy_Kod), A.Wyy_ParentID from CDN.Wymiary A join Wymiar on (Wymiar.WyyID = A.Wyy_ParentID)
 )
 insert into #wymiar(WyyID, Typ, TypWymiaru, ComplexKod, SimpleKod, ParentId)
 SELECT WyyID, Typ, TypWymiaru, ComplexKod, SimpleKod, ParentId
 FROM Wymiar
 ORDER BY hid
 create table #wartosci(ID nvarchar(1024), ViewID nvarchar(1024), ViewValue nvarchar(1024), WyyID int, SlownikTyp int, SlownikId int, KeyValue nvarchar(1024), Value nvarchar(1024), ComplexKod nvarchar(1024), ComplexValue nvarchar(1024), SimpleKod  nvarchar(1024), Description1 nvarchar(255), Description2 nvarchar(255), Description3 nvarchar(255));
 Declare @WyyID int;
 Declare @Typ int;
 Declare @TypWymiaru int;
 Declare @ComplexKod nvarchar(1024);
 Declare @SimpleKod nvarchar(1024);
 Declare @ComplexValue nvarchar(1024);
 Declare @twOpis int = 1;
 Declare @twKategoria int = 2;
 Declare @twPlanKont int = 3;
 Declare @twSlownik int = 4;
    --add empty value
 insert into  #wartosci(WyyID, SlownikTyp, SlownikId, Value, ComplexKod, ComplexValue, SimpleKod)
 select Top 1 WyyID, NULL, NULL, '', SimpleKod, SimpleKod,SimpleKod from #wymiar where WyyID = @ID and IsNull(ParentId,0)=0;
 Declare wymiarCursor Cursor Local Fast_Forward For Select WyyID, Typ, TypWymiaru, ComplexKod, SimpleKod  From #wymiar
 Open wymiarCursor
 While 1=1
 Begin
  Fetch Next From wymiarCursor InTo @WyyID, @Typ, @TypWymiaru, @ComplexKod, @SimpleKod
  If @@Fetch_Status<>0 Break
  if @TypWymiaru = @twPlanKont
   insert into  #wartosci(WyyID, SlownikTyp, SlownikId, Value, ComplexKod, ComplexValue, SimpleKod, Description1, Description2, Description3)
   select WyyId, SlownikTyp, SlownikId, Value, @ComplexKod, @ComplexKod + '/' + Value, @SimpleKod, Description1, Description2, Description3
   from CDN.WAWartosciSlownika_Konto(@WyyID, @OkresObrachunkowyId);
  else if @TypWymiaru = @twKategoria
   insert into  #wartosci(WyyID, SlownikTyp, SlownikId, Value, ComplexKod, ComplexValue, SimpleKod, Description1, Description2, Description3)
   select WyyId, SlownikTyp, SlownikId, Value, @ComplexKod, @ComplexKod + '/' + Value, @SimpleKod, Description1, Description2, Description3
   from CDN.WAWartosciSlownika_Kategoria(@WyyID);
  else if @TypWymiaru = @twSlownik
   insert into  #wartosci(WyyID, SlownikTyp, SlownikId, Value, ComplexKod, ComplexValue, SimpleKod, Description1, Description2, Description3)
   select WyyId, SlownikTyp, SlownikId, Value, @ComplexKod, @ComplexKod + '/' + Value, @SimpleKod, Description1, Description2, Description3
   from CDN.WAWartosciSlownika_Podmiot(@WyyID);
  else if @TypWymiaru = @twOpis
   insert into  #wartosci(WyyID, SlownikTyp, SlownikId, Value, ComplexKod, ComplexValue, SimpleKod, Description1, Description2, Description3)
   select WyyId, SlownikTyp, SlownikId, Value, @ComplexKod, case when @WyyID<>WyyId then @ComplexKod + '/' + Value else @ComplexKod end, @SimpleKod, Description1, Description2, Description3
   from CDN.WAWartosciSlownika_Opis(@WyyID);
 End
 Close wymiarCursor
 Deallocate wymiarCursor
 drop table #wymiar;
 --update #wartosci Set KeyValue = str(WyyID) + '/' + ComplexValue, ID = Str(WyyId)+'/'+ComplexKod+'/'+Value, ViewValue = case when IsNull(Value, '')='' then '' else ComplexKod+'/'+Value end;
 update #wartosci Set KeyValue = str(WyyID) + '/' + ComplexValue,
      ID = ltrim(Str(WyyId)+'/'+ComplexKod+'/'+Value),
      ViewID = ComplexKod+'/'+Value,
      ViewValue = case when IsNull(Value, '')='' then '' else ComplexKod+'/'+Value end;
 --, ComplexValue = case when IsNull(Value, '')='' then '' else Value end
 select * from #wartosci;
 drop table #wartosci;

CREATE FUNCTION CDN.WAWartosciSlownika_Konto(@WymiarId int, @OkresObrachunkowyId int)
RETURNS @Result TABLE( Id int identity(1,1), WyyId int, SlownikTyp int, SlownikId int, Value nvarchar(255), Description1 nvarchar(255), Description2 nvarchar(255), Description3 nvarchar(255))
AS
BEGIN
 Declare @Numer varchar(50) = NULL;
 Declare @AccID int = NULL;
 Select @Numer = Wyy_KontoNumer from CDN.Wymiary where Wyy_WyyID = @WymiarId;
 Select @AccID = Acc_AccID from CDN.Konta where Acc_Numer = @Numer and Acc_OObId=@OkresObrachunkowyId order by Acc_AccId desc;
  if IsNull(@AccID,0) <> 0
  begin
    WITH Konta AS (
      SELECT Acc_AccId as AccId, Acc_Numer as AccNumer, Acc_Analityka as AccAnalityka, Acc_Nazwa as AccNazwa from CDN.Konta where Acc_NieAktywne=0 and Acc_AccId = @AccID
      UNION ALL
      SELECT A.Acc_AccId, A.Acc_Numer, A.Acc_Analityka, A.Acc_Nazwa from CDN.Konta A join Konta on (Konta.AccId= A.Acc_ParId) where Acc_NieAktywne=0
    )
    insert into @Result(WyyId, SlownikTyp, SlownikId, Value, Description1, Description2, Description3)
    SELECT @WymiarId as WyyId,  0 as SlownikTyp, AccId as SlownikId, AccNumer as Value, AccNazwa, AccNumer, AccNumer
    FROM Konta
    ORDER BY Value
  end
  else
  begin
    WITH Konta AS (
      SELECT Acc_AccId as AccId, Acc_Numer as AccNumer, Acc_Analityka as AccAnalityka, Acc_Nazwa as AccNazwa from CDN.Konta where Acc_NieAktywne=0 and Acc_OObId=@OkresObrachunkowyId and IsNull(Acc_ParId, 0) = 0
      UNION ALL
      SELECT A.Acc_AccId, A.Acc_Numer, A.Acc_Analityka, A.Acc_Nazwa from CDN.Konta A join Konta on (Konta.AccId= A.Acc_ParId) where Acc_NieAktywne=0
    )
    insert into @Result(WyyId, SlownikTyp, SlownikId, Value, Description1, Description2, Description3)
    SELECT @WymiarId as WyyId,  0 as SlownikTyp, AccId as SlownikId, AccNumer as Value, AccNazwa, AccNumer, AccNumer
    FROM Konta
    ORDER BY Value
  end
 return
END

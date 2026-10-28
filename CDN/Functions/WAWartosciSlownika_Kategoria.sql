CREATE FUNCTION CDN.WAWartosciSlownika_Kategoria(@WymiarId int)
RETURNS @Result TABLE( Id int identity(1,1), WyyId int, SlownikTyp int, SlownikId int, Value nvarchar(255), Description1 nvarchar(255), Description2 nvarchar(255), Description3 nvarchar(255))
AS
BEGIN
 Declare @ID int = NULL;
 Select @ID = Wyy_KatId from CDN.Wymiary where Wyy_WyyID = @WymiarId;
  if IsNull(@ID,0) <> 0
  begin
      WITH Kategorie AS (
        SELECT Kat_KatId as KatId, convert(nvarchar(255),Kat_KodSzczegol) as Kod, Kat_Opis as Opis, Kat_KontoSegmentWN as Konto1, Kat_KontoSegmentMA as Konto2 from CDN.Kategorie where Kat_Nieaktywny=0 and Kat_KatId = @ID
        UNION ALL
        SELECT Kat_KatId as KatId, convert(nvarchar(255), Kategorie.Kod+'/'+Kat_KodSzczegol), Kat_Opis, Kat_KontoSegmentWN, Kat_KontoSegmentMA from CDN.Kategorie  A join Kategorie on (Kategorie.KatId= A.Kat_ParentID) where Kat_Nieaktywny=0
      )
      insert into @Result(WyyId, SlownikTyp, SlownikId, Value, Description1, Description2, Description3)
      SELECT @WymiarId as WyyId,  0 as SlownikTyp, KatId as SlownikId, Kod as Value, Opis, Konto1, Konto2
      FROM Kategorie
      ORDER BY Kod
  end
  else
  begin
      declare @hid int = 1;
      WITH Kategorie AS (
        SELECT Kat_KatId as KatId, convert(nvarchar(255),Kat_KodSzczegol) as Kod, Kat_Opis as Opis, Kat_KontoSegmentWN as Konto1, Kat_KontoSegmentMA as Konto2 from CDN.Kategorie where Kat_Nieaktywny=0 and IsNull(Kat_ParentId, 0) = 0
        UNION ALL
        SELECT Kat_KatId as KatId, convert(nvarchar(255), Kategorie.Kod+'/'+Kat_KodSzczegol), Kat_Opis, Kat_KontoSegmentWN, Kat_KontoSegmentMA from CDN.Kategorie  A join Kategorie on (Kategorie.KatId= A.Kat_ParentID) where Kat_Nieaktywny=0
      )
      insert into @Result(WyyId, SlownikTyp, SlownikId, Value, Description1, Description2, Description3)
      SELECT @WymiarId as WyyId,  0 as SlownikTyp, KatId as SlownikId, Kod, Opis as Value, Konto1, Konto2
      FROM Kategorie
      ORDER BY Kod
  end
 return
END

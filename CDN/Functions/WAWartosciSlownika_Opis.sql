CREATE FUNCTION CDN.WAWartosciSlownika_Opis(@WymiarId int)
RETURNS @Result TABLE( Id int identity(1,1), WyyId int, SlownikTyp int, SlownikId int, Value nvarchar(255), Description1 nvarchar(255), Description2 nvarchar(255), Description3 nvarchar(255))
AS
BEGIN
 Declare @ID int = NULL;
 Select @ID = Wyy_WyyID from CDN.Wymiary where Wyy_Aktywny = 1 and Wyy_WyyID = @WymiarId;
 if @ID is Null
  return;
 /*
 declare @hid int = 1;
 WITH Opis AS (
  SELECT @hid as hid, Kat_KatId as KatId, Kat_KodSzczegol as Kod from CDN.Kategorie where Kat_KatId = @ID
  UNION ALL
  SELECT hid+1, Kat_KatId as KatId, Kat_KodSzczegol as Kod from CDN.Kategorie  A join Kategorie on (Kategorie.KatId= A.Kat_ParentID)
 )
 */
 /*
 insert into @Result(WyyId, SlownikTyp, SlownikId, Value)
 SELECT Wyy_WyyID,  Wyy_SlownikTyp, Wyy_SlownikId, Wyy_Kod
 FROM CDN.Wymiary
 where Wyy_Aktywny = 1 and Wyy_WyyID = @WymiarId
 ORDER BY Wyy_Kod;
 */
 insert into @Result(WyyId, SlownikTyp, SlownikId, Value, Description1, Description2, Description3)
 SELECT Wyy_WyyID,  Wyy_SlownikTyp, Wyy_SlownikId, Wyy_Kod, Wyy_Nazwa, Wyy_KontoNumer, Wyy_KontoNumer
 FROM CDN.Wymiary
 where Wyy_Aktywny = 1 and Wyy_ParentID = @WymiarId
 ORDER BY Wyy_Kod;
 return
END

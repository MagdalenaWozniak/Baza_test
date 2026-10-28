CREATE procedure CDN.WAUstawStatusAktywnosci
@ParentWyyId int = 0,
@Wartosc int = 0
As
 WITH Wymiar AS (
  SELECT Wyy_WyyID as WyyID, Wyy_ParentID as ParentID from CDN.Wymiary where Wyy_WyyID = @ParentWyyId
  UNION ALL
  SELECT A.Wyy_WyyID, A.Wyy_ParentID from CDN.Wymiary A join Wymiar on (Wymiar.WyyID = A.Wyy_ParentID)
 )
 update CDN.Wymiary set Wyy_Aktywny = @Wartosc where Wyy_WyyID in (Select WyyID FROM Wymiar where WyyID <> @ParentWyyId);

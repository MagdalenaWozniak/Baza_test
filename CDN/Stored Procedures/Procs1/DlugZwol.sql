CREATE PROCEDURE CDN.DlugZwol @DataOd DATETIME, @DataDo DATETIME, @Szczegol INT, @Guid NVARCHAR(50)
AS
SET NOCOUNT ON
DECLARE @IdPrac INT
DECLARE @Ozn Char(1)
DECLARE @Osoba NVarChar(71)
DECLARE @Kod NVarChar(20)
DECLARE @Okres_Od DATETIME
DECLARE @Okres_Do DATETIME
DECLARE @Kont INT
DECLARE @Dni INT
CREATE TABLE #DlugZwol(
 Tmp_Prcid INT,
 Tmp_Ozn NVarChar(1),
 Tmp_Osoba NVarChar(71),
 Tmp_Akronim NVarChar(20),
 Tmp_Od DATETIME,
 Tmp_Do DATETIME,
 Tmp_Kontynuacja INT,
 Tmp_IloscDni INT
)
DECLARE Tmp_Prac CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
SELECT
 PRI_PraID,
 case pri_nadrzedny when 1 then '+'else case isnull(pri_parentid,0) when 0 then ' ' else '-'end  end,
 case pri_nadrzedny when 1 then pri_nazwisko+' '+ PRI_Imie1 else case isnull(pri_parentid,0) when 0 then pri_nazwisko+' '+ PRI_Imie1 else pri_nazwisko+' '+ PRI_Imie1 end  end,
 PRI_Kod,
 min(Pnb_OkresOd),
 min(Pnb_OkresDo)
 FROM CDN.PracIdx join CDN.PracNieobec on PRI_PraId = PNB_PraId join CDN.TypNieobec on PNB_TnbId = TNB_TnbId
 join CDN.RptZaznaczenia2 on PRI_PraId = RpZ2_GIDNumer
 WHERE RpZ2_GUID = @Guid and PRI_Typ = 1 and TNB_PdzId = 331 and (PNB_Tryb = 0 or PNB_Tryb = 2) and (Pnb_OkresOd between @DataOd and @DataDo
 or Pnb_OkresDo between @DataOd and @DataDo or @DataOd between Pnb_OkresOd and Pnb_OkresDo)
 group by PRI_PraID ,  case pri_nadrzedny when 1 then '+'else case isnull(pri_parentid,0) when 0 then ' ' else '-'end  end,  case pri_nadrzedny when 1 then pri_nazwisko+' '+ PRI_Imie1 else case isnull(pri_parentid,0) when 0 then pri_nazwisko+' '+ PRI_Imie1 else pri_nazwisko+' '+ PRI_Imie1 end  end,PRI_Kod
 OPEN Tmp_Prac
  WHILE 1=1
    BEGIN
      FETCH NEXT FROM Tmp_Prac INTO  @IdPrac, @Ozn, @Osoba,@Kod, @Okres_Od, @Okres_Do
      IF @@FETCH_STATUS <> 0 BREAK
 exec CDN.DlugZwolCalc @IdPrac, @Ozn, @Osoba,@Kod, @Okres_Od, @Okres_Do
    END
 CLOSE Tmp_Prac
 DEALLOCATE Tmp_Prac
 SET NOCOUNT OFF
IF @Szczegol=1
SELECT DISTINCT * FROM #DlugZwol order by Tmp_Osoba, Tmp_Od desc
ELSE
SELECT DISTINCT Tmp_Prcid,Tmp_Ozn,Tmp_Osoba,Tmp_Akronim, min(Tmp_Kontynuacja) as Tmp_Kontynuacja ,min(Tmp_Od) as Tmp_Od,max(Tmp_Do) as Tmp_Do,sum(Tmp_IloscDni) as Tmp_IloscDni  FROM #DlugZwol
group by Tmp_Prcid,Tmp_Ozn,Tmp_Osoba, Tmp_Akronim

CREATE Procedure CDN.AKORD @PrcId INT = 0, @MiesD INT, @RokD INT, @sum INT = 1, @Nazwa NVARCHAR(40) = 'NULL'
As
SET NOCOUNT ON
--Tworze tabele tymczasowa
CREATE TABLE #AKORD(
 Tmp_AK_NAZW NVARCHAR(40),
 Tmp_AK_IMIE NVARCHAR(30),
 Tmp_AK_NAME NVARCHAR(40),
 Tmp_AK_IL DECIMAL (15,4),
 Tmp_AK_JEDN NVARCHAR(40),
 Tmp_AK_CZAS INT,
 Tmp_AK_KWOTA   DECIMAL (15,2),
 Tmp_AK_MIES INT,
 Tmp_AK_ROK INT
)
--Tworze kursor z akordami dla danego pracownika
IF  @sum = 1
BEGIN
DECLARE AkordPracCursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
SELECT
--PRI_Nazwisko,
--PRI_Imie1,
case pri_nadrzedny when 1 then '+ '+pri_nazwisko else case isnull(pri_parentid,0) when 0 then pri_nazwisko else '- '+pri_nazwisko  end  end,
case pri_nadrzedny when 1 then PRI_Imie1+ ' [' + PRI_Kod+']' else case isnull(pri_parentid,0) when 0 then PRI_Imie1+' [' + PRI_Kod+']' else PRI_Imie1+' [' + PRI_Kod+']'  end  end,
AKR_Nazwa, sum(ahw_ilosc), adf_jednostka,
sum(DateDiff(minute, CONVERT(DATETIME, '1899-12-30',120),ahw_czas)),
kwota = (select sum(wps_wartosc) from cdn.wypskladniki
inner join cdn.wyplaty on WPS_WplId = WPL_WplId
 where wps_rodzajzrodla = 18 and wps_zrodloid = akr_akrid and WPL_Tryb<>1 and WPL_Tryb<>2
 and month(wps_datado) = @MiesD and year(wps_datado) = @RokD),
 ahw_miesiac, AHW_rok
 from cdn.pracidx
 join cdn.akordy on PRI_Praid = AKR_Praid
 join cdn.akordyhist on akr_akrid = akh_akrid
 join cdn.akorddefinicja on akh_adfid = adf_adfid
 join cdn.akordyhistwartosci on akh_akhid = ahw_akhid
where akr_praid = @prcId and Pri_typ = 1 and
@MiesD = AHW_Miesiac and @RokD = AHW_Rok and
(AKR_Nazwa = @Nazwa or @Nazwa = 'NULL')
group by PRI_Nazwisko, Pri_Imie1,pri_nadrzedny,pri_parentid,pri_kod, AKR_Nazwa, AKR_akrId, ahw_miesiac, AHW_rok, adf_jednostka
order by AKR_Nazwa
END
ELSE
BEGIN
DECLARE AkordPracCursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
SELECT
case pri_nadrzedny when 1 then '+ '+pri_nazwisko else case isnull(pri_parentid,0) when 0 then pri_nazwisko else '- '+pri_nazwisko  end  end,
case pri_nadrzedny when 1 then PRI_Imie1+ ' [' + PRI_Kod+']' else case isnull(pri_parentid,0) when 0 then PRI_Imie1+' [' + PRI_Kod+']' else PRI_Imie1+' [' + PRI_Kod+']'  end  end,
AKR_Nazwa, sum(ahw_ilosc), adf_jednostka,
sum(DateDiff(minute, CONVERT(DATETIME, '1899-12-30',120),ahw_czas)),
kwota = (select sum(wps_wartosc) from cdn.wypskladniki
 inner join cdn.wyplaty on WPS_WplId = WPL_WplId
 where wps_rodzajzrodla = 18 and wps_zrodloid = akr_akrid and WPL_Tryb<>1 and WPL_Tryb<>2
 and month(wps_datado) = @MiesD and year(wps_datado) = @RokD),
 ahw_miesiac, AHW_rok
 from cdn.pracidx
 join cdn.akordy on PRI_Praid = AKR_Praid
 join cdn.akordyhist on akr_akrid = akh_akrid
 join cdn.akorddefinicja on akh_adfid = adf_adfid
 join cdn.akordyhistwartosci on akh_akhid = ahw_akhid
where Pri_typ = 1 and @MiesD = AHW_Miesiac and @RokD = AHW_Rok and
(AKR_Nazwa = @Nazwa or @Nazwa = 'NULL')
group by PRI_Nazwisko, Pri_Imie1,pri_nadrzedny,pri_parentid,pri_kod, AKR_Nazwa, AKR_akrId, ahw_miesiac, AHW_rok, adf_jednostka
order by AKR_Nazwa
END
OPEN AkordPracCursor
  DECLARE @Nazw NVARCHAR(40)
  DECLARE @Imie NVARCHAR(30)
  DECLARE @NameAk NVARCHAR(40)
  DECLARE @IlAk DECIMAL (15,4)
  DECLARE @JednAk  NVARCHAR(40)
  DECLARE @CzasAk INT
  DECLARE @Kwota DECIMAL (15,2)
  DECLARE @Mies INT
  DECLARE @Rok INT
WHILE 1=1
  BEGIN
    FETCH NEXT FROM AkordPracCursor INTO @Nazw, @Imie, @NameAk, @IlAk, @JednAk, @CzasAk, @Kwota,@Mies, @Rok
    IF @@FETCH_STATUS <> 0 BREAK
    INSERT INTO #Akord
     select @Nazw, @Imie, @NameAk, @IlAk, @JednAk, @CzasAk, @Kwota, @Mies, @Rok
  END
  CLOSE AkordPracCursor
  DEALLOCATE AkordPracCursor
SET NOCOUNT OFF
SELECT
 Tmp_AK_NAZW,
 Tmp_AK_IMIE,
 Tmp_AK_NAME,
 Tmp_AK_IL,
 Tmp_AK_JEDN,
 Tmp_AK_CZAS,
 Tmp_AK_KWOTA,
 Tmp_AK_MIES,
 Tmp_AK_Rok
FROM #AKORD

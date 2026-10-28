CREATE PROCEDURE CDN.CDNDTS_OPDeklaracje  @DataOd DATETIME
AS
SET NOCOUNT OFF
DECLARE @RM INT
DECLARE @R  NVARCHAR(4)
DECLARE @M  NVARCHAR(2)
SET @R = CAST(DATEPART(year ,@DataOd) as NVARCHAR)
SET @M = CAST(DATEPART(month ,@DataOd)  as NVARCHAR)
IF LEN(@M)<2 SET @M='0'+@M
SET @RM = CAST(@R+@M as NVARCHAR)
--
-- Lecę po tabeli deklstr (strony deklaracji)
-- Szukam kwot pracowników
-- Niestety trzeba parsować stringa gdyż jest to wierne odzwierciedlenie pliku KEDU
--
DECLARE @A04  NVARCHAR(10)
DECLARE @A05  NVARCHAR(10)
DECLARE @B04  NVARCHAR(10)
DECLARE @B05  NVARCHAR(10)
DECLARE @C01  NVARCHAR(10)
DECLARE @C02  NVARCHAR(10)
DECLARE @C03  NVARCHAR(10)
DECLARE @D02  NVARCHAR(10)
DECLARE @D05  NVARCHAR(10)
DECLARE @E02  NVARCHAR(10)
DECLARE @E03  NVARCHAR(10)
DECLARE @E04  NVARCHAR(10)
DECLARE @V02  NVARCHAR(10)
DECLARE @V05  NVARCHAR(11)
DECLARE @VI01  NVARCHAR(10)
DECLARE @VI02  NVARCHAR(11)
DECLARE @VII03  NVARCHAR(10)
DECLARE @VII04  NVARCHAR(11)
DECLARE @VIII01 NVARCHAR(10)
DECLARE @VIII02 NVARCHAR(10)
DECLARE @VIII03 NVARCHAR(11)
DECLARE @nA04  DECIMAL(15,2)
DECLARE @nA05  DECIMAL(15,2)
DECLARE @nB04  DECIMAL(15,2)
DECLARE @nB05  DECIMAL(15,2)
DECLARE @nC01  DECIMAL(15,2)
DECLARE @nC02  DECIMAL(15,2)
DECLARE @nC03  DECIMAL(15,2)
DECLARE @nD02  DECIMAL(15,2)
DECLARE @nD05  DECIMAL(15,2)
DECLARE @nE02  DECIMAL(15,2)
DECLARE @nE03  DECIMAL(15,2)
DECLARE @nE04  DECIMAL(15,2)
DECLARE @nV02  DECIMAL(15,2)
DECLARE @nV05  DECIMAL(15,2)
DECLARE @nVI01  DECIMAL(15,2)
DECLARE @nVI02  DECIMAL(15,2)
DECLARE @nVII03  DECIMAL(15,2)
DECLARE @nVII04  DECIMAL(15,2)
DECLARE @nVIII01 DECIMAL(15,2)
DECLARE @nVIII02 DECIMAL(15,2)
DECLARE @nVIII03 DECIMAL(15,2)
DECLARE @nWYP1 DECIMAL(15,2)
DECLARE @nWYP2 DECIMAL(15,2)
DECLARE @CELLSIZE INT
DECLARE @NEWLEN   INT
DECLARE @TEKST NVARCHAR(MAX)
DECLARE @FOUNDTAG INT
DECLARE @TMPIDX   INT
DECLARE @DKNID    INT
DECLARE @DKNRM    INT
SET  @CELLSIZE = 10
SET  @NEWLEN   = 2
DECLARE Tmp_DekKwoty CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
  select dks_tekst, dks_dknid, dkn_rokmiesiac from cdn.deklnag join cdn.deklstr on dkn_dknid=dks_dknid
  where dkn_typdeklar=120 and dkn_rokmiesiac>=@RM and dkn_zablokowana=1
OPEN Tmp_DekKwoty
WHILE 1=1
BEGIN
     FETCH NEXT FROM Tmp_DekKwoty INTO @TEKST, @DKNID, @DKNRM
     IF @@FETCH_STATUS <> 0 BREAK
     delete from cdn.deklelem where dke_dknid = @DKNID
     SET @FOUNDTAG = PATINDEX('%<ZSDRAI>%', @TEKST)
     SET @TMPIDX   = @FOUNDTAG
     IF @TMPIDX>0
     BEGIN
       --Skaczę poza tagi <ZSDRAI>
       SET @TMPIDX = @TMPIDX + 10
       --Wyciągam Kwoty z ZSDRAI sekcja IV
       SET @C01 = SUBSTRING(@TEKST, @TMPIDX+2*@CELLSIZE+2*@NEWLEN, 10 )
       SET @C02 = SUBSTRING(@TEKST, @TMPIDX+5*@CELLSIZE+5*@NEWLEN, 10 )
       SET @C03 = SUBSTRING(@TEKST, @TMPIDX+8*@CELLSIZE+8*@NEWLEN, 10 )
       SET @A04 = SUBSTRING(@TEKST, @TMPIDX+9*@CELLSIZE+9*@NEWLEN, 10 )
       SET @A05 = SUBSTRING(@TEKST, @TMPIDX+12*@CELLSIZE+12*@NEWLEN, 10 )
       SET @B04 = SUBSTRING(@TEKST, @TMPIDX+10*@CELLSIZE+10*@NEWLEN, 10 )
       SET @B05 = SUBSTRING(@TEKST, @TMPIDX+13*@CELLSIZE+13*@NEWLEN, 10 )
       SET @D02 = SUBSTRING(@TEKST, @TMPIDX+21*@CELLSIZE+21*@NEWLEN, 10 )
       SET @D05 = SUBSTRING(@TEKST, @TMPIDX+26*@CELLSIZE+26*@NEWLEN, 10 )
       SET @E02 = SUBSTRING(@TEKST, @TMPIDX+22*@CELLSIZE+22*@NEWLEN, 10 )
       SET @E03 = SUBSTRING(@TEKST, @TMPIDX+24*@CELLSIZE+24*@NEWLEN, 10 )
       SET @E04 = SUBSTRING(@TEKST, @TMPIDX+27*@CELLSIZE+27*@NEWLEN, 10 )
     END
     --Skaczę do sekcji <ZWDRA>
     SET @FOUNDTAG = PATINDEX('%<ZWDRA>%', @TEKST)
     SET @TMPIDX   = @FOUNDTAG
     IF @TMPIDX>0
     BEGIN
        SET @TMPIDX = @TMPIDX + 9
        SET @V02 = SUBSTRING(@TEKST, @TMPIDX+1*@CELLSIZE+1*@NEWLEN, 10 )
        SET @V05 = SUBSTRING(@TEKST, @TMPIDX+4*@CELLSIZE+4*@NEWLEN, 11 )
     END
     --Skaczę do sekcji <RIVDRA>
     SET @FOUNDTAG = PATINDEX('%<RIVDRA>%', @TEKST)
     SET @TMPIDX   = @FOUNDTAG
     IF @TMPIDX>0
     BEGIN
        SET @TMPIDX = @TMPIDX + 10
        SET @VI01 = SUBSTRING(@TEKST, @TMPIDX, 11 )
        SET @VI02 = SUBSTRING(@TEKST, @TMPIDX+11+1*@NEWLEN, 11 )
     END
     --Skaczę do sekcji <ZSDRA>
     SET @FOUNDTAG = PATINDEX('%<ZSDRA>%', @TEKST)
     SET @TMPIDX   = @FOUNDTAG
     IF @TMPIDX>0
     BEGIN
        SET @TMPIDX = @TMPIDX + 9
        SET @VII03 = SUBSTRING(@TEKST, @TMPIDX+2*@CELLSIZE+2*@NEWLEN, 10 )
        SET @VII04 = SUBSTRING(@TEKST, @TMPIDX+3*@CELLSIZE+3*@NEWLEN, 11 )
     END
     --Skaczę do sekcji <ZDRAV>
     SET @FOUNDTAG = PATINDEX('%<ZDRAV>%', @TEKST)
     SET @TMPIDX   = @FOUNDTAG
     IF @TMPIDX>0
     BEGIN
        SET @TMPIDX = @TMPIDX + 9
        SET @VIII01 = SUBSTRING(@TEKST, @TMPIDX, 10 )
        SET @VIII02 = SUBSTRING(@TEKST, @TMPIDX+1*@CELLSIZE+1*@NEWLEN, 10 )
        SET @VIII03 = SUBSTRING(@TEKST, @TMPIDX+2*@CELLSIZE+2*@NEWLEN, 11 )
     END
     --Obliczam brakujące kwoty, których nie da się wyciągnąć z deklaracji
     SET @nWYP1 = (select isnull(sum(wpe_sklemerprac),0) from cdn.wyplaty join cdn.wypelementy on wpe_wplid = wpl_wplid
 where wpe_tyub = 12000 and wpl_rok = cast (@R as int) and wpl_miesiac=cast (@M as int))
     SET @nWYP2 = (select isnull(sum(wpe_sklrentprac),0) from cdn.wyplaty join cdn.wypelementy on wpe_wplid = wpl_wplid
 where wpe_tyub = 12000 and wpl_rok = cast (@R as int) and wpl_miesiac=cast (@M as int))
     --Konwertuję kwoty ze stringów
     exec CDN.CDNDeklKwota @C01, @nC01 output
     exec CDN.CDNDeklKwota @C02, @nC02 output
     exec CDN.CDNDeklKwota @C03, @nC03 output
     exec CDN.CDNDeklKwota @A04, @nA04 output
     exec CDN.CDNDeklKwota @A05, @nA05 output
     exec CDN.CDNDeklKwota @B04, @nB04 output
     exec CDN.CDNDeklKwota @B05, @nB05 output
     exec CDN.CDNDeklKwota @D02, @nD02 output
     exec CDN.CDNDeklKwota @D05, @nD05 output
     exec CDN.CDNDeklKwota @E02, @nE02 output
     exec CDN.CDNDeklKwota @E03, @nE03 output
     exec CDN.CDNDeklKwota @E04, @nE04 output
     exec CDN.CDNDeklKwota @V02, @nV02 output
     exec CDN.CDNDeklKwota @V05, @nV05 output
     exec CDN.CDNDeklKwota @VI01, @nVI01 output
     exec CDN.CDNDeklKwota @VI02, @nVI02 output
     exec CDN.CDNDeklKwota @VII03, @nVII03 output
     exec CDN.CDNDeklKwota @VII04, @nVII04 output
     exec CDN.CDNDeklKwota @VIII01, @nVIII01 output
     exec CDN.CDNDeklKwota @VIII02, @nVIII02 output
     exec CDN.CDNDeklKwota @VIII03, @nVIII03 output
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (1, @nC01, 1, 'Suma kwot składek na ubezpieczenia emerytalne i rentowe', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (2, @nC02, 1, 'Suma kwot składek emerytalnych i rentowych - finansowane przez ubezpieczonych', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (3, @nC03, 1, 'Suma kwot składek emerytalnych i rentowych - finansowane przez budżet Państwa', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (4, @nA04, 1, 'Kwota składki na ubezpieczenie emerytalne - finansowane przez budżet Państwa', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (5, @nA05, 1, 'Kwota składki na ubezpieczenie emerytalne - finansowane przez PFRON', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (6, @nB04, 1, 'Kwota składki na ubezpieczenie rentowe - finansowane przez budżet Państwa', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (7, @nB05, 1, 'Kwota składki na ubezpieczenie rentowe - finansowane przez PFRON', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (8, @nD02, 1, 'Kwota składki na ubezpieczenie chorobowe - finansowane przez ubezpieczonych', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (9, @nD05, 1, 'Kwota składki na ubezpieczenie chorobowe - finansowane przez PFRON', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (10, @nE02, 1, 'Kwota składki na ubezpieczenie wypadkowe - finansowane przez ubezpieczonych', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (11, @nE03, 1, 'Kwota składki na ubezpieczenie wypadkowe - finansowane przez płatnika', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (12, @nE04, 1, 'Kwota składki na ubezpieczenie wypadkowe - finansowane przez PFRON', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (13, @nV02, 1, 'Kwota wynagrodzenia należnego płatnikowi od wypłaconych świadczeń z ubezpieczenia chorobowego', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (14, @nV05, 1, 'Łączna kwota świadczeń do potrącenia', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (15, @nVI01, 1, 'Kwota do zwrotu przez ZUS', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (16, @nVI02, 1, 'Kwota do zapłaty', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (17, @nVII03, 1, 'Kwota należnego wnagrodzenia dla płatnika', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (18, @nVII04, 1, 'Kwota do zapłaty', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (19, @nVIII01, 1, 'Kwota należnych składek na FP', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (20, @nVIII02, 1, 'Kwota należnych składek na FGŚP', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (21, @nVIII03, 1, 'Kwota do zapłaty', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (22, @nWYP1, 1, 'Składki emerytalne', @DKNID, '')
     insert into cdn.deklelem (DKE_Numer, DKE_WartoscL, DKE_WartoscM, DKE_Opis,DKE_DKNID, DKE_WartoscTekst) values
     (23, @nWYP2, 1, 'Składki rentowe', @DKNID, '')
END
CLOSE Tmp_DekKwoty
DEALLOCATE Tmp_DekKwoty

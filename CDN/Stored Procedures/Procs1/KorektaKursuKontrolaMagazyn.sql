Create PROCEDURE [CDN].[KorektaKursuKontrolaMagazyn]
@DokId int,
@OpeZmianyOffLine int
AS
 SET NOCOUNT ON
Declare
@TypSkoj int,
@Typ int,
@Numer nvarchar(40),
@Komunikat nvarchar(256)
select @Typ = TrN_TypDokumentu from cdn.tranag where trn_trnid = @DokId
if (@Typ = 302)
set @TypSkoj = 306
else if (@Typ = 301)
set @TypSkoj = 307
else
return
select @Numer = ''
  SELECT TOP 1 @Numer = isnull(TrN_NumerPelny,'') FROM CDN.TraNag WHERE TrN_ZwrId in  (select trr_trnid from cdn.tranagrelacje where TrR_FaId = @DokId and TrR_FaTyp = @Typ and TrR_TrNTyp = @TypSkoj ) AND TrN_Bufor != -1 AND TrN_Rodzaj not in (306061,306071,306072)
  IF(@Numer != '')
  BEGIN
      set @Komunikat = '##OPT32930##%%s1%%=' + @Numer+ '##'-- 'Do dokumentu powiązanego istnieje korekta ' + @Numer+ '.'
   RAISERROR(@Komunikat, 16, 1)
   RETURN
  END
  select @Numer = ''
  SELECT TOP 1 @Numer = isnull(TrN_NumerPelny,'') FROM CDN.Tranag WHERE trn_trnid  in  (select trr_trnid from cdn.tranagrelacje where trr_faid = @DokId and trr_fatyp = @Typ and TrR_TrNTyp = @TypSkoj ) AND   (Trn_DekId Is NOT Null  OR TrN_PreDekID Is NOT Null OR TrN_VaNId Is NOT Null )
  IF(@Numer != '')
  BEGIN
      set @Komunikat = '##OPT34423##%%s1%%=' + @Numer+ '##'--'Dokument powiązany (' + @Numer+ ') jest zaksięgowany.'
   RAISERROR(@Komunikat, 16, 1)
   RETURN
  END
  select @Numer = ''
  if (@OpeZmianyOffLine =0)
  select TOP 1 @Numer = isnull(TrN_NumerPelny,'')  from cdn.tranagrelacje
  left join cdn.TraNag on trn_trnid = trr_trnid
  where trr_faid = @DokId and trr_fatyp = @Typ and TrR_TrNTyp = @TypSkoj  and isnull(trn_TS_export,0) >0
  IF(@Numer != '')
  BEGIN
      set @Komunikat = '##OPT34424##%%s1%%=' + @Numer+ '##'--'Dokument powiązany (' + @Numer+ ') został wyeksportowany.'
   RAISERROR(@Komunikat, 16, 1)
   RETURN
  END
 SET NOCOUNT OFF

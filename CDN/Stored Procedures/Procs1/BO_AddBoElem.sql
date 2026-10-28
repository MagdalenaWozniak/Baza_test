CREATE PROCEDURE CDN.BO_AddBoElem
@BONID    int,
@DataDokumentu datetime,
@AccID   int,
@AccPrevID     int,
@KwotaWn  decimal(15,2),
@KwotaMa  decimal(15,2),
@KwotaWnWal     decimal(15,2),
@KwotaMaWal     decimal(15,2),
@Waluta         NVARCHAR(3)
AS
 SET NOCOUNT ON
 declare @BOEID int  -- result
 declare @KursNumer   int
 declare @KursL     decimal(15,4)
 declare @KursM     decimal(5,0)
 declare @FPlID     int
 --select @DataDokumentu = BON_DataDok from CDN.BONag where BON_BONID = @BONID
 select top 1 @FPlID = FPl_FPlId from CDN.FormyPlatnosci where FPl_NieAktywny=0 order by FPl_FPlId asc
 if @Waluta = ''
  begin
   set @KursNumer = 2 -- kurs podstawowy
   set @KursL   = 1.0000
   set @KursM   = 1
  end
 else
  begin
   set @KursNumer = -1 -- kurs nieokreślony
   set @KursL   = 0.0000
   set @KursM   = 0
  end
 insert into CDN.BOElem
 (
  BOE_BONId,
  BOE_AccId,
  BOE_AccPrevId,
  BOE_KwotaWn,
  BOE_KwotaMa,
  BOE_KwotaWnWal,
  BOE_KwotaMaWal,
  BOE_Waluta,
  BOE_KursNumer,
  BOE_KursL,
  BOE_KursM,
  BOE_Platnosci,
  BOE_FPlID,
  BOE_Termin,
  BOE_DataDok,
  BOE_Dokument,
  BOE_DataKur,
  BOE_Rozrachunki,
  BOE_TerminRoz
 )
 values
 (
  @BONID,
  @AccID,
  @AccPrevID,
  @KwotaWn,
  @KwotaMa,
  @KwotaWnWal,
  @KwotaMaWal,
  @Waluta,
  @KursNumer,
  @KursL,
  @KursM,
  0,        -- BOE_Platnosci
  @FPlID,
  @DataDokumentu,
  @DataDokumentu,
  '',        -- BOE_Dokument
  @DataDokumentu,     -- BOE_DataKur
  0,        -- BOE_Rozrachunki
  @DataDokumentu     -- BOE_TerminRoz
 )
 SET NOCOUNT OFF

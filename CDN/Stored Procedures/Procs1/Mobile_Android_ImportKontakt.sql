CREATE PROCEDURE [CDN].[Mobile_Android_ImportKontakt]
 @Id int ,
 @OptimaId int OUTPUT,
 @StanDetalID int,
 @OpeID int,
 @Status int,
 @Tytul nvarchar(max),
 @Lokalizacja nvarchar(max),
 @KntId int,
 @PrzedstawicielId int,
 @Czastrwania int,
 @typ tinyint,
 @datadok  nvarchar(40),
 @datado nvarchar(40),
 @opis nvarchar(max),
 @Uwagidorealizacji nvarchar(max)
AS
BEGIN
SET NOCOUNT ON
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeID, @OpeModKod OUT, @OpeModNazwisko OUT
declare
@OpisNew    NVARCHAR(255),
@PrzedstNazwisko  NVARCHAR(40),
@DDF_Numeracja   NVARCHAR(50),
@DDF_NumeracjaPelna  NVARCHAR(50),
@DDF_Symbol    NVARCHAR(20),
@Seria     NVARCHAR(20),
@NumerZero    NVARCHAR (6),
@Number     INT,
@DDfId     INT,
@dataod1                 datetime,
@datado1     datetime
select @dataod1 = convert(datetime,@datadok,120)
select @datado1 = convert(datetime,@datado,120)
select @PrzedstNazwisko = KnO_Nazwisko from cdn.KntOsoby where KnO_KnOId = @PrzedstawicielId
select @NumerZero = '000000'
select @OpisNew = substring(@opis,1,255)
--if LEN(@Lokalizacja)>0 and LEN(@OpisNew)< 255
--select @OpisNew = substring(@OpisNew,1,254)+' ' + substring(@Lokalizacja,1,255 - LEN(@OpisNew))
--if LEN(@Uwagidorealizacji)>0 and LEN(@OpisNew)< 255
--select @OpisNew = substring(@OpisNew,1,254)+' ' + substring(@Uwagidorealizacji,1,255 - LEN(@OpisNew))
set @Czastrwania = datediff(minute,@dataod1, @datado1)
 select @DDf_Numeracja = DDf_Numeracja,@DDf_Symbol = DDf_Symbol, @Seria = DSta_Seria,@DDfId = DSta_DDfIdCRM from cdn.detalstanowiska
 join cdn.dokdefinicje on  DDf_DDfId = DSta_DDfIdCRM
 where dsta_dstaid = @StanDetalID
if ISNULL(@OptimaId,0) = 0
begin
if @DDf_Numeracja is null
 begin
   --RAISERROR( 'Brak schematu numeracji dla CRM', 16, 1)
   EXEC CDN.RaiseOptimaException 34168
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
 end
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@symbol' , @DDF_Symbol  )
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@rejestr', @Seria)
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@brak/'  , ''       )
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '/@brak'  , ''       )
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@rok_kal', datepart(yy,@dataod1)  )
  if datepart(m,@dataod1) < 10
 SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@miesiac', '0'+ convert(varchar(3),datepart(m,@dataod1)) )
  else
 SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@miesiac', datepart(m,@dataod1) )
select @Number = ISNULL(max(CRK_NumerNr),0) from CDN.CRMKontakty where CRK_NumerString = @DDF_Numeracja
  --SET  @DDF_NumeracjaPelna  = REPLACE ( @DDF_Numeracja, '@numerS', @Number )
  --SET  @DDF_NumeracjaPelna  = REPLACE ( @DDF_NumeracjaPelna, '@numer', substring(@NumerZero,1,6-len(@Number)) + convert(NVARCHAR(6),@Number) )
INSERT INTO CDN.CRMKontakty
           (CRK_WatekId
           ,CRK_ParId
           ,CRK_DDfId
           ,CRK_NumerString
           ,CRK_NumerNr
           ,CRK_Anulowany
           ,CRK_Bufor
           ,CRK_PodmiotTyp
           ,CRK_PodID
           ,CRK_OsobaId
           ,CRK_OsobaNazwisko
           ,CRK_OpiekunTyp
           ,CRK_OpiekunId
           ,CRK_Obsluga
           ,CRK_DataDok
           ,CRK_CzasPrzygot
           ,CRK_CzasKontaktu
           ,CRK_CzasOpracow
           ,CRK_Zadanie
           ,CRK_TerminOd
           ,CRK_TerminDo
           ,CRK_Przypomnienie
           ,CRK_CzasPrzypomnienia
           ,CRK_Priorytet
           ,CRK_Wykonano
           ,CRK_EtapRealizacji
           ,CRK_Temat
           ,CRK_Opis
           ,CRK_Lokalizacja
           ,CRK_OpeZalID
     ,CRK_OpeZalKod
     ,CRK_OpeZalNazwisko
           ,CRK_StaZalId
           ,CRK_TS_Zal
           ,CRK_OpeModID
     ,CRK_OpeModKod
     ,CRK_OpeModNazwisko
           ,CRK_StaModId
           ,CRK_TS_Mod
           ,CRK_StanowiskoID
           ,CRK_DokID)
     VALUES
           (1
           ,NULL
           ,@DDfId
           ,@DDF_Numeracja
           ,@Number+1
           ,case when @Status = 2 then -2147483647 else 0 end
           ,CASE WHEN @Status = 0 THEN 1 ELSE CASE WHEN @Status = 2 THEN -1 ELSE 0 END END
           ,1
           ,@KntId
           ,case when @PrzedstawicielId = 0 then null else @PrzedstawicielId end
           ,ISNULL(@PrzedstNazwisko,'')
           ,8
           ,@OpeID
           ,0
           ,@dataod1
           ,convert(datetime,'1899-12-30 00:00:00.000',120)
           , dateadd( minute, @Czastrwania,convert(datetime,'1899-12-30 00:00:00.000',120) )--datediff(second,dataod1, @datado1)
           ,convert(datetime,'1899-12-30 00:00:00.000',120)
           ,case when @typ = 4 then 1 else 0 end
           ,@dataod1
           ,@datado1
           ,0
           ,@dataod1
           ,1
           ,0.00
           ,NULL
           ,substring(@Tytul,1,255)
           ,@OpisNew
           ,''
           ,@OpeID
     ,@OpeModKod
     ,@OpeModNazwisko
           ,NULL
           ,GETDATE()
           ,@OpeID
     ,@OpeModKod
     ,@OpeModNazwisko
           ,NULL
           ,GETDATE()
           ,@StanDetalID
           ,@Id)
 declare @IDCRK int, @akronim nvarchar(20), @nazwisko nvarchar(255), @opiekunTyp int,  @opiekunId  int
 select @IDCRK = crk_CrKId from CDN.CRMKontakty where CRK_NumerString = @DDF_Numeracja and CRK_NumerNr = @Number+1
 SET @OptimaId = @IDCRK
 DECLARE @result table (opis nvarchar(50), akronim nvarchar(20), nazwisko nvarchar(255))
 INSERT INTO @result exec  CDN.GetDaneOpiekuna 8, @OpeID
 SELECT TOP 1 @akronim = akronim, @nazwisko = nazwisko from @result
    INSERT INTO [CDN].[CrmUczestnicy]
           ([CrU_CrKId]
           ,[CrU_PodmiotTyp]
           ,[CrU_PodmiotId]
           ,[CrU_Organizator]
           ,[CrU_Akronim]
           ,[CrU_Nazwisko])
    VALUES
           (@IDCRK
           ,8
           ,@OpeID
           ,1
           ,@akronim
           ,@nazwisko)
end
else
update CDN.CRMKontakty
set
           CRK_Anulowany = case when @Status = 2 then -2147483647 else 0 end
           ,CRK_Bufor = CASE WHEN @Status = 0 THEN 1 ELSE CASE WHEN @Status = 2 THEN -1 ELSE 0 END END
           ,CRK_PodID = @KntId
           ,CRK_OsobaId = case when @PrzedstawicielId = 0 then null else @PrzedstawicielId end
           ,CRK_OsobaNazwisko = ISNULL(@PrzedstNazwisko,'')
           ,CRK_DataDok = @dataod1
           ,CRK_CzasKontaktu = dateadd( minute, @Czastrwania,convert(datetime,'1899-12-30 00:00:00.000',120) )--dateadd( second, datediff(second,dataod1, @datado1),'1899-12-30 00:00:00.000')
           ,CRK_Zadanie = case when @typ = 4 then 1 else 0 end
           ,CRK_TerminOd = @dataod1
           ,CRK_TerminDo = @datado1
           ,CRK_Temat = substring(@Tytul,1,255)
           ,CRK_Opis = @OpisNew
           ,CRK_TS_Mod = GETDATE()
           ,CRK_StanowiskoID = @StanDetalID
           ,CRK_DokID = @Id
where CRK_CRKId= @OptimaId
SET NOCOUNT OFF
END

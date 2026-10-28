CREATE PROCEDURE [CDN].[Ankieta_AddNew]
 @id    int OUTPUT
 ,@opeID   int
 ,@stanowiskoId  int
 ,@seriaDok   nvarchar(20)
 ,@dataDok   datetime
 ,@stanAnkiety  int
 ,@przyczynaOdrzucenia nvarchar(512)
 ,@idWzorcaAnkiety   int
 ,@nazwaAnkiety  nvarchar(512)
 ,@opis    nvarchar(max)
 ,@podmiotTyp  int
 ,@podmiotId  int
 ,@osobaId   int
 ,@osobaTelefon  varchar(20)
 ,@osobaNazwisko nvarchar(40)
 ,@terminOd   datetime
 ,@terminDo   datetime
 ,@ocena   decimal(15,2)
 ,@dataWypelnienia datetime
 ,@dataZatwierdzenia datetime
 ,@crmId   int
 ,@fromMobile  int
AS
BEGIN
 SET NOCOUNT ON
 DECLARE @opeKod varchar(20), @opeNazwisko nvarchar(50)
 EXEC CDN.OpeKodNazwisko @opeID, @opeKod OUT, @opeNazwisko OUT
 DECLARE @DDF_Numeracja   NVARCHAR(50),
   @DDF_NumeracjaPelna  NVARCHAR(50),
   @DDF_Symbol    NVARCHAR(20),
   @SeriaOpe    INT,
   @Seria     NVARCHAR(20),
   @RejestrOperatora  NVARCHAR(20),
   @Number     INT,
   @DDfId     INT
 SELECT @DDfId = Convert(int, IsNull(Fir_Wartosc, 0)) FROM cdn.Firma WHERE Fir_Numer = 2268 --'%ankiet%'
 IF @DDfId is NULL OR @DDfId = 0
 BEGIN
  --RAISERROR( 'Brak schematu numeracji dla Ankiet', 16, 1)
  EXEC CDN.RaiseOptimaException 32767
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
 SET @Seria = @seriaDok
 SET @RejestrOperatora = ''
 SELECT @DDf_Numeracja = DDf_Numeracja, @DDf_Symbol = DDf_Symbol, @SeriaOpe = DDf_SeriaOperatora FROM cdn.DokDefinicje WHERE DDf_DDfID = @DDfId
 IF @DDf_Numeracja IS NULL
 BEGIN
  --RAISERROR( 'Brak schematu numeracji dla Ankiet', 16, 1)
  EXEC CDN.RaiseOptimaException 32767
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
 END
 IF @SeriaOpe = 1 AND LEN(LTRIM(RTRIM(@Seria))) = 0
 BEGIN
  DECLARE @ServerCfgString  NVARCHAR(512), @BazaCfgString NVARCHAR(512)
  SELECT @ServerCfgString = sys_wartosc FROM cdn.Systemcdn WHERE sys_id = 1001
  SELECT @BazaCfgString = sys_wartosc FROM cdn.Systemcdn WHERE sys_id = 1002
  EXEC CDN.SeriaOperatora @ServerCfgString, @BazaCfgString, @OpeID, @Seria OUTPUT, @RejestrOperatora OUTPUT
  SET @Seria = ISNULL(@Seria, '')
 END
 SET @DDF_Numeracja = REPLACE ( @DDF_Numeracja, '@symbol' , @DDF_Symbol  )
 SET @DDF_Numeracja = REPLACE ( @DDF_Numeracja, '@rejestr', @Seria)
 SET @DDF_Numeracja = REPLACE ( @DDF_Numeracja, '@brak/'  , ''       )
 SET @DDF_Numeracja = REPLACE ( @DDF_Numeracja, '/@brak'  , ''       )
 SET @DDF_Numeracja = REPLACE ( @DDF_Numeracja, '@rok_kal', datepart(yy,@dataDok)  )
 IF datepart(m,@datadok) < 10
  SET @DDF_Numeracja = REPLACE ( @DDF_Numeracja, '@miesiac', '0'+ convert(varchar(3),datepart(m, @datadok)) )
 ELSE
  SET @DDF_Numeracja = REPLACE ( @DDF_Numeracja, '@miesiac', datepart(m, @datadok) )
 SELECT @Number = ISNULL(max(AnkAnN_NumerNr),0) FROM CDN.AnkAnkietyNag WHERE AnkAnN_NumerString = @DDF_Numeracja
 IF @terminOd IS NULL SET @terminOd = cdn.DateOnly(@dataDok)
 IF @terminDo IS NULL SET @terminDo = @terminOd
 INSERT INTO [CDN].[AnkAnkietyNag]
        ([AnkAnN_DDfId]
        ,[AnkAnN_NumerString]
        ,[AnkAnN_NumerNr]
        ,[AnkAnN_DataDok]
        ,[AnkAnN_Stan]
        ,[AnkAnN_PrzyczynaOdrzucenia]
        ,[AnkAnN_AnkWaNId]
        ,[AnkAnN_Nazwa]
        ,[AnkAnN_Opis]
        ,[AnkAnN_PodmiotTyp]
        ,[AnkAnN_PodID]
        ,[AnkAnN_OsobaId]
        ,[AnkAnN_OsobaTelefon]
        ,[AnkAnN_OsobaNazwisko]
        ,[AnkAnN_TerminOd]
        ,[AnkAnN_TerminDo]
        ,[AnkAnN_Ocena]
        ,[AnkAnN_DataWypelnienia]
        ,[AnkAnN_DataZatwierdzenia]
        ,[AnkAnN_Eksport]
        ,[AnkAnN_OpeZalID]
        ,[AnkAnN_StaZalId]
        ,[AnkAnN_TS_Zal]
        ,[AnkAnN_OpeModID]
        ,[AnkAnN_StaModId]
        ,[AnkAnN_TS_Mod]
        ,[AnkAnN_OpeModKod]
        ,[AnkAnN_OpeModNazwisko]
        ,[AnkAnN_OpeZalKod]
        ,[AnkAnN_OpeZalNazwisko])
    VALUES
        (
        @DDfId
        ,@DDF_Numeracja
        ,@Number+1
  ,@dataDok
  ,@stanAnkiety
  ,@przyczynaOdrzucenia
  ,@idWzorcaAnkiety
        ,@nazwaAnkiety
        ,@opis
        ,@podmiotTyp
        ,@podmiotId
        ,@osobaId
        ,@osobaTelefon
        ,@osobaNazwisko
        ,@terminOd
        ,@terminDo
        ,@ocena
        ,@dataWypelnienia
        ,@dataZatwierdzenia
  ,@fromMobile
        ,@opeId
        ,@stanowiskoId
        ,@dataDok
        ,@opeId
        ,@stanowiskoId
        ,@dataDok
        ,@opeKod
        ,@opeNazwisko
        ,@opeKod
        ,@opeNazwisko)
 SET @id = SCOPE_IDENTITY()
 -- dodaj ankietera
 INSERT INTO [CDN].[AnkAnkietyAnkieterzy]
           ([AnkAaA_AnkAnNId]
           ,[AnkAaA_Lp]
           ,[AnkAaA_PodmiotTyp]
           ,[AnkAaA_PodID])
    VALUES
           (@id
           ,1
           ,8
           ,@opeId)
 -- przenieś pytania ze wzorca
 INSERT INTO [CDN].[AnkAnkietyPyt]
           ([AnkAnP_AnkAnNId]
           ,[AnkAnP_Lp]
           ,[AnkAnP_Tresc]
           ,[AnkAnP_Opis]
           ,[AnkAnP_TypPytania]
           ,[AnkAnP_FormatPytOtwartego]
           ,[AnkAnP_WielokrotnyWybor]
           ,[AnkAnP_AnkSonId]
           ,[AnkAnP_Waga]
           ,[AnkAnP_OdpWymagana]
           ,[AnkAnP_Nieaktywne]
           ,[AnkAnP_WypelniajacyTyp]
           ,[AnkAnP_WypelniajacyId]
           ,[AnkAnP_AnkSpId]
           ,[AnkAnP_AnkGpId]
           ,[AnkAnP_GpTreeId]
           ,[AnkAnP_GpParentId]
           ,[AnkAnP_GpParentLp]
           ,[AnkAnP_PunktyZaOdp])
  SELECT @id
     ,AnkWaP_Lp
           ,AnkWaP_Tresc
           ,AnkWaP_Opis
           ,AnkWaP_TypPytania
           ,AnkWaP_FormatPytOtwartego
           ,AnkWaP_WielokrotnyWybor
           ,AnkWaP_AnkSonId
           ,AnkWaP_Waga
           ,AnkWaP_OdpWymagana
           ,AnkWaP_Nieaktywne
           ,8
           ,@opeId
           ,AnkWaP_AnkSpId
           ,AnkWaP_AnkGpId
           ,AnkWaP_GpTreeId
           ,AnkWaP_GpParentId
           ,AnkWaP_GpParentLp
           ,0
  FROM [CDN].AnkWzorzecAnkietyPyt WHERE AnkWaP_AnkWaNId = @idWzorcaAnkiety
  -- przenieś odpowiedzi
  INSERT INTO [CDN].[AnkAnkietyOdp]
           ([AnkAnO_AnkAnPId]
           ,[AnkAnO_Lp]
           ,[AnkAnO_Mode]
           ,[AnkAnO_Punkty]
           ,[AnkAnO_Wartosc]
           ,[AnkAnO_AnkSpOId])
  SELECT
            [AnkAnP_AnkAnPId]
           ,[AnkSpO_Lp]
           ,[AnkSpO_Mode]
           ,[AnkSpO_Punkty]
           ,[AnkSpO_Wartosc]
           ,[AnkSpO_AnkSpOId]
   FROM [CDN].[AnkAnkietyPyt]
   JOIN [CDN].[AnkSlownikPytanOdp] ON AnkSpO_AnkSpId = AnkAnP_AnkSpId
   WHERE [AnkAnP_AnkAnNId] = @id
 IF @crmId IS NOT NULL BEGIN EXEC CDN.ZapiszDokRelacjeCore 700, @crmId, 710, @id, 255 END
 EXEC CDN.ZapiszDokRelacjeCore 714, @idWzorcaAnkiety, 710, @id, 255
 DECLARE @numerPelny NVARCHAR(30), @opisRO NVARCHAR(200)
 SELECT TOP 1 @numerPelny = AnkAnN_NumerPelny FROM cdn.[AnkAnkietyNag] WHERE AnkAnN_AnkAnNId = @id
 SET @opisRO = N'Dodano skryptem SQL'
 IF @fromMobile > 0
 BEGIN
  SET @opisRO = N'Import z Mobile'
 END
    EXEC  CDN.RejestrOperacjiContextInfo @opeID
 EXEC [CDN].[RejestrOperacjiDodaj]  @ObiektTyp  = 710,
          @ObiektSubTyp = 0,
          @ObiektID  = @id,
          @ObiektNazwa = @numerPelny,
          @OperacjaTyp = 1,
          @Opis   = @opisRO
 SET NOCOUNT OFF
END

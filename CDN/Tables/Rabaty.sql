CREATE TABLE [CDN].[Rabaty] (
    [Rab_RabId]       INT             IDENTITY (1, 1) NOT NULL,
    [Rab_Typ]         SMALLINT        NOT NULL,
    [Rab_TypCenyNB]   TINYINT         NOT NULL,
    [Rab_TwrId]       INT             NULL,
    [Rab_PodmiotTyp]  SMALLINT        NULL,
    [Rab_PodmiotId]   INT             NULL,
    [Rab_Rabat]       DECIMAL (5, 2)  NOT NULL,
    [Rab_RabatISklep] DECIMAL (5, 2)  CONSTRAINT [DF_Rab_RabatISklep] DEFAULT ((0.00)) NOT NULL,
    [Rab_Cena]        DECIMAL (17, 4) NOT NULL,
    [Rab_Waluta]      VARCHAR (3)     NOT NULL,
    [Rab_Opis]        NVARCHAR (254)  NOT NULL,
    CONSTRAINT [Rab_Primary] PRIMARY KEY CLUSTERED ([Rab_RabId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [RabTowar]
    ON [CDN].[Rabaty]([Rab_TwrId] ASC, [Rab_Typ] ASC, [Rab_PodmiotTyp] ASC, [Rab_PodmiotId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [RabPodmiot]
    ON [CDN].[Rabaty]([Rab_PodmiotId] ASC, [Rab_PodmiotTyp] ASC, [Rab_Typ] ASC, [Rab_TwrId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER [CDN].[RO_Rabaty_InsertUpdateDelete_Trigger]
  ON [CDN].[Rabaty]
  FOR INSERT, UPDATE, DELETE
AS
  SET NOCOUNT ON
  DECLARE
  @Rab_RabID INT,
  @Rab_Typ INT,
  @Rab_Nazwa NVARCHAR(254),
  @Twr_kod NVARCHAR(254),
  @Pod_Kod NVARCHAR(254),
  @Gru_Nazwa NVARCHAR(254),
  @TwG_Kod NVARCHAR(254)
  DECLARE
  @TypOperacji INT
  DECLARE Dodane Cursor Local Fast_Forward For
  SELECT
  Rab_RabID,
  Rab_Typ,
  LTRIM(RTRIM(Twr_kod)), LTRIM(RTRIM(Pod_Kod)),LTRIM(RTRIM(Gru_Nazwa)),LTRIM(RTRIM(TwG_Kod))
  FROM inserted
left join CDN.PodmiotyView on  Pod_PodId = Rab_PodmiotId and Pod_PodmiotTyp = Rab_PodmiotTyp
left join CDN.Grupy on  Gru_GruId = Rab_Podmiotid
left join CDN.TwrGrupy on  TwG_GIDNumer = Rab_TwrId and TwG_GIDTyp = -16
left join CDN.Towary on  Twr_twrid = Rab_TwrId
  Open Dodane
  While 1=1
  BEGIN
  Fetch Next From Dodane Into
   @Rab_RabID,
   @Rab_Typ,
   @Twr_kod,
   @Pod_Kod,
   @Gru_Nazwa,
   @TwG_Kod
  If @@Fetch_Status <> 0 Break
 IF EXISTS(select * from deleted where deleted.Rab_RabID = @Rab_RabID)
   BEGIN
  SET @TypOperacji = 2
   END
   ELSE -- dodany
  SET @TypOperacji = 1
select @Rab_Nazwa =
    case when @Rab_Typ = 1 then 'Grupa kontrahenta ('+@Gru_Nazwa +') - wszystkie towary'
   when @Rab_Typ = 2 then 'Jeden kontrahent ('+@Pod_Kod +') - wszystkie towary'
   when @Rab_Typ = 3 then 'Grupa kontrahenta ('+@Gru_Nazwa +') - grupa towarowa ('+@TwG_Kod +')'
   when @Rab_Typ = 4 then 'Grupa kontrahenta ('+@Gru_Nazwa +') - jeden towar ('+@Twr_kod +')'
   when @Rab_Typ = 5 then 'Jeden kontrahent ('+@Pod_Kod +') - grupa towarowa ('+@TwG_Kod +')'
   when @Rab_Typ = 6 then 'Jeden kontrahent ('+@Pod_Kod +') - jeden towar ('+@Twr_kod +')'
   when @Rab_Typ = 7 then 'Grupa towarowa ('+@TwG_Kod +') - wszyscy kontrahenci'
   when @Rab_Typ = 8 then 'Jeden towar ('+@Twr_kod +') - wszyscy kontrahenci'
   when @Rab_Typ = 11 then 'Stała cena jeden towar ('+@Twr_kod +') - wszyscy kontrahenci'
   when @Rab_Typ = 12 then 'Stała cena jeden towar ('+@Twr_kod +') - grupa kontrahenta ('+@Gru_Nazwa +')'
   when @Rab_Typ = 13 then 'Stała cena jeden towar ('+@Twr_kod +') - jeden kontrahent ('+@Pod_Kod +')'
 end
   -- Grupa kontrahentow - wszystkie towary      1         NULL         1                Gru_GruId
 -- Jeden kontrahent   - wszystkie towary      2         NULL         Pod_PodmiotTyp   Pod_PodId
 -- Grupa kontrahenta  - grupa towarowa        3         Gru_GruId    1                Gru_GruId
 -- Grupa kontrahentow - jeden towar           4         Twr_TwrId    1                Gru_GruId
 -- Jeden kontrahent   - grupa towarowa        5         Gru_GruId    Pod_PodmiotTyp   Pod_PodId
 -- Jeden kontrahent   - jeden towar           6         Twr_TwrId    Pod_PodmiotTyp   Pod_PodId
 -- Grupa towarowa     - wszyscy kontrahenci   7         Gru_GruId    NULL             NULL
 -- Jeden towar        - wszyscy kontrahenci   8         Twr_TwrId    NULL             NULL
 -- Rabaty typu sta3a cena - maja wyzszy priorytet i sa liczone w pierwszej kolejnosci
 -- Jeden towar        - wszyscy kontrahenci  11         Twr_TwrId    NULL             NULL
 -- Jeden towar        - grupa   kontrahentow 12         Twr_TwrId    1                Gru_GruId
 -- Jeden towar        - jeden   kontrahent   13         Twr_TwrId    Pod_PodmiotTyp   Pod_PodId
 EXEC CDN.RejestrOperacjiDodaj 1118, 0, @Rab_RabID, @Rab_Nazwa, @TypOperacji, ''
  END
  DECLARE Usuniete Cursor Local Fast_Forward For
  SELECT
  Rab_RabID,
  Rab_Typ,
  LTRIM(RTRIM(Twr_kod)), LTRIM(RTRIM(Pod_Kod)),LTRIM(RTRIM(Gru_Nazwa)),LTRIM(RTRIM(TwG_Kod))
  FROM deleted
left join CDN.PodmiotyView on  Pod_PodId = Rab_PodmiotId and Pod_PodmiotTyp = Rab_PodmiotTyp
left join CDN.Grupy on  Gru_GruId = Rab_Podmiotid
left join CDN.TwrGrupy on  TwG_GIDNumer = Rab_TwrId and TwG_GIDTyp = -16
left join CDN.Towary on  Twr_twrid = Rab_TwrId
  Open Usuniete
  While 1=1
  BEGIN
  Fetch Next From Usuniete Into
  @Rab_RabID,
   @Rab_Typ,
   @Twr_kod,
   @Pod_Kod,
   @Gru_Nazwa,
   @TwG_Kod
  If @@Fetch_Status <> 0 Break
  select @Rab_Nazwa =
    case when @Rab_Typ = 1 then 'Grupa kontrahenta ('+@Gru_Nazwa +') - wszystkie towary'
   when @Rab_Typ = 2 then 'Jeden kontrahent ('+ISNULL(@Pod_Kod,'Usunięty') +') - wszystkie towary'
   when @Rab_Typ = 3 then 'Grupa kontrahenta ('+@Gru_Nazwa +') - grupa towarowa ('+@TwG_Kod +')'
   when @Rab_Typ = 4 then 'Grupa kontrahenta ('+@Gru_Nazwa +') - jeden towar ('+@Twr_kod +')'
   when @Rab_Typ = 5 then 'Jeden kontrahent ('+ISNULL(@Pod_Kod,'Usunięty') +') - grupa towarowa ('+@TwG_Kod +')'
   when @Rab_Typ = 6 then 'Jeden kontrahent ('+ISNULL(@Pod_Kod,'Usunięty') +') - jeden towar ('+@Twr_kod +')'
   when @Rab_Typ = 7 then 'Grupa towarowa ('+@TwG_Kod +') - wszyscy kontrahenci'
   when @Rab_Typ = 8 then 'Jeden towar ('+@Twr_kod +') - wszyscy kontrahenci'
   when @Rab_Typ = 11 then 'Stała cena jeden towar ('+@Twr_kod +') - wszyscy kontrahenci'
   when @Rab_Typ = 12 then 'Stała cena jeden towar ('+@Twr_kod +') - grupa kontrahenta ('+@Gru_Nazwa +')'
   when @Rab_Typ = 13 then 'Stała cena jeden towar ('+@Twr_kod +') - jeden kontrahent ('+ISNULL(@Pod_Kod,'Usunięty') +')'
 end
   IF NOT EXISTS(select * from inserted where inserted.Rab_RabID = @Rab_RabID)
   BEGIN
  EXEC CDN.RejestrOperacjiDodaj 1118, 0, @Rab_RabID, @Rab_Nazwa, 3, ''
   END
  END
  Close Dodane
  Close Usuniete
  Deallocate Dodane
  Deallocate Usuniete
  SET NOCOUNT OFF

GO
Create Trigger CDN.Rabaty_InsertUpdate_Trigger
  On CDN.Rabaty
  For Insert, Update, DELETE
As
Set NoCount On
  DECLARE @IDPrmKnt int
  IF EXISTS (SELECT * FROM CDN.Firma WHERE Fir_Numer = 1470 AND Fir_Wartosc = '4')
    If Exists (
               Select * From deleted Left Outer Join CDN.Kontrahenci On Rab_PodmiotId  = Knt_KntId
               Where Rab_Typ In (2) And Rab_PodmiotTyp = 1
    )
    Begin
             Select @IDPrmKnt=Prm_ID From CDN.PrmKarty Where PRM_Typ=1
             Delete CDN.KntPromocje From CDN.KntPromocje
               Join CDN.Kontrahenci On Kpr_KntNumer=knt_GIDNumer
               join deleted On Rab_PodmiotId  = Knt_KntId
             Where Kpr_PrmID=@IDPrmKnt
    End
If Exists (Select * From inserted Where Rab_Typ In (2, 5, 6))
Begin
  If Exists (
    Select * From inserted Left Outer Join CDN.Kontrahenci On Rab_PodmiotId  = Knt_KntId
    Where Rab_Typ In (2, 5, 6) And Rab_PodmiotTyp = 1 And Knt_KntId Is Null
    )
    Begin
      RaisError ('##OPT34524##', 16, 1)
      RollBack Tran
      Set NoCount Off
      Return
    End
  IF EXISTS (SELECT * FROM CDN.Firma WHERE Fir_Numer = 1470 AND Fir_Wartosc = '4')
   If Exists (
              Select * From inserted Left Outer Join CDN.Kontrahenci On Rab_PodmiotId  = Knt_KntId
              Where Rab_Typ In (2) And Rab_PodmiotTyp = 1
             )
             BEGIN
                Select @IDPrmKnt=Prm_ID From CDN.PrmKarty Where PRM_Typ=1 -- PROM_KNT
                IF @IDPrmKnt IS NULL
                BEGIN
                    Insert Into CDN.PrmKarty (PRM_ID,PrM_Akronim, Prm_DataOd, Prm_DataDo, Prm_Typ, Prm_Stan, Prm_Aktywna, Prm_Priorytet, Prm_SposobStosowania, Prm_PominPozostale, Prm_Uwagi, Prm_Dokument, Prm_LastMod,PRM_PriorytetLp,Prm_Cykliczna /*, Prm_CenaEdytowalna*/ )
                    Values (0,'UPUSTY GLOBALNE KONTRAHENTA', 0, 2147483647, 1, 1, 0, 10, 1, 0,'Promocja zawierająca wszystkie upusty globalne kontrahenta zdefinwoane na karcie kontrahenta.', 0, 0, 0, 0 /*, 1 */ )
                    SET @IDPrmKnt = 0
                END
                Update CDN.KntPromocje Set Kpr_Wartosc=rab_rabat
                  From CDN.KntPromocje
                  Join CDN.Kontrahenci a On  Kpr_KntNumer=knt_GIDNumer
                  Join inserted On Rab_PodmiotId  = Knt_KntId
                 Where Kpr_PrmID=@IDPrmKnt AND rab_rabat!=0
                 Insert Into CDN.KntPromocje (KPR_PRMID, KPR_KntTyp, KPR_KntFirma, KPR_KntNumer, KPR_KntLp, KPR_KngTyp, KPR_KngFirma, KPR_KngNumer, KPR_KngLp, Kpr_Typ, Kpr_Wartosc)
                 Select @IDPrmKnt, knt_GIDTyp,knt_GIDFirma, knt_GIDNumer, knt_GIDLp,0,0,0,0,1,rab_rabat
                 From  inserted
                 Left Outer Join CDN.Kontrahenci On Rab_PodmiotId  = Knt_KntId
                 Left Join CDN.KntPromocje On  Kpr_KntNumer=knt_GIDNumer AND Kpr_PrmID=@IDPrmKnt
                 Where  Kpr_ID IS NULL AND rab_rabat!=0
            END
  IF NOT EXISTS (SELECT * FROM CDN.Firma WHERE Fir_Numer = 1470 AND Fir_Wartosc = '4')
  BEGIN
  If Exists (
  Select * From inserted Left Outer Join CDN.Kontrahenci On Rab_PodmiotId  = Knt_KntId
  Where Rab_Typ In (2) And Rab_PodmiotTyp = 1)
 Begin
  Update CDN.Kontrahenci
  Set Knt_TS_Export = NULL
  Where Knt_KntId in (Select Rab_PodmiotId From inserted)
 end
  END
  If Exists (
    Select * From inserted Left Outer Join CDN.BnkNazwy On Rab_PodmiotId  = BNa_BNaId
    Where Rab_Typ In (2, 5, 6) And Rab_PodmiotTyp = 2 And BNa_BNaId Is Null
    )
    Begin
      RaisError ('##OPT34525##', 16, 1)
      RollBack Tran
      Set NoCount Off
      Return
    End
  If Exists (
    Select * From inserted Left Outer Join CDN.PracKod On Rab_PodmiotId  = Pra_PraId
    Where Rab_Typ In (2, 5, 6) And Rab_PodmiotTyp = 3 And Pra_PraId Is Null
    )
    Begin
      RaisError ('##OPT34526##', 16, 1)
      RollBack Tran
      Set NoCount Off
      Return
    End
  If Exists (
    Select * From inserted Left Outer Join CDN.Urzedy On Rab_PodmiotId  = Urz_UrzId
    Where Rab_Typ In (2, 5, 6) And Rab_PodmiotTyp = 5 And Urz_UrzId Is Null
    )
    Begin
      RaisError ('##OPT34527##', 16, 1)
      RollBack Tran
      Set NoCount Off
      Return
    End
End
If Exists (
  Select * From inserted Left Outer Join CDN.Grupy On Rab_PodmiotId  = Gru_GruId And Gru_Typ = 31
  Where Rab_Typ In (1, 3, 4) And Rab_PodmiotTyp = 1 And Gru_GruId Is Null
  )
  Begin
    RaisError ('##OPT34528##', 16, 1)
    RollBack Tran
    Set NoCount Off
    Return
  End
If Exists (
  Select * From inserted Left Outer Join CDN.Towary On Rab_TwrId  = Twr_TwrId
  Where Rab_Typ In (6, 8) And Twr_TwrId Is Null
  )
  Begin
    RaisError ('##OPT34529##', 16, 1)
    RollBack Tran
    Set NoCount Off
    Return
  End
If Exists (
  Select * From inserted Left Outer Join CDN.TwrGrupy On Rab_TwrId  = TwG_GIDNumer and TwG_GIDTyp = -16
  Where Rab_Typ In (3, 7) And TwG_GIDNumer Is Null
  )
  Begin
    RaisError ('##OPT34530##', 16, 1)
    RollBack Tran
    Set NoCount Off
    Return
  End
Set NoCount Off

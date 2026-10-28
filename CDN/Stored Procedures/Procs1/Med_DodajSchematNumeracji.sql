CREATE PROCEDURE [CDN].[Med_DodajSchematNumeracji]
 @symbol NVARCHAR(5),  --symbol
 @MiejsceSymbol int, -- miejsce symbolu w schemacie numeracji
 @MiejsceLicznik int, -- miejsce Licznik w schemacie numeracji
 @MiejsceRok int, -- miejsce Rok  w schemacie numeracji
 @MiejsceSymbol_lokalizacji int, -- miejsce serii w schemacie numeracji
 @TypDokumentu int, --302 faktura,305 paragon
 @Nazwa NVARCHAR(20), -- nazwa dla schematu
 @MiejsceMiesiac int = 0 -- miejsce miesiąca w schemacie numeracji
AS
SET NOCOUNT ON
/*
<symbol> - VARCHAR2(8)
<licznik> - NUMBER(8)
<rok> - NUMER(4)
<symbol_lokalizacji> - VARCHAR2(10)
*/
DECLARE
    @DDf_DDfId INT,
    @Numeracja NVARCHAR(50)
set @Numeracja = ''
    if @MiejsceSymbol = '1'
     select @Numeracja = '@symbol'
    if @MiejsceLicznik = '1'
     select @Numeracja = '@numerS'
    if @MiejsceRok  = '1'
     select @Numeracja = '@rok_kal'
    if @MiejsceSymbol_lokalizacji = '1'
     select @Numeracja = '@rejestr'
    if @MiejsceMiesiac = '1'
     select @Numeracja = '@miesiac'
    if @MiejsceSymbol = '2'
     select @Numeracja = @Numeracja+'/@symbol'
    if @MiejsceLicznik = '2'
     select @Numeracja = @Numeracja+'/@numerS'
    if @MiejsceRok  = '2'
     select @Numeracja = @Numeracja+'/@rok_kal'
    if @MiejsceSymbol_lokalizacji = '2'
     select @Numeracja = @Numeracja+'/@rejestr'
    if @MiejsceMiesiac = '2'
     select @Numeracja = @Numeracja+'/@miesiac'
    if @MiejsceSymbol = '3'
     select @Numeracja = @Numeracja+'/@symbol'
    if @MiejsceLicznik = '3'
     select @Numeracja = @Numeracja+'/@numerS'
    if @MiejsceRok  = '3'
     select @Numeracja = @Numeracja+'/@rok_kal'
    if @MiejsceMiesiac = '3'
     select @Numeracja = @Numeracja+'/@miesiac'
    if @MiejsceSymbol_lokalizacji = '3'
     select @Numeracja = @Numeracja+'/@rejestr'
    if @MiejsceSymbol = '4'
     select @Numeracja = @Numeracja+'/@symbol'
    if @MiejsceLicznik = '4'
     select @Numeracja = @Numeracja+'/@numerS'
    if @MiejsceRok  = '4'
     select @Numeracja = @Numeracja+'/@rok_kal'
    if @MiejsceSymbol_lokalizacji = '4'
     select @Numeracja = @Numeracja+'/@rejestr'
    if @MiejsceMiesiac = '4'
     select @Numeracja = @Numeracja+'/@miesiac'
    if @MiejsceSymbol = '5'
     select @Numeracja = @Numeracja+'/@symbol'
    if @MiejsceLicznik = '5'
     select @Numeracja = @Numeracja+'/@numerS'
    if @MiejsceRok  = '5'
     select @Numeracja = @Numeracja+'/@rok_kal'
    if @MiejsceSymbol_lokalizacji = '5'
     select @Numeracja = @Numeracja+'/@rejestr'
    if @MiejsceMiesiac = '5'
     select @Numeracja = @Numeracja+'/@miesiac'
     if @MiejsceSymbol = '0'
     select @Numeracja = @Numeracja+'/@brak'
    if @MiejsceLicznik = '0'
     select @Numeracja = @Numeracja+'/@brak'
    if @MiejsceRok  = '0'
     select @Numeracja = @Numeracja+'/@brak'
    if @MiejsceSymbol_lokalizacji = '0'
     select @Numeracja = @Numeracja+'/@brak'
    if @MiejsceMiesiac = '0'
     select @Numeracja = @Numeracja+'/@brak'
  SELECT  @DDf_DDfId  = DDf_DDfId
    FROM CDN.DokDefinicje
    WHERE DDf_Symbol = @Symbol
  IF @DDf_DDfId IS NULL
    BEGIN
     INSERT INTO CDN.DokDefinicje
           (DDf_Klasa
           ,DDf_Symbol
           ,DDf_Nazwa
           ,DDf_Numeracja
           ,DDf_SeriaOperatora
           ,DDf_ImportRowId
           ,DDf_TS_Zal
           ,DDf_TS_Mod)
       VALUES
           (@TypDokumentu
           ,@Symbol
           ,@Nazwa
           ,@Numeracja
           ,0
           ,''
           ,GETDATE()
           ,GETDATE())
    END
   Else
    BEGIN
     RAISERROR( 'Taki symbol schematu już istnieje', 16, 1)
     RETURN
    END
select DDf_DDfId from CDN.DokDefinicje where DDf_Symbol = @Symbol
  SET NOCOUNT OFF

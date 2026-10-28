Create PROCEDURE CDN.ZapiszOperatoraWyr
@Tabela      NVARCHAR(MAX),
@OpeId      int ,
@OpeKod      NVARCHAR(MAX),
@OpeNazwisko    NVARCHAR(MAX),
@NazwaKolumnyKluczaGlownego NVARCHAR(MAX),
@filtr      NVARCHAR(MAX),
@Email int  = 0
AS
SET NOCOUNT ON
DECLARE @sqlCommand NVARCHAR(MAX)
set @OpeKod = REPLACE(@OpeKod,'''','''''')
set @OpeNazwisko = REPLACE(@OpeNazwisko,'''','''''')
set @sqlCommand = ''
if @filtr = ''
 set @filtr = '1=1'
if @Tabela != ''
begin
 if @Tabela = 'TraNag'
 Begin
  SET @sqlCommand ='UPDATE cdn.TraNag SET TrN_OpeWydrID = '+ convert(varchar(15), @OpeId) +',TrN_OpeWydrKod = '''+ @OpeKod +''',TrN_OpeWydrNazwisko = '''+ @OpeNazwisko +''', TrN_TS_Wydr = GETDATE() WHERE '+ @filtr
 end
end
else
begin
select @NazwaKolumnyKluczaGlownego
 if @NazwaKolumnyKluczaGlownego != ''
 begin
  if  CHARINDEX('trn_trnid',@NazwaKolumnyKluczaGlownego) > 0
   SET @sqlCommand ='UPDATE cdn.TraNag SET TrN_OpeWydrID = '+ convert(varchar(15), @OpeId) +',TrN_OpeWydrKod = '''+ @OpeKod +''',TrN_OpeWydrNazwisko = '''+ @OpeNazwisko +''',  TrN_TS_Wydr = GETDATE() WHERE TRN_TRNID IN ((SELECT RpZ2_GIDNumer FROM cdn.RptZaznaczenia2 WHERE '+ @filtr +'))'
 end
 else
 begin
  if CHARINDEX('trn_trnid',@filtr) > 0
   SET @sqlCommand ='UPDATE cdn.TraNag SET TrN_OpeWydrID = '+ convert(varchar(15), @OpeId) +',TrN_OpeWydrKod = '''+ @OpeKod +''',TrN_OpeWydrNazwisko = '''+ @OpeNazwisko +''',  TrN_TS_Wydr = GETDATE() WHERE '+ @filtr
 end
end
if @sqlCommand != ''
EXEC (@sqlCommand)
SET NOCOUNT OFF

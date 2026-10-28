CREATE PROCEDURE [CDN].[Mobile_Android_ImportKntOsoby]
 @OptimaId int ,
 @DSKnOId int ,
 @DSKntId int ,
 @StanDetalID int ,
 @Telefon varchar(20) ,
 @GSM varchar(20) ,
 @Informacje nvarchar(254) ,
 @Email nvarchar(60) ,
 @Nazwisko nvarchar(40),
 @Domyslny int,
 @Nieaktywna int = 0
AS
SET NOCOUNT ON
DECLARE
 @DKnO_DKnOId int,
 @Knt_KntId int,
 @Kno_KnoId int
 if @DSKntId < 0
select  @Knt_KntId = DKnt_OptimaId from cdn.DetalKontrahenci where DKnt_DSKntId =  @DSKntId and DKnt_StanDetalID = @StanDetalID
else
select  @Knt_KntId = Knt_KntId from cdn.Kontrahenci where Knt_KntId =  @DSKntId
if @DSKnOId < 0
  SELECT  @DKnO_DKnOId = DKnO_DKnOId, @OptimaID = DKnO_OptimaID
    FROM CDN.DetalKntOsoby
    WHERE DKnO_DSKnOId = @DSKnOId and DKnO_StanDetalID = @StanDetalID
else
begin
 SELECT  @DKnO_DKnOId = DKnO_DKnOId
    FROM CDN.DetalKntOsoby
    WHERE DKnO_OptimaID = @DSKnOId and DKnO_StanDetalID = @StanDetalID
    set @OptimaID = @DSKnOId
end
  IF @DKnO_DKnOId IS NULL
    BEGIN
       INSERT INTO CDN.DetalKntOsoby
           (DKnO_OptimaId
           ,DKnO_DSKnOId
           ,DKnO_DSKntId
           ,DKnO_StanDetalID
           ,DKnO_Telefon
           ,DKnO_GSM
           ,DKnO_Informacje
           ,DKnO_Email
           ,DKnO_Nazwisko
    )
  VALUES (
 @OptimaId ,
 @DSKnOId ,
 @DSKntId ,
 @StanDetalID ,
 @Telefon  ,
 @GSM  ,
 0  ,
 @Email  ,
 @Nazwisko
         )
    END
  ELSE
 BEGIN
     UPDATE  CDN.DetalKntOsoby
   SET
   DKnO_OptimaId = @OptimaId
           ,DKnO_DSKnOId = @DSKnOId
           ,DKnO_DSKntId = @DSKntId
           ,DKnO_StanDetalID = @StanDetalID
           ,DKnO_Telefon = @Telefon
           ,DKnO_GSM = @GSM
           ,DKnO_Email = @Email
           ,DKnO_Nazwisko = @Nazwisko
  WHERE (@DKnO_DKnOId = DKnO_DKnOId)
      END
if @OptimaId = 0
 BEGIN
      -- dodajemy nowego
   if   @Domyslny = 1
     update cdn.KntOsoby set KnO_Domyslny = 0 where KnO_KntId = @Knt_KntId
   INSERT INTO cdn.KntOsoby
      (
           KnO_KntId
           ,KnO_Plec
           ,KnO_KodPocztowy
           ,KnO_Telefon
           ,KnO_GSM
           ,KnO_Informacje
           ,KnO_Domyslny
           ,KnO_Adres2
           ,KnO_Email
           ,KnO_Gmina
           ,KnO_Kraj
           ,KnO_Miasto
           ,KnO_Nazwisko
           ,KnO_NrDomu
           ,KnO_NrLokalu
           ,KnO_Poczta
           ,KnO_Powiat
           ,KnO_Tytul
           ,KnO_Ulica
           ,KnO_Wojewodztwo
     ,KnO_Nieaktywny
       )
      VALUES
      (
        @Knt_KntId
        ,1
           ,''
           ,@Telefon
           ,@GSM
           ,0
           ,@Domyslny
           ,''
           ,@Email
           ,''
           ,''
           ,''
           ,@Nazwisko
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
     ,@Nieaktywna
       )
       select @Kno_KnoId = Kno_KnoID from CDN.Kntosoby where KnO_Nazwisko = @Nazwisko and KnO_KntId = @Knt_KntId
 update CDN.DetalKntOsoby SET DKno_OptimaId = @Kno_KnoId WHERE  DKno_DSKnoId = @DSKnOId and DKnO_StanDetalID = @StanDetalID
 END
else
 BEGIN
    if   @Domyslny = 1
 update cdn.KntOsoby set KnO_Domyslny = 0 where KnO_KntId = @Knt_KntId
    UPDATE cdn.KntOsoby SET
        KnO_Telefon = @Telefon,
        KnO_GSM = @GSM,
        KnO_Email = @Email,
        KnO_Nazwisko = @Nazwisko,
        KnO_Domyslny = @Domyslny,
        KnO_Nieaktywny = @Nieaktywna
      WHERE KnO_KnOId = @OptimaId
 END

CREATE PROCEDURE CDN.KopiujKodyJPKV7NaPodkategorie(@KatOgID INT, @OpeID INT)
AS
BEGIN
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeID, @OpeModKod OUT, @OpeModNazwisko OUT
 Declare @KatOgKod NVARCHAR(256)
 SELECT @KatOgKod = Kat_KodOgolny FROM cdn.Kategorie WHERE Kat_KatID = @KatOgID
 Declare Podkategorie Cursor Local Fast_Forward For
 Select Kat_KatID, Kat_KodSzczegol
 From CDN.Kategorie
 Where Kat_KodOgolny = @KatOgKod AND Kat_Poziom = 2
 Declare @KatID INT
 Declare @KatKodSzczegol VARCHAR(20)
 Open Podkategorie
 While 1=1
 Begin
  Fetch Next From Podkategorie Into @KatID, @KatKodSzczegol
  If @@Fetch_Status<>0 Break
  INSERT INTO cdn.DokKodyJPKV7 (DKV7_ParentTyp, DKV7_ParentID, DKV7_KV7ID, DKV7_Status)
   SELECT DKV7_ParentTyp, @KatID, DKV7_KV7ID, DKV7_Status FROM cdn.DokKodyJPKV7 A WHERE A.DKV7_ParentTyp = 3 AND A.DKV7_ParentID = @KatOgID
    AND NOT EXISTS (SELECT * FROM cdn.DokKodyJPKV7 B WHERE B.DKV7_ParentTyp = 3 AND B.DKV7_ParentID = @KatID AND B.DKV7_KV7ID = A.DKV7_KV7ID)
  UPDATE cdn.Kategorie SET Kat_OpeModID = @OpeID, Kat_OpeModKod = @OpeModKod, Kat_OpeModNazwisko = @OpeModNazwisko, Kat_TS_Mod = GETDATE() WHERE Kat_KatID = @KatID
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 4008, -- OptimaObjectType_Kategoria
    @ObiektSubTyp = 0,
    @ObiektID = @KatID,
    @ObiektNazwa = @KatKodSzczegol,
    @OperacjaTyp = 2,
    @Opis = '' --@Kat_Opis
 End
 Close Podkategorie
 Deallocate Podkategorie
END

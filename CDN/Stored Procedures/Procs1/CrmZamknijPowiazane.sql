CREATE PROCEDURE cdn.CrmZamknijPowiazane
@crkId  AS INT,
@opeNazwisko AS NVARCHAR(40)
AS
BEGIN
 SET NOCOUNT ON;
 INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
 SELECT DISTINCT 700, NULL, CrK_CrKId, CrK_NumerPelny, GetDate(), @opeNazwisko, 103, N'' FROM CDN.CrmKontakty
 WHERE (CRK_Bufor = 1 AND CRK_ParId Is Not NULL AND CRK_ParId = @crkId)
 UPDATE cdn.CrmKontakty
 SET CRK_Bufor = 0
 WHERE (CRK_Bufor = 1 AND CRK_ParId Is Not NULL AND CRK_ParId = @crkId)
 SET NOCOUNT OFF;
 SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
END

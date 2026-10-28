CREATE FUNCTION [CDN].[DetalStan_SprawdzKorektyDlaElementu] (@DSTrEId INT)
RETURNS @TraElemKor TABLE (
                          DSTrEId         INT PRIMARY KEY,
                          IloscKor      NUMERIC(15,4),
        WartoscKor      NUMERIC(15,4)
                          )
AS
BEGIN
  DECLARE @IloscKor      NUMERIC(15,4) -- ilosc elementu pomniejszona o ilości z korekt
  DECLARE @WartoscKor      NUMERIC(15,4) -- wartosc elementu pomniejszona o ilości z korekt
SELECT @IloscKor = SUM(IsNull(B.DSTrE_Ilosc,0.00)),
  @WartoscKor = SUM(IsNull(B.DSTrE_WartoscBrutto,0.00))
    FROM CDN.DetalStanTraElem B JOIN CDN.DetalStanTraNag  C ON
     B.DSTrE_DSTrNId = C.DSTrN_DSTrNId AND C.DSTrN_Korekta = 1 AND C.DSTrN_Bufor<>1
    WHERE DSTrE_ZwrId = @DSTrEId
SELECT @IloscKor = A.DSTrE_Ilosc + IsNull(@IloscKor, 0),
  @WartoscKor = A.DSTrE_WartoscBrutto + IsNull(@WartoscKor, 0)
    FROM CDN.DetalStanTraElem A
    WHERE A.DSTrE_DSTrEId = @DSTrEId
  --Dodanie wiersza do tabeli zwracanej przez funkcję
  INSERT INTO @TraElemKor
    (DSTrEId, IloscKor, WartoscKor)
  VALUES
    (@DSTrEId, @IloscKor, @WartoscKor)
  RETURN
END

CREATE PROCEDURE CDN.OFF_Ex_Infoblok
   AS
   SET NOCOUNT ON
   DECLARE
     @TSS nvarchar(254),
     @TSK nvarchar(254),
     @TST nvarchar(254),
     @TSP nvarchar(254),
     @TSG nvarchar(254),
     @ZC nvarchar(254),
     @IDO INT,
     @CS nvarchar(20),
     @CN nvarchar(50),
     @OS nvarchar(20),
     @ON nvarchar(50)
        IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1563) SELECT @TSS = 0 ELSE SELECT @TSS = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1563
        IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1564) SELECT @TSK = 0 ELSE SELECT @TSK = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1564
        IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1565) SELECT @TST = 0 ELSE SELECT @TST = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1565
        IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1566) SELECT @TSP = 0 ELSE SELECT @TSP = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1566
        IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1822) SELECT @TSG = 0 ELSE SELECT @TSG = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1822
        SELECT @CS = Mag_Symbol, @CN = Mag_Nazwa From Cdn.Magazyny where Mag_Typ = 2
        SELECT @IDO = Mag_Magidxl ,@OS = Mag_Symbol, @ON = Mag_Nazwa  FROM cdn.magazyny WHERE Mag_MagId = 1
        IF not exists (SELECT fir_wartosc FROM Cdn.Firma WHERE Fir_Numer = 1562) select @ZC = 0 ELSE SELECT @ZC = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1562
   SET NOCOUNT OFF
   SELECT @TSS AS _TSS,@TSK AS _TSK,@TST AS _TST ,@TSP AS _TSP,@TSG AS _TSG, @ZC AS _ZC,@IDO AS _IDO, @CS AS _CS, @CN AS _CN, @OS AS _OS, @ON AS _ON

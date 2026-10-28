CREATE FUNCTION CDN.Powiazania (@Id INT, @IdTyp INT )
RETURNS @Relacje TABLE (TrN_TypDokumentu INT, TrN_NumerPelny NVARCHAR(40), TrN_DataOpe DATETIME,TrN_TrNId INT, TrN_Korekta INT, TrN_DataWys DATETIME, TrN_RazemNetto DECIMAL(15,2), TrN_MagZrdID INT, Trn_Waluta NVARCHAR(5), TrN_RazemNettoWal DECIMAL(15,2))
AS
BEGIN
  DECLARE
         @FaId INT,
         @FaTyp INT,
         @FaIdPowiazane INT,
         @FaTypPowiazane INT,
         @FaIdStare INT,
         @FaTypStare INT,
         @FaTypPoziom INT,
         @FaIdPoziom INT,
         @Flaga INT,
         @ZlecenieId INT,
         @CRMId INT
         SET @FaIdStare = 0
         SET @FaTypStare = 0
  DECLARE Relacje CURSOR LOCAL FAST_FORWARD FOR
   SELECT TrR_FaId, TrR_FaTyp FROM CDN.TraNagRelacje WHERE TrR_TrNID = @Id  AND TrR_TrNTyp = @IdTyp
    OPEN Relacje
     WHILE 1=1
      BEGIN
        FETCH NEXT FROM Relacje INTO @FaId, @FaTyp
         IF @@FETCH_STATUS <> 0 BREAK
         --najpierw dodaję skojrzone dokumenty z relacji na poziomie 1
          IF NOT EXISTS (SELECT TrN_TrNId FROM @Relacje WHERE TrN_TrNId = @FaId AND TrN_TypDokumentu = @FaTyp)
          BEGIN
   INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal)
   SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaId AND TrN_TypDokumentu = @FaTyp
      -- i jeszcze dokumeny serwisowe powiązane ze skojarzoną z FA WZ
   IF @FaTyp = 306 AND (@IdTyp=302 OR @IdTyp=305)
    INSERT INTO @Relacje(TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
    SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM cdn.SerwisPowiazania(@FaId, @FaTyp)
          END
         --teraz szukam relacji skojarzonych na poziomie 2
        -- SELECT @FaidStare = Trr_FaId, @FaTypStare = Trr_FaTyp FROM CDN.TraNagRelacje WHERE Trr_TrNId = @FaId AND Trr_TrNTyp = @FaTyp
         DECLARE Relacje2 CURSOR LOCAL FAST_FORWARD FOR
          SELECT Trr_FaId, Trr_FaTyp, Trr_Flaga FROM CDN.TraNagRelacje WHERE (Trr_TrNId = @FaId AND Trr_TrNTyp = @FaTyp  AND Trr_FaId <> @Id)
               --AND Trr_FaTyp <> @IdTyp)
                    AND TrR_FaId <> @FaidStare  AND TrR_FaTyp <> @FaTypStare
          OPEN Relacje2
          WHILE 1=1
          BEGIN
          FETCH NEXT FROM Relacje2 INTO @FaIdPowiazane, @FaTypPowiazane, @Flaga
          IF @@FETCH_STATUS <> 0 BREAK
          SET @FaIdStare = 0
          SET @FaTypStare = 0
         -- dla określonych typów dokumentów sam określam co chcę wyświetlać
         -- dokumenty przychodowe  --
         -- relacje do FA, czyli kiedy jestem na dokumencie FA
          IF @IdTyp = 302
            BEGIN
               IF @FaTypPowiazane = 308 AND @FaTyp = 306 AND NOT EXISTS (SELECT TrN_TrNID FROM @Relacje WHERE TrN_TrNID = @FaIdPowiazane)
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 314 AND @FaTyp = 306
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 302 AND @FaTyp = 320
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane --AND TrN_ZwrId IS NULL AND TrN_Rodzaj <> 302200
               IF @FaTypPowiazane = 306 AND @FaTyp = 320
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 320 AND @FaTyp = 308
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
              --  SELECT @FaidStare = Trr_FaId, @FaTypStare = Trr_FaTyp FROM CDN.TraNagRelacje WHERE (Trr_TrNId = @FaId AND Trr_TrNTyp = @FaTyp  AND Trr_FaId <> @Id AND Trr_FaTyp <> @IdTyp)
            END
          -- relacje do PA, czyli kiedy jestem na dokumencie PA
           IF @IdTyp = 305
             BEGIN
               IF @FaTypPowiazane = 308 AND @FaTyp = 306 AND NOT EXISTS (SELECT TrN_TrNID FROM @Relacje WHERE TrN_TrNID = @FaIdPowiazane)
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               --IF @FaTypPowiazane = 306 AND @FaTyp = 302 AND NOT EXISTS (SELECT TrN_TrNID FROM @Relacje WHERE TrN_TrNID = @FaIdPowiazane)
               --  INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
               --  SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 314 AND @FaTyp = 306
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID ,Trn_Waluta, TrN_RazemNettoWal)
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
              -- SELECT @FaidStare = Trr_FaId, @FaTypStare = Trr_FaTyp FROM CDN.TraNagRelacje WHERE (Trr_TrNId = @FaId AND Trr_TrNTyp = @FaTyp  AND Trr_FaId <> @Id AND Trr_FaTyp <> @IdTyp)
             END
          -- relacje do WZ, czyli kiedy jestem na dokumencie WZ
          IF @IdTyp = 306
            BEGIN
               IF @FaTypPowiazane = 308 AND @FaTyp = 302
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 302 AND @FaTyp = 320 AND NOT EXISTS (SELECT TrN_TrNID FROM @Relacje WHERE TrN_TrNID = @FaIdPowiazane)
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 320 AND @FaTyp = 302 AND NOT EXISTS (SELECT TrN_TrNID FROM @Relacje WHERE TrN_TrNID = @FaIdPowiazane)
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               --IF @FaTypPowiazane = 305 AND @FaTyp = 302 AND NOT EXISTS (SELECT TrN_TrNID FROM @Relacje WHERE TrN_TrNID = @FaIdPowiazane)
               --  INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
               --  SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 308 AND @FaTyp = 305
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 314 AND @FaTyp = 305
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 314 AND @FaTyp = 302
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 320 AND @FaTyp = 308
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
            END
          -- relacje do WKA, czyli kiedy jestem na dokumencie WKA
          IF @IdTyp = 314
            BEGIN
               IF @FaTypPowiazane = 306 AND @FaTyp = 305
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 306 AND @FaTyp = 302
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 302 AND @FaTyp = 306
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 305 AND @FaTyp = 306 AND NOT EXISTS (SELECT * FROM @Relacje WHERE TrN_TrNId = @FaIdPowiazane)
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
            END
          -- relacje do FPF, czyli kiedy jestem na dokumencie FPF
          IF @IdTyp = 320
            BEGIN
               IF @FaTypPowiazane = 306 AND @FaTyp = 302 AND NOT EXISTS (SELECT TrN_TrNId FROM @Relacje WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane)
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 302 AND @FaTyp = 308
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 306 AND @FaTyp = 308
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 312 AND @FaTyp = 308
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 304 AND @FaTyp = 308
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
         --    SELECT @FaidStare = Trr_FaId, @FaTypStare = Trr_FaTyp FROM CDN.TraNagRelacje WHERE (Trr_TrNId = @FaId AND Trr_TrNTyp = @FaTyp  AND Trr_FaId <> @Id AND Trr_FaTyp <> @IdTyp)
            END
          -- relacje do RO, czyli kiedy jestem na dokumencie RO
          IF @IdTyp = 308
            BEGIN
               IF @FaTypPowiazane = 302 AND @FaTyp = 306 AND NOT EXISTS (SELECT TrN_TrNID FROM @Relacje WHERE TrN_TrNID = @FaIdPowiazane)
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 306 AND @FaTyp = 302
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 305 AND @FaTyp = 306 AND NOT EXISTS (SELECT TrN_TrNID FROM @Relacje WHERE TrN_TrNID = @FaIdPowiazane)
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 306 AND @FaTyp = 305
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
         --    SELECT @FaidStare = Trr_FaId, @FaTypStare = Trr_FaTyp FROM CDN.TraNagRelacje WHERE (Trr_TrNId = @FaId AND Trr_TrNTyp = @FaTyp  AND Trr_FaId <> @Id AND Trr_FaTyp <> @IdTyp)
            END  -- dokumenty przychodowe
         -- dokumenty kosztowe --
         -- relacje do ZD, czyli kiedy jestem na dokumencie ZD
          IF @IdTyp = 309
            BEGIN
               IF @FaTypPowiazane = 301 AND @FaTyp = 307 AND NOT EXISTS (SELECT TrN_TrNID FROM @Relacje WHERE TrN_TrNID = @FaIdPowiazane)
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 307 AND @FaTyp = 301
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
        --     SELECT @FaidStare = Trr_FaId, @FaTypStare = Trr_FaTyp FROM CDN.TraNagRelacje WHERE (Trr_TrNId = @FaId AND Trr_TrNTyp = @FaTyp  AND Trr_FaId <> @Id AND Trr_FaTyp <> @IdTyp)
            END
        -- relacje do FZ, czyli kiedy jestem na dokumencie FZ
          IF @IdTyp = 301
            BEGIN
               IF @FaTypPowiazane = 309 AND @FaTyp = 307 AND NOT EXISTS (SELECT TrN_TrNID FROM @Relacje WHERE TrN_TrNID = @FaIdPowiazane)
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 321 AND @FaTyp = 322
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 313 AND @FaTyp = 307
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
          --    SELECT @FaidStare = Trr_FaId, @FaTypStare = Trr_FaTyp FROM CDN.TraNagRelacje WHERE (Trr_TrNId = @FaId AND Trr_TrNTyp = @FaTyp  AND Trr_FaId <> @Id AND Trr_FaTyp <> @IdTyp)
             END
        -- relacje do PZ, czyli kiedy jestem na dokumencie PZ
          IF @IdTyp = 307
            BEGIN
               IF @FaTypPowiazane = 350 AND @FaTyp = 301
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 309 AND @FaTyp = 301
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID ,Trn_Waluta, TrN_RazemNettoWal)
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 313 AND @FaTyp = 301
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
        --      SELECT @FaidStare = Trr_FaId, @FaTypStare = Trr_FaTyp FROM CDN.TraNagRelacje WHERE (Trr_TrNId = @FaId AND Trr_TrNTyp = @FaTyp  AND Trr_FaId <> @Id AND Trr_FaTyp <> @IdTyp)
             END
          IF @IdTyp = 313
            BEGIN
               IF @FaTypPowiazane = 307 AND @FaTyp = 301
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
               IF @FaTypPowiazane = 301 AND @FaTyp = 307
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
            END
        -- relacje do FRR, czyli kiedy jestem na dokumencie FRR
          IF @IdTyp = 350
            BEGIN
               IF @FaTypPowiazane = 307 AND @FaTyp = 301
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
        --      SELECT @FaidStare = Trr_FaId, @FaTypStare = Trr_FaTyp FROM CDN.TraNagRelacje WHERE (Trr_TrNId = @FaId AND Trr_TrNTyp = @FaTyp  AND Trr_FaId <> @Id AND Trr_FaTyp <> @IdTyp)
             END
        -- relacje do FWZ, czyli kiedy jestem na dokumencie FWZ
          IF @IdTyp = 321
            BEGIN
               IF @FaTypPowiazane = 301 AND @FaTyp = 322
                 INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                 SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe, TrN_TrNId, TrN_Korekta,TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM CDN.TraNag WITH (NOLOCK) WHERE TrN_TrNId = @FaIdPowiazane AND TrN_TypDokumentu = @FaTypPowiazane
            END -- dokumenty kosztowe
          SET @FaIdPowiazane=0
          SET @FaTypPowiazane=0
         END
        CLOSE Relacje2
       DEALLOCATE Relacje2
      END
    CLOSE Relacje
  DEALLOCATE Relacje
   -- tutaj przygotowuje liste dokumentow powiazanych zwiazanych z modulem CRM i Serwis
 IF @IdTyp = 302 OR @IdTyp = 304 OR @IdTyp = 312 OR @IdTyp = 305 OR @IdTyp = 309 OR @IdTyp = 306
    BEGIN
     --najpierw dokumenty z modulu Serwis
  INSERT INTO @Relacje(TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
  SELECT TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal FROM cdn.SerwisPowiazania(@Id, @IdTyp)
 END
 IF @IdTyp = 302 OR @IdTyp = 305
    BEGIN
     -- nastepnie dokumenty z modulu CRM
     IF EXISTS (SELECT * FROM CDN.DokRelacje WHERE DoR_DokumentTyp = @IdTyp AND DoR_DokumentId = @Id AND DoR_ParentTyp = 900)
                 BEGIN
                   DECLARE RelacjeCRM CURSOR LOCAL FAST_FORWARD FOR
                   SELECT DoR_ParentId FROM CDN.DokRelacje WHERE DoR_DokumentTyp = @IdTyp AND DoR_DokumentId = @Id AND DoR_ParentTyp = 900
                     OPEN RelacjeCRM
                      WHILE 1=1
                        BEGIN
                         FETCH NEXT FROM RelacjeCRM INTO @ZlecenieId
                          IF @@FETCH_STATUS <> 0 BREAK
                           INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
                           SELECT 700, CRK_NumerPelny, CRK_DataDok, CRK_CRKId,NULL, CRK_DataDok AS TrN_DataWys,0,0,'',0 FROM CDN.CRMKontakty
                           JOIN CDN.DokRelacje ON (CrK_CrKId = DoR_DokumentId AND DoR_DokumentTyp = 700 AND DoR_ParentTyp = 900) OR
                           (CrK_CrKId = DoR_ParentId AND DoR_ParentTyp = 700 AND DoR_DokumentTyp = 900)
                           WHERE (Dor_ParentTyp=900 AND DoR_ParentId = @ZlecenieId) OR (DoR_DokumentTyp=900 AND DoR_DokumentId = @ZlecenieId) ORDER BY CRK_DataDok, CRK_CrKId
                        END
                      CLOSE RelacjeCRM
                    DEALLOCATE RelacjeCRM
                  END
     END
    -- tutaj przygotowuje dokument intrastat ktory jest powiazany z dokumentem handlowym lub magazynowym
    IF @IdTyp IN (301,302,307,306,303,304,312,313,314)
    BEGIN
     INSERT INTO @Relacje (TrN_TypDokumentu, TrN_NumerPelny, TrN_DataOpe,TrN_TrNId, TrN_Korekta, TrN_DataWys, TrN_RazemNetto, TrN_MagZrdID,Trn_Waluta, TrN_RazemNettoWal )
     SELECT 100 AS TrN_TypDokumentu,'IST/' + CAST(IsN_Rok as NVARCHAR(4)) + '/'+
       CASE WHEN LEN (CAST(ISN_Miesiac AS NVARCHAR(2)))=1 THEN '0'+CAST(ISN_Miesiac AS NVARCHAR(2)) ELSE CAST(ISN_Miesiac AS NVARCHAR(2)) END
        + '/'+ RTRIM(CAST(ISN_Numer AS NVARCHAR(4))) + RTRIM( CAST(ISN_Wersja AS NVARCHAR(4))) AS TrN_NumerPelny, Isn_DataWypelnienia, Isn_IsnID, 0 AS TrN_Korekta,
       IsN_DataWypelnienia AS TrN_DataWys, Isn_Netto,'' AS TrN_MagZrdId,'',0 FROM CDN.IntrastatNag JOIN CDN.TraNag ON IsN_IsNId = TrN_IsNId
       AND TrN_TrNId = @Id AND TrN_TypDokumentu = @IdTyp AND TrN_IsNID IS NOT NULL
    END
 RETURN
END

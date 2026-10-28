Create PROCEDURE CDN.UstawIlosciNaPI
 @MagazynZrodlowyId   INT,
 @DataDokChr          NVARCHAR(20),
 @Id          INT
  AS
  SET NOCOUNT ON
  DECLARE
    @TrN_DataDok           DATETIME
    SET @TrN_DataDok = CONVERT(DATETIME, @DataDokChr, 120)
  UPDATE Cdn.TraElem SET Tre_IloscKW = ISNULL(I.TwI_Ilosc,0),Tre_IloscJMKW = ISNULL(I.TwI_Ilosc*TrE_JMPrzelicznikM/TrE_JMPrzelicznikL,0)
    FROM cdn.traelem
    LEFT OUTER JOIN cdn.TwrIlosci I ON TrE_TwrId = I.TwI_TwrId AND I.TwI_MagId = @MagazynZrodlowyId
        AND I.TwI_Data = (SELECT TOP 1 H.TwI_Data FROM CDN.TwrIlosci H WHERE H.TwI_TwrId = Tre_TwrId AND H.TwI_MagId = @MagazynZrodlowyId
        AND H.TwI_Data <=@TrN_DataDok ORDER BY H.TwI_Data DESC )
    WHERE     TrE_TrNId=@Id
    SET NOCOUNT Off

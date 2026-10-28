CREATE PROCEDURE [CDN].jdp_updateDocItem
 @ID int,
 @Nazwa NVARCHAR(255),
 @Tresc ntext,
 @KntID int,
 @OpeID int = NULL,
 @StaID int = NULL
AS
UPDATE
 CDN.OfertyDok
SET
 OfD_Nazwa = @Nazwa,
 OfD_Body = @Tresc,
 OfD_KntID = @KntID,
 OfD_OpeModId = @OpeID,
 OfD_StaModId = @StaID,
 OfD_TS_Mod = GETDATE()
WHERE
 OfD_OfDID = @ID

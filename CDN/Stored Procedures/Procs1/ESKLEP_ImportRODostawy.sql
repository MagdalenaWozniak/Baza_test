CREATE PROCEDURE CDN.ESKLEP_ImportRODostawy
  @TrEID      int,
  @TwRID      int,
  @Cecha_DeAId     int = 0,
  @Cecha_Wartosc     nvarchar(255) = ''
AS
  SET NOCOUNT ON
insert into CDN.eSklepROCechy ( ESC_TrEID ,
 ESC_TwRID ,
 ESC_Cecha_DeAId ,
 ESC_Cecha_Wartosc
 )
values
(@TrEID,
  @TwRID,
  @Cecha_DeAId,
  @Cecha_Wartosc
 )
SET NOCOUNT OFF

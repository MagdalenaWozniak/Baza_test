CREATE PROCEDURE [CDN].jdp_getRabat
 @PodId int,
 @TwrId int,
 @TypRabatu smallint output,
 @RabatCena decimal(17,4) output,
 @TypCenyNB smallint output,
 @Waluta char(3) output
AS
SELECT
 @TypRabatu = TypRabatu,
 @RabatCena = RabatCena,
 @TypCenyNB = TypCenyNB,
 @Waluta = Waluta
FROM
 CDN.fnObliczRabat(1, @PodId, @TwrId)

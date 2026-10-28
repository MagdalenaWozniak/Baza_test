-- Ustawienie EAN
CREATE PROCEDURE [CDN].[UstawEAN]
@twrId INT, @EAN INT,@WartoscOd BIGINT, @WartoscDo BIGINT
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE
 @komunikat NVARCHAR(255),
 @dlugosc int,
 @dlugosca int,
 @i int,
 @BarCode_temp_suma_NP int,
 @BarCode_temp_suma_P int,
 @BarCode_temp_CRC int,
 @BarCode_temp_13 NVARCHAR(128),
 @BarCode_temp_12 NVARCHAR(128),
 @Twr_EAN  NVARCHAR(40),
 @znaleziono int,
 @kod NVARCHAR(50)
 SET @komunikat = ''
 SELECT @komunikat = Twr_Kod,@kod = Twr_Kod FROM cdn.Towary WHERE TwR_TwRId=@twrId
 set @Twr_EAN = ''
 select @Twr_EAN = Twr_EAN from cdn.towary where twr_twrid =  @twrId
 if len(@Twr_EAN) <> 0
 begin
 SET @komunikat = @komunikat + SPACE(2) + 'Istnieje już EAN.'
 GOTO KONIEC
 end
if @EAN = 1
  set @dlugosc = 8
else if @EAN = 2
  set @dlugosc = 13
else if @EAN = 3
  set @dlugosc = 14
else
 begin
 SET @komunikat = @komunikat + SPACE(2) + 'Nie wybrano typu EAN.'
 GOTO KONIEC
 end
set @dlugosca = len(@WartoscOd)
set @i = 1
while @i < @dlugosc  - @dlugosca
begin
set @i = @i+1
set @WartoscOd = @WartoscOd*10
end
set @dlugosca = len(@WartoscDo)
set @i = 1
while @i < @dlugosc  - @dlugosca
begin
set @i = @i+1
set @WartoscDo = @WartoscDo*10
end
set @znaleziono = 0
while (@znaleziono = 0)
begin
select
@BarCode_temp_suma_NP =0,
 @BarCode_temp_suma_P =0,
 @BarCode_temp_CRC =0,
 @BarCode_temp_13 ='',
 @BarCode_temp_12 ='',
 @Twr_EAN  =''
if @EAN = 1
begin
SET @BarCode_temp_12 = convert(NVARCHAR(20),@WartoscOd)
SET @BarCode_temp_suma_NP=
cast(SubString(@BarCode_temp_12,1,1)AS int)+
cast(SubString(@BarCode_temp_12,3,1)AS int)+
cast(SubString(@BarCode_temp_12,5,1)AS int)+
cast(SubString(@BarCode_temp_12,7,1)AS int)
SET @BarCode_temp_suma_P=
cast(SubString(@BarCode_temp_12,2,1)AS int)+
cast(SubString(@BarCode_temp_12,4,1)AS int)+
cast(SubString(@BarCode_temp_12,6,1)AS int)
IF ((@BarCode_temp_suma_P+@BarCode_temp_suma_NP*3)%10)=0
SET @BarCode_temp_CRC=0
else
SET @BarCode_temp_CRC=10-((@BarCode_temp_suma_P+@BarCode_temp_suma_NP*3)%10)
SET @BarCode_temp_13=@BarCode_temp_12+cast(@BarCode_temp_CRC AS NVARCHAR(1))
select @Twr_EAN = @BarCode_temp_13
end
if @EAN = 2
begin
SET @BarCode_temp_12 = convert(NVARCHAR(20),@WartoscOd)
SET @BarCode_temp_suma_NP=
cast(SubString(@BarCode_temp_12,1,1)AS int)+
cast(SubString(@BarCode_temp_12,3,1)AS int)+
cast(SubString(@BarCode_temp_12,5,1)AS int)+
cast(SubString(@BarCode_temp_12,7,1)AS int)+
cast(SubString(@BarCode_temp_12,9,1)AS int)+
cast(SubString(@BarCode_temp_12,11,1)AS int)
SET @BarCode_temp_suma_P=
cast(SubString(@BarCode_temp_12,2,1)AS int)+
cast(SubString(@BarCode_temp_12,4,1)AS int)+
cast(SubString(@BarCode_temp_12,6,1)AS int)+
cast(SubString(@BarCode_temp_12,8,1)AS int)+
cast(SubString(@BarCode_temp_12,10,1)AS int)+
cast(SubString(@BarCode_temp_12,12,1)AS int)
IF ((@BarCode_temp_suma_NP+@BarCode_temp_suma_P*3)%10)=0
SET @BarCode_temp_CRC=0
else
SET @BarCode_temp_CRC=10-((@BarCode_temp_suma_NP+@BarCode_temp_suma_P*3)%10)
SET @BarCode_temp_13=@BarCode_temp_12+cast(@BarCode_temp_CRC AS NVARCHAR(1))
select @Twr_EAN = @BarCode_temp_13
end
if @EAN = 3
begin
SET @BarCode_temp_12 = convert(NVARCHAR(20),@WartoscOd)
SET @BarCode_temp_suma_NP=
cast(SubString(@BarCode_temp_12,1,1)AS int)+
cast(SubString(@BarCode_temp_12,3,1)AS int)+
cast(SubString(@BarCode_temp_12,5,1)AS int)+
cast(SubString(@BarCode_temp_12,7,1)AS int)+
cast(SubString(@BarCode_temp_12,9,1)AS int)+
cast(SubString(@BarCode_temp_12,11,1)AS int) +
cast(SubString(@BarCode_temp_12,13,1)AS int)
SET @BarCode_temp_suma_P=
cast(SubString(@BarCode_temp_12,2,1)AS int)+
cast(SubString(@BarCode_temp_12,4,1)AS int)+
cast(SubString(@BarCode_temp_12,6,1)AS int)+
cast(SubString(@BarCode_temp_12,8,1)AS int)+
cast(SubString(@BarCode_temp_12,10,1)AS int)+
cast(SubString(@BarCode_temp_12,12,1)AS int)
IF ((@BarCode_temp_suma_P+@BarCode_temp_suma_NP*3)%10)=0
SET @BarCode_temp_CRC=0
else
SET @BarCode_temp_CRC=10-((@BarCode_temp_suma_P+@BarCode_temp_suma_NP*3)%10)
SET @BarCode_temp_13=@BarCode_temp_12+cast(@BarCode_temp_CRC AS NVARCHAR(1))
select @Twr_EAN = @BarCode_temp_13
end
if not exists (select Twr_EAN from cdn.towary where Twr_EAN = @Twr_EAN )
begin
   update cdn.towary set Twr_EAN = @Twr_EAN, Twr_TS_mod = GetDate()  where twr_twrid =  @twrId
   exec [CDN].[RejestrOperacjiDodaj] 1106 ,0, @twrId, @Kod, 2, '';
   set @znaleziono = 1
end
else
begin
   if len(@WartoscOd) < len(@WartoscOd+1)
   begin
     SET @komunikat = @komunikat + SPACE(2) + 'Koniec zakresu.'
     GOTO KONIEC
   end
   set @WartoscOd = @WartoscOd+1
   if @WartoscDo <> 0 and @WartoscDo < @WartoscOd
   begin
     SET @komunikat = @komunikat + SPACE(2) + 'Koniec zakresu.'
     GOTO KONIEC
   end
end
end
  IF @@ERROR = 0
  SET @komunikat = @komunikat + SPACE(2) + ' ustawiono dane. '
KONIEC:
SET NOCOUNT OFF;
 SELECT @komunikat
END

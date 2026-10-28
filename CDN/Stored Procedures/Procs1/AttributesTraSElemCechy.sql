create procedure CDN.AttributesTraSElemCechy @ID int
as
begin
declare
@Cecha1_kod nvarchar(255), @Cecha1_wartosc nvarchar(255),
@Cecha2_kod nvarchar(255), @Cecha2_wartosc nvarchar(255),
@Cecha3_kod nvarchar(255), @Cecha3_wartosc nvarchar(255),
@Cecha4_kod nvarchar(255), @Cecha4_wartosc nvarchar(255),
@Cecha5_kod nvarchar(255), @Cecha5_wartosc nvarchar(255),
@Cecha6_kod nvarchar(255), @Cecha6_wartosc nvarchar(255),
@Cecha7_kod nvarchar(255), @Cecha7_wartosc nvarchar(255),
@Cecha8_kod nvarchar(255), @Cecha8_wartosc nvarchar(255),
@Cecha9_kod nvarchar(255), @Cecha9_wartosc nvarchar(255),
@Cecha10_kod nvarchar(255),@Cecha10_wartosc nvarchar(255),
@Cecha1_format int,@Cecha2_format int,@Cecha3_format int,
@Cecha4_format int,@Cecha5_format int,@Cecha6_format int,
@Cecha7_format int,@Cecha8_format int,@Cecha9_format int,@Cecha10_format int
select
@Cecha1_kod = TsC_Cecha1_kod , @Cecha1_wartosc = TsC_Cecha1_wartosc , @Cecha1_format = TsC_Cecha1_format,
@Cecha2_kod = TsC_Cecha2_kod , @Cecha2_wartosc = TsC_Cecha2_wartosc , @Cecha2_format = TsC_Cecha2_format,
@Cecha3_kod = TsC_Cecha3_kod , @Cecha3_wartosc = TsC_Cecha3_wartosc , @Cecha3_format = TsC_Cecha3_format,
@Cecha4_kod = TsC_Cecha4_kod , @Cecha4_wartosc = TsC_Cecha4_wartosc , @Cecha4_format = TsC_Cecha4_format,
@Cecha5_kod = TsC_Cecha5_kod , @Cecha5_wartosc = TsC_Cecha5_wartosc , @Cecha5_format = TsC_Cecha5_format,
@Cecha6_kod = TsC_Cecha6_kod , @Cecha6_wartosc = TsC_Cecha6_wartosc , @Cecha6_format = TsC_Cecha6_format,
@Cecha7_kod = TsC_Cecha7_kod , @Cecha5_wartosc = TsC_Cecha7_wartosc , @Cecha7_format = TsC_Cecha7_format,
@Cecha8_kod = TsC_Cecha8_kod , @Cecha5_wartosc = TsC_Cecha8_wartosc , @Cecha8_format = TsC_Cecha8_format,
@Cecha9_kod = TsC_Cecha9_kod , @Cecha5_wartosc = TsC_Cecha9_wartosc , @Cecha9_format = TsC_Cecha9_format,
@Cecha10_kod = TsC_Cecha10_kod , @Cecha5_wartosc = TsC_Cecha10_wartosc , @Cecha10_format = TsC_Cecha10_format
from CDN.TraSElemCechy  where tsc_trsid = @ID
select * from
(select @Cecha1_kod as kod , @Cecha1_wartosc  as wartosc , @Cecha1_format as format union
select @Cecha2_kod  ,@Cecha2_wartosc ,@Cecha2_format union
select @Cecha3_kod , @Cecha3_wartosc ,@Cecha3_format  union
select @Cecha4_kod , @Cecha4_wartosc ,@Cecha4_format union
select @Cecha5_kod , @Cecha5_wartosc ,@Cecha5_format union
select @Cecha6_kod , @Cecha6_wartosc ,@Cecha6_format union
select @Cecha7_kod , @Cecha7_wartosc ,@Cecha7_format union
select @Cecha8_kod , @Cecha8_wartosc ,@Cecha8_format union
select @Cecha9_kod , @Cecha9_wartosc ,@Cecha9_format union
select @Cecha10_kod ,@Cecha10_wartosc,@Cecha10_format  )as wynik
where  format > 0
end

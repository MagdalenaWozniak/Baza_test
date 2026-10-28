create function [CDN].[GetHistoriaAktualna] (@PraId int, @Date DateTime)
returns @Historia table
(
 TypPracownika int,
    PosiadaIdentyfikator int,
 IndywDRA int,
 WlascicielId int
)
as
begin
 declare
  @TypPracownika int,
  @Paszport nvarchar(9),
  @DowodOsobisty nvarchar(12),
  @Pesel nvarchar(11),
  @PosiadaIdentyfikator int,
  @IndywDRA int,
  @WlascicielId int
 select
  @TypPracownika = PRE_TypPracownika,
  @Paszport = PRE_Paszport,
  @DowodOsobisty = PRE_DowOsobisty,
  @Pesel = PRE_Pesel,
  @IndywDRA = PRE_IndywDRA,
  @WlascicielId = PRE_WlascicielId
  from cdn.pracetaty
  where PRE_PraId = @PraId and (PRE_DataOd <= @Date and PRE_DataDo >= @Date)
 if @Paszport = '' and @DowodOsobisty = '' and @Pesel = ''
  set @PosiadaIdentyfikator = 0
 else
  set @PosiadaIdentyfikator = 1
 if @WlascicielId is null
  set @WlascicielId = 0
 insert into @Historia (TypPracownika, PosiadaIdentyfikator, IndywDRA, WlascicielId)
  select @TypPracownika, @PosiadaIdentyfikator, @IndywDRA, @WlascicielId
 return
end

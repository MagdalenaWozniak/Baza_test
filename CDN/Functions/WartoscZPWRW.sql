--* gSkrypt.sOpis = $Tworzenie funkcji cdn.WartoscZPWRW$
create function cdn.WartoscZPWRW ( @id int )
returns decimal (15,2)
begin
declare @wartosc decimal (15,2)
select   @wartosc  = sum(
case when TypDokumentu = 304 then 1 else -1 end *
(isnull ( wartosc,0) )
)
from
(
select wartosc = TrN_WartoscZakupu , TypDokumentu = trn_TypDokumentu
from cdn.[TraNag]
where ( trn_TypDokumentu = 304 or trn_TypDokumentu =303) and trn_RelTrnId =
@id
) as abc
return @wartosc
end

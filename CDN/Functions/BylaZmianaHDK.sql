create function cdn.BylaZmianaHDK(@PreId int, @prevPreId int)
returns int
as
begin
 declare @BylaZmiana int
 select top 1 @BylaZmiana =
  isnull(
   (select
    1
    from
    (
     select
      A.PRE_PreId from cdn.PracEtaty A join cdn.PracEtaty B on B.PRE_PreId = @prevPreId
     where (A.PRE_PreId = @PreId and A.PRE_PreId = @prevPreId)
      or
      (A.PRE_PreId = @PreId and A.PRE_PreId > @prevPreId
       and
       (
        A.PRE_HDKTelefon1 <> B.PRE_HDKTelefon1
        or A.PRE_HDKTelefon2 <> B.PRE_HDKTelefon2
        or A.PRE_TelefonSms <> B.PRE_TelefonSms
        or A.PRE_HDKFax <> B.PRE_HDKFax
        or A.PRE_HDKEmail <> B.PRE_HDKEmail
        or A.PRE_HDKURL <> B.PRE_HDKURL
        or A.PRE_HDKSkrytkaPoczt <> B.PRE_HDKSkrytkaPoczt
        or A.PRE_HDKTeleks <> B.PRE_HDKTeleks
       )
    )) as ContactDetails), '')
 return @BylaZmiana
end

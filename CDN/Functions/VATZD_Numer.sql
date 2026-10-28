CREATE FUNCTION CDN.VATZD_Numer(  )
RETURNS @Result TABLE(DkNId int, VatZdNumer nvarchar(50))
AS
BEGIN
 insert into @Result(DkNId, VatZdNumer)
 select DkN_DkNId,
   'DEK/'+cast(DkN_RokMiesiac%100 as nvarchar(2))+'/'+cast(DkN_RokMiesiac/100 as nvarchar(4))+'/'
   +
            case DkN_Finalna when 0 then
                case DkN_TypDeklar
     when 402 then (CASE DkN_Numer WHEN 0 THEN 'Z' ELSE 'Z'+CAST(DkN_Numer AS VARCHAR(3)) END)
     when 403 then (CASE DkN_Numer WHEN 0 THEN 'S' ELSE 'S'+CAST(DkN_Numer AS VARCHAR(3)) END)
     else '' END
             else
                 case DkN_TypDeklar
     when 402 then (CASE DkN_Numer WHEN 0 THEN 'Z' ELSE 'Z'+CAST(DkN_Numer AS VARCHAR(3)) END)
     when 403 then (CASE DkN_Numer WHEN 0 THEN 'S' ELSE 'S'+CAST(DkN_Numer AS VARCHAR(3)) END)
     else '' END
   end
   +
   '/VATZD'
  from cdn.deklnag
 return
 end

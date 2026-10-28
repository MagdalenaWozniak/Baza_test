CREATE PROCEDURE CDN.KopiujAtrybutyDoVatNag
  @IDZrodla   NVARCHAR(3),
  @SrcID     int,
  @DscID      int
AS
BEGIN
 SET NOCOUNT ON
 set @IDZrodla = UPPER(@IDZrodla)
 if @IDZrodla='TRN'   -- kopiowanie wartości atrybutów z dokumentów TRN
  begin
   insert into CDN.DokAtrybuty
   ( DAt_DeAId,
    DAt_WartoscTxt,
    DAt_TrNId,
    DAt_CRKId,
    DAt_SrZId,
    DAt_VaNID )
   select DAt_DeAId,
       DAt_WartoscTxt,
       NULL,
       NULL,
       NULL,
       @DscID
   from
   CDN.DokAtrybuty
   join CDN.DefAtrybuty on DeA_DeAId=DAt_DeAId
   where DAt_TrNId=@SrcID and DeA_CzyKopiowacDoVAT=1 and DeA_Typ <> 5
  end
 if @IDZrodla='TRN'   -- kopiowanie wartości atrybutów z dokumentów TRN
  begin
   insert into CDN.DokAtrybuty
   ( DAt_DeAId,
    DAt_WartoscTxt,
    DAt_TrNId,
    DAt_CRKId,
    DAt_SrZId,
    DAt_VaNID,
    DAt_TypJPK )
   select DAt_DeAId,
       DAt_WartoscTxt,
       NULL,
       NULL,
       NULL,
       @DscID,
       2
   from
   CDN.DokAtrybuty
   join CDN.DefAtrybuty on DeA_DeAId=DAt_DeAId
   where DAt_TrNId=@SrcID and DeA_CzyKopiowacDoVAT=1 and DeA_Typ = 5
  end
 else if (@IDZrodla='VAT') -- kopiowanie wartości atrybutów z dokumentów VAT
  begin
   insert into CDN.DokAtrybuty
   ( DAt_DeAId,
    DAt_WartoscTxt,
    DAt_TrNId,
    DAt_CRKId,
    DAt_SrZId,
    DAt_VaNID )
   select DAt_DeAId,
       DAt_WartoscTxt,
       NULL,
       NULL,
       NULL,
       @DscID
   from CDN.DokAtrybuty where DAt_VaNId=@SrcID
   end
 else if (@IDZrodla='KNT') -- kopiowanie wartości atrybutów z dokumentów VAT
  begin
   insert into CDN.DokAtrybuty
   ( DAt_DeAId,
    DAt_WartoscTxt,
    DAt_TrNId,
    DAt_CRKId,
    DAt_SrZId,
    DAt_VaNID )
    select  KnA_DeAId,
        KnA_WartoscTxt,
        NULL,
            NULL,
            NULL,
            @DscID
    from
    CDN.KntAtrybuty
    join CDN.DefAtrybuty on KnA_DeAId=DeA_DeAId and KnA_CzyKopiowacDoVAT=1
    where KnA_PodmiotId=@SrcID
  end
 else
  begin
   RAISERROR('##OPT32019##%%1%%=%s##', 16, 1, @IDZrodla)
   if @@ROWCOUNT > 0
    ROLLBACK TRAN
   SET NOCOUNT OFF
   RETURN
  end
 SET NOCOUNT OFF
END

CREATE TABLE [CDN].[KontaZakazy] (
    [AcZ_AcZId] INT IDENTITY (1, 1) NOT NULL,
    [AcZ_AccId] INT NOT NULL,
    [AcZ_OpeId] INT NOT NULL,
    CONSTRAINT [AcZ_Primary] PRIMARY KEY CLUSTERED ([AcZ_AcZId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AcZKonto] FOREIGN KEY ([AcZ_AccId]) REFERENCES [CDN].[Konta] ([Acc_AccId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [AcZKonto]
    ON [CDN].[KontaZakazy]([AcZ_AccId] ASC, [AcZ_OpeId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.KontaZakazy_Delete_Trigger
 ON CDN.KontaZakazy
 FOR DELETE
AS
 SET NOCOUNT ON
 Delete From CDN.KontaZakazy where CDN.KontaZakazy.AcZ_AcZId in (
  select Distinct TODEL.AcZ_AcZId from
  Deleted DEL join CDN.Konta A on (DEL.AcZ_AccId = A.Acc_AccId)
  join CDN.Konta B on (A.Acc_OObId = B.Acc_OObId and B.Acc_NumerIdx like A.Acc_NumerIdx+'.%' and A.Acc_AccId <> B.Acc_AccId)
  join CDN.KontaZakazy TODEL on (TODEL.AcZ_OpeId = DEL.AcZ_OpeId and TODEL.AcZ_AccId = B.Acc_AccId)
 )
 SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.KontaZakazy_Insert_Trigger
 ON CDN.KontaZakazy
 FOR INSERT
AS
 SET NOCOUNT ON
 Insert Into CDN.KontaZakazy (AcZ_AccId, AcZ_OpeId)
 select A.Acc_AccId, Inserted.AcZ_OpeId from
 CDN.Konta A join CDN.Konta Z on (A.Acc_OObId = Z.Acc_OObId and A.Acc_NumerIdx like Z.Acc_NumerIdx+'.%' and A.Acc_AccId <> Z.Acc_AccId)
 join Inserted on (Z.Acc_AccId = Inserted.AcZ_AccId)
 SET NOCOUNT OFF

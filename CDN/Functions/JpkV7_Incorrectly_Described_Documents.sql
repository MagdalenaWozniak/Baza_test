
--* gSkrypt.sOpis = $Tworzenie funkcji CDN.JpkV7_Incorrectly_Described_Documents$
-->
CREATE FUNCTION [CDN].[JpkV7_Incorrectly_Described_Documents](@DataOd DateTime, @DataDo DateTime)
RETURNS @Wyniki TABLE(
REjestrDokumentAndNip nvarchar(255)
)

AS
begin
	declare @rmOd int = 100 * Year(@DataOd) + Month(@DataOd)
	declare @rmDo int = 100 * Year(@DataDo) + Month(@DataDo)

	insert into @Wyniki 
	select Rejest + ', NIP: ' + VaN_KntNipE + ', Nr.dok.: ' + VaN_Dokument as DokumentAndNIP from 
	(
    SELECT 'Rejestr sprzedaży' as Rejest , VaN_Dokument, VaN_KntNipE, van_vanid FROM CDN.RejestrVat_DeklaracjaVAT7_OdDo(@DataOd,@DataDo,0,2,0,1,1,1,100) 
    union all
    SELECT 'Rejestr zakupu' as Rejest , VaN_Dokument, VaN_KntNipE, van_vanid FROM CDN.RejestrVat_DeklaracjaVAT7_OdDo(@DataOd,@DataDo,0,1,0,1,1,1,100) 
	) jpk join (CDN.DokKodyJPKV7 join CDN.KodyJPKV7 on (DKV7_KV7ID=KV7_KV7ID)) on (jpk.VaN_VaNID = DKV7_ParentID and DKV7_ParentTyp = 2)
	where KV7_Rodzaj = 3
	group by rejest, VaN_Dokument, VaN_KntNipE, van_vanid
	having count(van_vanid)>1
	return 
end

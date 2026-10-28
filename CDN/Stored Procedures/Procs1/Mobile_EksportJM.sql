CREATE Procedure [CDN].[Mobile_EksportJM]
AS
BEGIN
        SELECT Gru_GruId,
                   RTRIM(LTRIM(Gru_Nazwa)) as Gru_Nazwa,
                   Gru_Opis
        FROM cdn.grupy WHERE gru_typ = 32
END

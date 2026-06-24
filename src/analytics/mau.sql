WITH tb_daily AS (
    SELECT DISTINCT
    date(substr(DtCriacao, 0 ,11)) AS Dtdia,
    IdCliente

    FROM transacoes
    ORDER BY Dtdia
),

tb_distinct_day AS (

    SELECT
        DISTINCT Dtdia AS dtRef

    FROM tb_daily
),

SELECT  
    t1.dtRef,
    COUNT(DISTINCT IdCliente) AS Mau,
    COUNT(DISTINCT t2.Dtdia)

FROM tb_distinct_day AS t1
    
LEFT JOIN tb_daily AS t2
ON t2.Dtdia <= t1.dtRef
AND julianday(t1.dtRef) - julianday(t1.Dtdia) < 28

GROUP BY t1.dtRef

ORDER BY t1.dtRef ASC


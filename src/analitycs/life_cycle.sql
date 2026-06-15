WITH tb_daily AS (
    SELECT
        DISTINCT
            IdCliente,
            substr(DtCriacao, 0, 11) AS dtDia
        
    FROM transacoes
    WHERE DtCriacao < '{date}'

),

tb_idade AS (
    SELECT
        IdCliente,
        MIN(dtDia) AS dtPrimTransacao,
        MAX(dtDia) AS dtUltiTransacao,
        CAST(MAX(julianday('{date}') - julianday(dtDia)) AS INT) AS qtdeDiasPrimTransacao,
        CAST(MIN(julianday('{date}') - julianday(dtDia)) AS INT) AS qtdeDiasUltiTransacao

    FROM tb_daily

    GROUP BY IdCliente
),

tb_rn AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY Idcliente ORDER BY dtDia DESC) AS rnDia

    FROM tb_daily

),

tb_penultima_ativacao AS (
    SELECT 
        *,
        CAST(julianday('{date}') - julianday(dtDia) AS INT) AS qtdeDiasPenultimaTransacao

    FROM tb_rn
    WHERE rnDia = 2
),

tb_life_cycle AS (

    SELECT 
        t1.*,
        t2.qtdeDiasPenultimaTransacao,
        CASE
            WHEN qtdeDiasPrimTransacao <= 7 THEN '01-CURIOSO'
            WHEN qtdeDiasUltiTransacao <= 7 AND qtdeDiasPenultimaTransacao - qtdeDiasUltiTransacao <= 14 THEN '02-FIEL'
            WHEN qtdeDiasUltiTransacao BETWEEN 8 AND 14 THEN '03-TURISTA'
            WHEN qtdeDiasUltiTransacao BETWEEN 15 AND 28 THEN '04-DESENCATADA'
            WHEN qtdeDiasUltiTransacao > 28 THEN '05-ZUMBI'
            WHEN qtdeDiasUltiTransacao <= 7 AND qtdeDiasPenultimaTransacao - qtdeDiasUltiTransacao BETWEEN 15 AND 28 THEN '02-RECONQUISTADO'
            WHEN qtdeDiasUltiTransacao <= 7 AND qtdeDiasPenultimaTransacao - qtdeDiasUltiTransacao > 28 THEN '02-REBORN'
        END AS descLifeCycle

    FROM tb_idade AS t1

    LEFT JOIN tb_penultima_ativacao AS t2
    ON t1.idCliente = t2.idCliente 
)

SELECT
    DATE('{date}', '-1 day') AS dtRef,
    *

FROM tb_life_cycle




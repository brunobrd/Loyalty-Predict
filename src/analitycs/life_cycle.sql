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
),

tb_freq_valor AS (
    SELECT 
        idCliente,
        COUNT(DISTINCT substr(DtCriacao,0,11)) AS qtdeFrequencia,
        SUM(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPos
        -- SUM(ABS(qtdePontos)) AS qtdePontosPosAbs

    FROM transacoes 

    WHERE DtCriacao < '{date}'
    AND DtCriacao >= DATE('{date}', '-28 days')

    GROUP BY idCliente
    ORDER BY qtdeFrequencia DESC
),

tb_cluster AS (
    SELECT
        *,
        CASE
            WHEN qtdeFrequencia <= 10 AND qtdePontosPos >= 1500 THEN 'HYPER'
            WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 1500 THEN 'EFICIENTE'
            WHEN qtdeFrequencia <= 10 AND qtdePontosPos >= 750 THEN 'INDECISO'
            WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 750 THEN 'ESFORÇADO'
            WHEN qtdeFrequencia < 5 THEN 'LURKER'
            WHEN qtdeFrequencia <= 10 THEN 'PREGUIÇOSO'
            WHEN qtdeFrequencia > 10 THEN 'POTENCIAL'
        END AS cluster
    FROM tb_freq_valor
)

SELECT
    DATE('{date}', '-1 day') AS dtRef,
    t1.*,
    t2.qtdeFrequencia,
    t2.qtdePontosPos,
    t2.cluster
FROM tb_life_cycle AS t1
LEFT JOIN tb_cluster AS t2
ON t1.IdCliente = t2.IdCliente



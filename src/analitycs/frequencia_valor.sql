WITH tb_freq_valor AS (
    SELECT 
        idCliente,
        COUNT(DISTINCT substr(DtCriacao,0,11)) AS qtdeFrequencia,
        SUM(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPos
        -- SUM(ABS(qtdePontos)) AS qtdePontosPosAbs

    FROM transacoes 

    WHERE DtCriacao < '2025-09-01'
    AND DtCriacao >= DATE('2025-09-01', '-28 days')

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
    *
FROM tb_cluster

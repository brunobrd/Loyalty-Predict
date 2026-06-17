WITH tb_transacao AS (
    SELECT
        *,
        SUBSTR(DtCriacao,0,11) AS dtDia

    FROM
        transacoes

    WHERE
        DtCriacao < '2025-10-01'
),

tb_agg_transacao AS (
    SELECT 
        idCliente,
        COUNT(DISTINCT dtDia) AS qtdeAtivacaoVida,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('2025-10-01', '-7 day') THEN dtDia END) AS qtdeAtivacaoVidaD7,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('2025-10-01', '-14 day') THEN dtDia END) AS qtdeAtivacaoVidaD14,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('2025-10-01', '-28 day') THEN dtDia END) AS qtdeAtivacaoVidaD28,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('2025-10-01', '-56 day') THEN dtDia END) AS qtdeAtivacaoVidaD56,

        COUNT(DISTINCT IdTransacao) AS qtdeTransacaoVida,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('2025-10-01', '-7 day') THEN dtDia END) AS qtdeTransacaoVidaD7,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('2025-10-01', '-14 day') THEN dtDia END) AS qtdeTransacaoVidaD14,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('2025-10-01', '-28 day') THEN dtDia END) AS qtdeTransacaoVidaD28,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('2025-10-01', '-56 day') THEN dtDia END) AS qtdeTransacaoVidaD56,

        SUM(qtdePontos) AS saldoVida,
        SUM(CASE WHEN dtDia >= DATE(2025-10-01, '-7 day') THEN qtdePontos ELSE 0 END) AS saldoD7,
        SUM(CASE WHEN dtDia >= DATE(2025-10-01, '-14 day') THEN qtdePontos ELSE 0 END) AS saldoD14,
        SUM(CASE WHEN dtDia >= DATE(2025-10-01, '-28 day') THEN qtdePontos ELSE 0 END) AS saldoD28,
        SUM(CASE WHEN dtDia >= DATE(2025-10-01, '-56 day') THEN qtdePontos ELSE 0 END) AS saldoD56,

        SUM(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVida,
        SUM(CASE WHEN dtDia >= DATE(2025-10-01, '-7 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVidaD7,
        SUM(CASE WHEN dtDia >= DATE(2025-10-01, '-14 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVidaD14,
        SUM(CASE WHEN dtDia >= DATE(2025-10-01, '-28 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVidaD28,
        SUM(CASE WHEN dtDia >= DATE(2025-10-01, '-56 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVidaD56,

        SUM(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVida,
        SUM(CASE WHEN dtDia >= DATE(2025-10-01, '-7 day') AND qtdePontos  < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVidaD7,
        SUM(CASE WHEN dtDia >= DATE(2025-10-01, '-14 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVidaD14,
        SUM(CASE WHEN dtDia >= DATE(2025-10-01, '-28 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVidaD28,
        SUM(CASE WHEN dtDia >= DATE(2025-10-01, '-56 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVidaD56
        
    FROM
        tb_transacao

    GROUP BY
        idCliente
),

tb_agg_calc AS (
    SELECT
        *,
        COALESCE(1.0 * qtdeAtivacaoVida / qtdeTransacaoVida, 0) AS qtdeTransacaoDiaVida,
        COALESCE(1.0 * qtdeAtivacaoVidaD7 / qtdeTransacaoVidaD7, 0) AS qtdeTransacaoDiaVidaD7,
        COALESCE(1.0 * qtdeAtivacaoVidaD14 / qtdeTransacaoVidaD7, 0) AS qtdeTransacaoDiaVidaD14,
        COALESCE(1.0 * qtdeAtivacaoVidaD28 / qtdeTransacaoVidaD7, 0) AS qtdeTransacaoDiaVidaD28,
        COALESCE(1.0 * qtdeAtivacaoVidaD56 / qtdeTransacaoVidaD7, 0) AS qtdeTransacaoDiaVidaD56
    FROM
        tb_agg_transacao
),

tb_horas_dia AS (
    SELECT
        IdCliente,
        dtDia,
        24 * (max(julianday(DtCriacao)) - min(julianday(DtCriacao))) AS duracao

    FROM
        tb_transacao
    GROUP BY
        idCliente, dtDia
),

tb_horas_cliente AS (
    SELECT
        idCliente,
        SUM(duracao) AS qtdeHorasVida,
        SUM(CASE WHEN dtDia >= DATE('2025-10-01', '-7 day') THEN duracao ELSE 0 END) AS qtdeHorasD7,
        SUM(CASE WHEN dtDia >= DATE('2025-10-01', '- 14 day') THEN duracao ELSE 0 END) AS qtdeHorasD14,
        SUM(CASE WHEN dtDia >= DATE('2025-10-01', '- 28 day') THEN duracao ELSE 0 END) AS qtdeHorasD28,
        SUM(CASE WHEN dtDia >= DATE('2025-10-01', '- 56 day') THEN duracao ELSE 0 END) AS qtdeHorasD56
    FROM
        tb_horas_dia

    GROUP BY idCliente
),

tb_lag_dia AS (
    SELECT
        idCliente,
        dtDia,
        LAG(dtDia) OVER (PARTITION BY idCliente ORDER BY dtDia) AS LagDia
    FROM
        tb_horas_dia
),

tb_intervalo_dias AS (
    SELECT
        idCliente,
        AVG(JULIANDAY(dtDia) - JULIANDAY(lagDia)) AS avgIntervaloDiasVida,
        AVG(CASE WHEN dtDia >= DATE('2025-10-01', '-28 day') THEN JULIANDAY(dtDia) - JULIANDAY(lagDia) END) AS avgIntervaloDias28

    FROM
        tb_lag_dia
    GROUP BY

        idCliente
)

SELECT
    t1.*,
    t2.qtdeHorasD7,
    t2.qtdeHorasD14,
    t2.qtdeHorasD28,
    t2.qtdeHorasD56,
    t3.avgIntervaloDiasVida,
    t3.avgIntervaloDias28

FROM
    tb_agg_calc AS t1

LEFT JOIN tb_horas_cliente AS t2
ON t1.idCliente = t2.idCliente

LEFT JOIN tb_intervalo_dias AS t3
ON t1.idCliente = t3.idCliente
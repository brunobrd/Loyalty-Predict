WITH tb_transacao AS (
    SELECT
        *,
        SUBSTR(DtCriacao,0,11) AS dtDia,
        CAST(SUBSTR(DtCriacao,12,2) AS INT) AS dtHora

    FROM
        transacoes

    WHERE
        DtCriacao < '{date}'
),

tb_agg_transacao AS (
    SELECT 
        idCliente,
        MAX(JULIANDAY(DATE('{date}', '-1 day')) - JULIANDAY(DtCriacao)) AS idadeDias,

        COUNT(DISTINCT dtDia) AS qtdeAtivacaoVida,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('{date}', '-7 day') THEN dtDia END) AS qtdeAtivacaoVidaD7,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('{date}', '-14 day') THEN dtDia END) AS qtdeAtivacaoVidaD14,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('{date}', '-28 day') THEN dtDia END) AS qtdeAtivacaoVidaD28,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('{date}', '-56 day') THEN dtDia END) AS qtdeAtivacaoVidaD56,

        COUNT(DISTINCT IdTransacao) AS qtdeTransacaoVida,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('{date}', '-7 day') THEN dtDia END) AS qtdeTransacaoVidaD7,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('{date}', '-14 day') THEN dtDia END) AS qtdeTransacaoVidaD14,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('{date}', '-28 day') THEN dtDia END) AS qtdeTransacaoVidaD28,
        COUNT(DISTINCT CASE WHEN dtDia >= DATE('{date}', '-56 day') THEN dtDia END) AS qtdeTransacaoVidaD56,

        SUM(qtdePontos) AS saldoVida,
        SUM(CASE WHEN dtDia >= DATE('{date}', '-7 day') THEN qtdePontos ELSE 0 END) AS saldoD7,
        SUM(CASE WHEN dtDia >= DATE('{date}', '-14 day') THEN qtdePontos ELSE 0 END) AS saldoD14,
        SUM(CASE WHEN dtDia >= DATE('{date}', '-28 day') THEN qtdePontos ELSE 0 END) AS saldoD28,
        SUM(CASE WHEN dtDia >= DATE('{date}', '-56 day') THEN qtdePontos ELSE 0 END) AS saldoD56,

        SUM(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVida,
        SUM(CASE WHEN dtDia >= DATE('{date}', '-7 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVidaD7,
        SUM(CASE WHEN dtDia >= DATE('{date}', '-14 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVidaD14,
        SUM(CASE WHEN dtDia >= DATE('{date}', '-28 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVidaD28,
        SUM(CASE WHEN dtDia >= DATE('{date}', '-56 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVidaD56,

        SUM(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVida,
        SUM(CASE WHEN dtDia >= DATE('{date}', '-7 day') AND qtdePontos  < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVidaD7,
        SUM(CASE WHEN dtDia >= DATE('{date}', '-14 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVidaD14,
        SUM(CASE WHEN dtDia >= DATE('{date}', '-28 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVidaD28,
        SUM(CASE WHEN dtDia >= DATE('{date}', '-56 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVidaD56,

        COUNT(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END) AS qtdeTransacaoManha,
        COUNT(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END) AS qtdeTransacaoTarde,
        COUNT(CASE WHEN dtHora > 21 OR dtHora < 7 THEN IdTransacao END) AS qtdeTransacaoNoite,

        1. * COUNT(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END) / COUNT(IdTransacao)AS pctTransacaoManha,
        1. * COUNT(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END) / COUNT(IdTransacao)AS pctTransacaoTarde,
        1. * COUNT(CASE WHEN dtHora > 21 OR dtHora < 7 THEN IdTransacao END)/ COUNT(IdTransacao) AS pctTransacaoNoite
        
        
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
        COALESCE(1.0 * qtdeAtivacaoVidaD56 / qtdeTransacaoVidaD7, 0) AS qtdeTransacaoDiaVidaD56,
        COALESCE(1.0 * qtdeAtivacaoVidaD28 / 28, 0) AS pctAtivacaoMau
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
        SUM(CASE WHEN dtDia >= DATE('{date}', '-7 day') THEN duracao ELSE 0 END) AS qtdeHorasD7,
        SUM(CASE WHEN dtDia >= DATE('{date}', '- 14 day') THEN duracao ELSE 0 END) AS qtdeHorasD14,
        SUM(CASE WHEN dtDia >= DATE('{date}', '- 28 day') THEN duracao ELSE 0 END) AS qtdeHorasD28,
        SUM(CASE WHEN dtDia >= DATE('{date}', '- 56 day') THEN duracao ELSE 0 END) AS qtdeHorasD56
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
        AVG(CASE WHEN dtDia >= DATE('{date}', '-28 day') THEN JULIANDAY(dtDia) - JULIANDAY(lagDia) END) AS avgIntervaloDias28

    FROM
        tb_lag_dia
    GROUP BY

        idCliente
),

tb_share_produto AS (
    SELECT
        idCliente,
        1. * COUNT(CASE WHEN DescNomeProduto = 'ChatMessage' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeChatMessage,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Airflow Lover' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeAirflowLover,
        1. * COUNT(CASE WHEN DescNomeProduto = 'R Lover' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeRLover,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Resgatar Ponei' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeResgatarPonei,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Lista de presença' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeListapresenca,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Presença Streak' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdePresencaStreak,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Troca de Pontos StreamElements' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeTrocaPontosStreamElements,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Reembolso: Troca de Pontos StreamElements' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeReembolsoStreamElements,
        1. * COUNT(CASE WHEN DescCategoriaProduto ='rpg' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeRPG,
        1. * COUNT(CASE WHEN DescCategoriaProduto ='churn_model' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeChurnModel
    FROM 
        tb_transacao AS t1
    LEFT JOIN 
        transacao_produto AS t2
    ON 
        t1.IdTransacao = t2.IdTransacao
    LEFT JOIN 
        produtos AS t3
    ON 
        t2.IdProduto = t3.IdProduto
    GROUP BY
        idCliente
),

tb_join AS (
    SELECT
        t1.*,
        t2.qtdeHorasVida,
        t2.qtdeHorasD7,
        t2.qtdeHorasD14,
        t2.qtdeHorasD28,
        t2.qtdeHorasD56,
        t3.avgIntervaloDiasVida,
        t3.avgIntervaloDias28,
        t4.qtdeChatMessage,
        t4.qtdeAirflowLover,
        t4.qtdeRLover,
        t4.qtdeResgatarPonei,
        t4.qtdeListapresenca,
        t4.qtdePresencaStreak,
        t4.qtdeTrocaPontosStreamElements,
        t4.qtdeReembolsoStreamElements,
        t4.qtdeRPG,
        t4.qtdeChurnModel

    FROM
        tb_agg_calc AS t1

    LEFT JOIN 
        tb_horas_cliente AS t2
    ON 
        t1.idCliente = t2.idCliente
    LEFT JOIN 
        tb_intervalo_dias AS t3
    ON 
        t1.idCliente = t3.idCliente
    LEFT JOIN
        tb_share_produto AS t4
    ON
        t1.idCliente = t4.idCliente
)

SELECT 
    DATE('{date}', '-1 day') AS dtRef,
    *
FROM tb_join
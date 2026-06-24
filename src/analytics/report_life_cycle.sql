SELECT
    dtRef,
    descLifeCycle,
    COUNT(*) AS qtdeCliente

FROM
    life_cycle

WHERE descLifeCycle <> 'ZUMBI'
AND dtRef = (SELECT MAX(dtRef) FROM life_cycle)

GROUP BY dtRef, descLifeCycle
ORDER BY dtRef, descLifeCycle;

WITH base AS (
    SELECT 
        measurement_concept_id,
        COUNT(*) AS total_cnt,
        SUM(
            CASE WHEN unit_concept_id IS NULL OR unit_concept_id = 0 
                 THEN 1 ELSE 0 END
        ) AS no_unit_cnt
    FROM @cdmDatabaseSchema.measurement
    WHERE measurement_concept_id > 0
    GROUP BY measurement_concept_id
)
SELECT 
    b.measurement_concept_id,
    c.concept_name,
    b.total_cnt,
    b.no_unit_cnt,
    ROUND(b.no_unit_cnt * 1.0 / b.total_cnt, 4) AS no_unit_rate
FROM base b
JOIN @vocabDatabaseSchema.concept c
    ON c.concept_id = b.measurement_concept_id
ORDER BY no_unit_rate DESC;
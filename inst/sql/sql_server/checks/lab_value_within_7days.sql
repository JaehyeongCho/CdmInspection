WITH target_cohort AS (
    SELECT 
        subject_id,
        cohort_definition_id,
        cohort_start_date AS index_date
    FROM @target_database_schema.@target_cohort_table
),

measure_window AS (
    SELECT
        m.person_id,
        m.measurement_concept_id,
        m.measurement_date
    FROM @cdm_database_schema.measurement m
    WHERE m.measurement_concept_id IN (@concept_ids)
),


measurement_near_index AS (
    SELECT 
        c.cohort_definition_id,
        c.subject_id,
        m.measurement_concept_id
    FROM target_cohort c
    JOIN measure_window m
      ON m.person_id = c.subject_id
     AND m.measurement_date BETWEEN c.index_date - INTERVAL '7 day'
                               AND c.index_date + INTERVAL '7 day'
    GROUP BY 
        c.cohort_definition_id,
        c.subject_id,
        m.measurement_concept_id
)

SELECT
    mni.cohort_definition_id,
    mni.measurement_concept_id,
    c.concept_name,
    COUNT(DISTINCT subject_id) AS measured_subjects
FROM measurement_near_index mni
LEFT JOIN @vocabulary_database_schema.concept c
          ON c.concept_id = mni.measurement_concept_id
GROUP BY mni.cohort_definition_id, mni.measurement_concept_id, c.concept_name
ORDER BY mni.cohort_definition_id, measured_subjects DESC;
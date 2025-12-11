WITH target_cohort AS (
    SELECT
        subject_id,
        cohort_definition_id
    FROM @target_database_schema.@target_cohort_table
),
visit_join AS (
    SELECT DISTINCT
        c.cohort_definition_id,
        c.subject_id,
        v.visit_concept_id
    FROM target_cohort c
    JOIN @cdm_database_schema.visit_occurrence v
      ON v.person_id = c.subject_id
),
agg AS (
    SELECT
        cohort_definition_id,
        visit_concept_id,
        COUNT(DISTINCT subject_id) AS subjects_with_visit
    FROM visit_join
    GROUP BY cohort_definition_id, visit_concept_id
)
SELECT
    a.cohort_definition_id,
    a.visit_concept_id,
    vc.concept_name,
    a.subjects_with_visit
FROM agg a
LEFT JOIN @cdm_database_schema.concept vc
       ON vc.concept_id = a.visit_concept_id
ORDER BY a.cohort_definition_id, subjects_with_visit DESC;
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
    WHERE m.measurement_concept_id IN (3000963,3009542,3007461,3003338,3035941,3024731,3026361,3010813,3006923,3013721,
  3016723,3001123,3027114,4074649,3004501,3019069,3002030,3006504,3022096,3017354,
  4018317,3013682,3024561,3020630,3035995,4097664,4119650,4230636,4008265,3024128,
  4230543,4055811,3011904,3006906,4289475,3014051,3037556,3009261,3022621,3011397,
  4313992,3026910,3005456,3000285,3018572,3017732,4208414,3037426,3021601,3018834,
  3000348,3035350,3035355,3027162,3015183,3020460,3035124,3035583,3010189,4245261,
  3014094,3034426,4175016,3018677,35609812,3027018,4168615,4278658,4135963,36304419,
  3004249,3012888,3025315,3036277,3019284,3005473,4273104,3006490,3004372,3049137,
  3043722,3000259,3036882,3042062,3028475,3002253,3001137,3011483,3022090,3022327,
  3007501,3027820,3033486,3003356,3026327,36306109,3020851,3002587,3000330,3022192,
  3024171,46272018,3033543,3020891,3007070,3026355,3038553)
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

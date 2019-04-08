explore: test_funnel {}
include: "ga_block.view.lkml"
view: test_funnel {
derived_table: {
  sql: SELECT
            CONCAT(CAST(sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(sessions.date AS STRING),'')) as id
          , sessions.fullVisitorId as full_visitor_id
          , sessions.suffix as suffix
          , hits_appInfo.screenName
          ,CASE WHEN hits_appInfo.screenName = 'food_dashboard' THEN 1
                WHEN hits_appInfo.screenName = 'food_browse_recipes' THEN 2
                WHEN  hits_appInfo.screenName like 'food_browse_recipes_%' THEN 3 END
            AS page_sequence
          , LAG(
           CASE WHEN hits_appInfo.screenName = 'food_dashboard' THEN 1
                WHEN hits_appInfo.screenName = 'food_browse_recipes' THEN 2
                WHEN  hits_appInfo.screenName like 'food_browse_recipes_%' THEN 3 END
              )
              OVER (PARTITION BY sessions.fullVisitorId ORDER BY hits.hitNumber) AS previous_page_sequence
         , LAG(
                CASE WHEN hits_appInfo.screenName = 'food_dashboard' THEN 1
                WHEN hits_appInfo.screenName = 'food_browse_recipes' THEN 2
                WHEN  hits_appInfo.screenName like 'food_browse_recipes_%' THEN 3 END, 2
              )
              OVER (PARTITION BY sessions.fullVisitorId ORDER BY hits.hitNumber) AS previous_page_sequence_2
         , LAG(
               CASE WHEN hits_appInfo.screenName = 'food_dashboard' THEN 1
                WHEN hits_appInfo.screenName = 'food_browse_recipes' THEN 2
                WHEN  hits_appInfo.screenName like 'food_browse_recipes_%' THEN 3 END, 3
              )
              OVER (PARTITION BY sessions.fullVisitorId ORDER BY hits.hitNumber) AS previous_page_sequence_3
         FROM (SELECT * FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions` WHERE SUBSTR(suffix,0,1) != 'i')  AS
         sessions
          LEFT JOIN UNNEST(sessions.hits) as hits
          LEFT JOIN UNNEST([hits.appInfo]) as hits_appInfo
          LEFT JOIN UNNEST([hits.contentGroup]) as hits_contentGroup

        WHERE ((((CAST(CONCAT(SUBSTR(sessions.suffix,0,4),'-',SUBSTR(sessions.suffix,5,2),'-',SUBSTR(sessions.suffix,7,2)) AS TIMESTAMP) ) >= ((TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY), INTERVAL -3 DAY)), 'America/New_York'))) AND (CAST(CONCAT(SUBSTR(sessions.suffix,0,4),'-',SUBSTR(sessions.suffix,5,2),'-',SUBSTR(sessions.suffix,7,2)) AS TIMESTAMP) ) < ((TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY), INTERVAL -3 DAY), INTERVAL 3 DAY)), 'America/New_York'))))))--       AND (hits_appInfo.screenName = 'food_dashboard')
        AND (((((TIMESTAMP((CAST(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_SECONDS(sessions.visitStarttime) , 'America/New_York')) AS DATE)))) ) >= ((TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY), INTERVAL -2 DAY))) AND ((TIMESTAMP((CAST(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_SECONDS(sessions.visitStarttime) , 'America/New_York')) AS DATE)))) ) < ((TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY), INTERVAL -2 DAY), INTERVAL 3 DAY))))))


-- AND
-- CASE WHEN hits_appInfo.screenName = 'food_dashboard' THEN 1
--                WHEN hits_appInfo.screenName = 'food_browse_recipes' THEN 2
--                WHEN  REGEXP_CONTAINS(hits_appInfo.screenName , 'food_browse_recipes_*') THEN 3
--           END IS NOT NULL
-- AND sessions.fullVisitorId = '10058377160071560302'


 ;;
}


dimension: id {
  type: string
  sql: ${TABLE}.id ;;
}

dimension: full_visitor_id {
  type: string
  sql: ${TABLE}.full_visitor_id ;;
}

dimension: suffix {
  type: string
  sql: ${TABLE}.suffix ;;
}

dimension: screen_name {
  type: string
  sql: ${TABLE}.screenName ;;
}

dimension: page_sequence {
  type: number
  sql: ${TABLE}.page_sequence ;;
}

dimension: previous_page_sequence {
  type: number
  sql: ${TABLE}.previous_page_sequence ;;
}

dimension: previous_page_sequence_2 {
  type: number
  sql: ${TABLE}.previous_page_sequence_2 ;;
}

dimension: previous_page_sequence_3 {
  type: number
  sql: ${TABLE}.previous_page_sequence_3 ;;
}

dimension: preceeded_by_funnel_step {
  type: yesno
  sql: ${page_sequence} - ${previous_page_sequence} = 1 ;;
}

dimension: preceeded_by_funnel_step_2 {
  type: yesno
  sql: ${page_sequence} - ${previous_page_sequence_2} = 2 ;;
}

dimension: preceeded_by_funnel_step_3 {
  type: yesno
  sql: ${page_sequence} - ${previous_page_sequence_3} = 3 ;;
}


measure: count {
  type: count
  drill_fields: [detail*]
}

measure: screen_1_hits {
  type: count_distinct
  sql: ${full_visitor_id} ;;
  filters: {
    field: "page_sequence"
    value: "1"
  }
}
  measure: screen_2_hits {
    type: count_distinct
    sql: ${full_visitor_id} ;;
    filters: {
      field: "page_sequence"
      value: "2"
    }
    filters: {
      field: preceeded_by_funnel_step
      value: "yes"
    }
  }

  measure: screen_3_hits {
    type: count_distinct
    sql: ${full_visitor_id} ;;
    filters: {
      field: "page_sequence"
      value: "3"
    }
    filters: {
      field: preceeded_by_funnel_step
      value: "yes"
    }
    filters: {
      field: preceeded_by_funnel_step_2
      value: "yes"
    }
  }


set: detail {
  fields: [
    id,
    full_visitor_id,
    suffix,
    screen_name,
    page_sequence,
    previous_page_sequence
  ]
}
}

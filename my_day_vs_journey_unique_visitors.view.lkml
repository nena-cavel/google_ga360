view: my_day_vs_journey_unique_visitors {
  derived_table: {
    sql_trigger_value: SELECT EXTRACT(WEEK FROM timestamp_sub(CURRENT_timestamp(), interval 20 hour)) AS ONCEPERWEEK ;;
    sql: WITH funnel_growth_dashboard AS (SELECT CONCAT(CAST(sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(sessions.date AS STRING),'')) as id
    , sessions.fullVisitorId as full_visitor_id
    , sessions.suffix as suffix
    , MIN(
       CASE WHEN REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:plan$')
       THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
       ELSE NULL END
      ) AS event_1
    , MIN(
      CASE WHEN
        REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:registration$')
       THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
       ELSE NULL END
      ) AS event_2_first
    , MAX(
      CASE WHEN
        REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:registration$')
       THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
       ELSE NULL END
      ) AS event_2_last
    , MIN(
      CASE WHEN
      REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:payment$')
       THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
       ELSE NULL END
      ) AS event_3_first
    , MAX(
      CASE WHEN
       REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:payment$')
      THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
       ELSE NULL END
      ) AS event_3_last
    , MIN(
      CASE WHEN
      REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:review$')
       THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
       ELSE NULL END
      ) AS event_4_first
    , MAX(
      CASE WHEN
      REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:review$')
       THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
       ELSE NULL END
      ) AS event_4_last
       , MIN(
      CASE WHEN
      REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:confirmation$')
       THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
       ELSE NULL END
      ) AS event_5_first
    , MAX(
      CASE WHEN
      REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:confirmation$')
       THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
       ELSE NULL END
      ) AS event_5_last
   FROM (SELECT * FROM `wwi-data-playground-3.wwi_processed_data_std_views.ga_session_view` WHERE SUBSTR(suffix,0,1) != 'i')  AS sessions
    LEFT JOIN UNNEST(sessions.hits) as hits
    LEFT JOIN UNNEST([hits.page]) as hits_page
    LEFT JOIN UNNEST([hits.contentGroup]) as hits_contentGroup
  WHERE ((( TIMESTAMP_SECONDS(sessions.visitStarttime) ) >= ((TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY), INTERVAL -7 DAY)), 'America/New_York'))) AND ( TIMESTAMP_SECONDS(sessions.visitStarttime) ) < ((TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY), INTERVAL -7 DAY), INTERVAL 7 DAY)), 'America/New_York')))))
   GROUP BY 1,2,3
    )
  SELECt
          case when hits_appInfo.screenName = 'food_dashboard' then 'my_day'
               else 'journey' end as which_tab,
          count(distinct ga_sessions.fullVisitorId) AS unique_visitors
  -- SELECT
  --  hits_appInfo.screenName AS hits_appinfo_screenname_1,
  --  ga_sessions.fullVisitorId AS ga_sessions_fullvisitorid_1
  FROM (SELECT * FROM `wwi-data-playground-3.wwi_processed_data_std_views.ga_session_view` WHERE SUBSTR(suffix,0,1) != 'i')  AS ga_sessions
  LEFT JOIN UNNEST([ga_sessions.geoNetwork]) as geoNetwork
  LEFT JOIN UNNEST(ga_sessions.hits) as hits
  LEFT JOIN UNNEST([hits.appInfo]) as hits_appInfo
  INNER JOIN funnel_growth_dashboard ON (CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(ga_sessions.date AS STRING),'')))=funnel_growth_dashboard.id

  WHERE ((((CAST(CONCAT(SUBSTR(ga_sessions.suffix,0,4),'-',SUBSTR(ga_sessions.suffix,5,2),'-',SUBSTR(ga_sessions.suffix,7,2)) AS TIMESTAMP) ) >= ((TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY), INTERVAL -8 DAY)), 'America/New_York'))) AND (CAST(CONCAT(SUBSTR(ga_sessions.suffix,0,4),'-',SUBSTR(ga_sessions.suffix,5,2),'-',SUBSTR(ga_sessions.suffix,7,2)) AS TIMESTAMP) ) < ((TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY), INTERVAL -8 DAY), INTERVAL 8 DAY)), 'America/New_York')))))) AND (geoNetwork.country = 'United States') AND (hits_appInfo.screenName LIKE '%journey%' OR hits_appInfo.screenName = 'food_dashboard')
  GROUP BY 1
      LIMIT 500
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: which_tab {
    type: string
    sql: ${TABLE}.which_tab ;;
  }

  measure: unique_visitors {
    type: max
    sql: ${TABLE}.unique_visitors ;;
  }

  set: detail {
    fields: [which_tab, unique_visitors]
  }
}

view: prize_screen_view_counts_bythelake {
  derived_table: {
    sql: SELECT
        replace(replace(substr(hits_appInfo.screenName,8,length(hits_appInfo.screenName)-13),'__',' '),'_',' ') as Reward,
        COALESCE(ROUND(COALESCE(CAST( ( SUM(DISTINCT (CAST(ROUND(COALESCE(totals.screenViews ,0)*(1/1000*1.0), 9) AS NUMERIC) + (cast(cast(concat('0x', substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(ga_sessions.visitId AS STRING),'')))  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(ga_sessions.visitId AS STRING),'')))  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001 )) - SUM(DISTINCT (cast(cast(concat('0x', substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(ga_sessions.visitId AS STRING),'')))  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(ga_sessions.visitId AS STRING),'')))  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001) )  / (1/1000*1.0) AS FLOAT64), 0), 6), 0) AS total_screen_views,
        COALESCE(ROUND(COALESCE(CAST( ( SUM(DISTINCT (CAST(ROUND(COALESCE(totals.uniqueScreenViews ,0)*(1/1000*1.0), 9) AS NUMERIC) + (cast(cast(concat('0x', substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(ga_sessions.visitId AS STRING),'')))  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(ga_sessions.visitId AS STRING),'')))  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001 )) - SUM(DISTINCT (cast(cast(concat('0x', substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(ga_sessions.visitId AS STRING),'')))  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(ga_sessions.visitId AS STRING),'')))  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001) )  / (1/1000*1.0) AS FLOAT64), 0), 6), 0) AS unique_screen_views,

        concat(cast(cast(floor(COALESCE(ROUND(COALESCE(CAST( ( SUM(DISTINCT (CAST(ROUND(COALESCE(totals.timeOnScreen ,0)*(1/1000*1.0), 9) AS NUMERIC) +
          (cast(cast(concat('0x', substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(ga_sessions.visitId AS STRING),'')))
           AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING),
           '|', COALESCE(CAST(ga_sessions.visitId AS STRING),'')))  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001 )) -
           SUM(DISTINCT (cast(cast(concat('0x', substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(ga_sessions.visitId AS STRING),'')))
           AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|',
           COALESCE(CAST(ga_sessions.visitId AS STRING),'')))  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001) )  / (60/1000*1.0) AS FLOAT64), 0), 6), 0)/60.0) as int64)
           as string), ":",

           format("%02d", mod(cast(COALESCE(ROUND(COALESCE(CAST( ( SUM(DISTINCT (CAST(ROUND(COALESCE(totals.timeOnScreen ,0)*(1/1000*1.0), 9) AS NUMERIC) +
           (cast(cast(concat('0x', substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|',
            COALESCE(CAST(ga_sessions.visitId AS STRING),'')))  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 +
            cast(cast(concat('0x', substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|',
            COALESCE(CAST(ga_sessions.visitId AS STRING),'')))  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001 ))
            - SUM(DISTINCT (cast(cast(concat('0x', substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|',
            COALESCE(CAST(ga_sessions.visitId AS STRING),'')))  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x',
            substr(to_hex(md5(CAST((CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(ga_sessions.visitId AS STRING),'')))  AS STRING))), 16, 8))
            as int64) as numeric)) * 0.000000001) )  / (60/1000*1.0) AS FLOAT64), 0), 6), 0) as int64),60))) AS time_on_screen
      FROM (SELECT * FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions` WHERE SUBSTR(suffix,0,1) != 'i')  AS ga_sessions
      LEFT JOIN UNNEST([ga_sessions.totals]) as totals
      LEFT JOIN UNNEST(ga_sessions.hits) as hits
      LEFT JOIN UNNEST([hits.appInfo]) as hits_appInfo

      WHERE ((((CAST(CONCAT(SUBSTR(ga_sessions.suffix,0,4),'-',SUBSTR(ga_sessions.suffix,5,2),'-',SUBSTR(ga_sessions.suffix,7,2)) AS TIMESTAMP) ) >= ((TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY), INTERVAL -7 DAY)), 'America/New_York'))) AND (CAST(CONCAT(SUBSTR(ga_sessions.suffix,0,4),'-',SUBSTR(ga_sessions.suffix,5,2),'-',SUBSTR(ga_sessions.suffix,7,2)) AS TIMESTAMP) ) < ((TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY), INTERVAL -7 DAY), INTERVAL 7 DAY)), 'America/New_York')))))) AND (hits_appInfo.screenName LIKE 'rewards\\_%\\_en\\_us')
      GROUP BY Reward
      ORDER BY total_screen_views desc
      LIMIT 500
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: reward {
    type: string
    sql: ${TABLE}.Reward ;;
  }

  dimension: total_screen_views {
    type: number
    sql: ${TABLE}.total_screen_views ;;
  }

  dimension: unique_screen_views {
    type: number
    sql: ${TABLE}.unique_screen_views ;;
  }

  dimension: time_on_screen {
    type: string
    sql: ${TABLE}.time_on_screen ;;
  }

  set: detail {
    fields: [reward, total_screen_views, unique_screen_views, time_on_screen]
  }
}

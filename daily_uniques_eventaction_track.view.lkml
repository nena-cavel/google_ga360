view: daily_uniques_eventaction_track {
  derived_table: {
    sql_trigger_value: select date(timestamp_sub(current_timestamp(), interval 10 hour)) ;;
    sql: #standardsql
SELECT
  CAST(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_SECONDS(ga_sessions.visitStarttime) , 'America/New_York') AS DATE) AS session_date,
  COUNT(DISTINCT ga_sessions.fullVisitorId ) AS unique_visitors
FROM (SELECT * FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions` WHERE SUBSTR(suffix,0,1) != 'i')  AS ga_sessions
LEFT JOIN UNNEST([ga_sessions.device]) as device
LEFT JOIN UNNEST(ga_sessions.hits) as hits
LEFT JOIN UNNEST([hits.eventInfo]) as hits_eventInfo

WHERE ((CAST(CONCAT(SUBSTR(ga_sessions.suffix,0,4),'-',SUBSTR(ga_sessions.suffix,5,2),'-',SUBSTR(ga_sessions.suffix,7,2)) AS TIMESTAMP)  >= TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP('2018-10-20 12:00:00')), 'America/New_York')))
AND (((TIMESTAMP((CAST(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_SECONDS(ga_sessions.visitStarttime) , 'America/New_York')) AS DATE))))  >= '2018-10-22'))
AND (((SELECT value FROM UNNEST(ga_sessions.customDimensions) WHERE index=53) = 'us'))
AND (device.browser = 'GoogleAnalytics')
AND device.isMobile
AND (hits_eventInfo.eventAction LIKE '%track%')
GROUP BY 1

union distinct

select *
from `wwi-data-playground-3.jleavitt.daily_uniques_eventaction_track_copy2`

ORDER BY 1 desc ;;
  }

    dimension: session_date {
      label: "Session Date"
      type: date
    }
    measure: baseline {
      sql:  select 627723  ;;
      type: average
    }

    measure: unique_visitors {
      label: "Unique Visitors"
      type: max
    }
  }

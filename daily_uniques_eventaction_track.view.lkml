view: daily_uniques_eventaction_track {
  derived_table: {
    sql_trigger_value: select date(timestamp_sub(current_timestamp(), interval 6 hour)) ;;
    sql: #standardsql
SELECT
  CAST(timestamp(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_SECONDS(ga_sessions.visitStarttime) , 'America/New_York')) AS DATE) AS session_date,
  COUNT(DISTINCT ga_sessions.fullVisitorId ) AS unique_visitors
FROM (SELECT * FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions` WHERE SUBSTR(suffix,0,1) != 'i')  AS ga_sessions
LEFT JOIN UNNEST([ga_sessions.device]) as device
LEFT JOIN UNNEST(ga_sessions.hits) as hits
LEFT JOIN UNNEST([hits.eventInfo]) as hits_eventInfo

WHERE ((CAST(CONCAT(SUBSTR(ga_sessions.suffix,0,4),'-',SUBSTR(ga_sessions.suffix,5,2),'-',SUBSTR(ga_sessions.suffix,7,2)) AS TIMESTAMP)  >= TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP('2018-10-20 12:00:00')), 'America/New_York')))
AND CAST(timestamp(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_SECONDS(ga_sessions.visitStarttime) , 'America/New_York')) AS DATE)  >= '2018-10-22'
AND (((SELECT value FROM UNNEST(ga_sessions.customDimensions) WHERE index=53) = 'us'))
AND (device.browser = 'GoogleAnalytics')
AND device.isMobile
AND (hits_eventInfo.eventAction LIKE '%track%')
GROUP BY 1

union distinct

select *
from `wwi-data-playground-3.jleavitt.daily_uniques_eventaction_track_base`

ORDER BY 1 desc ;;
  }

#     dimension: session_date {
#       label: "Session Date"
#       type: date
#     }

  dimension_group: session_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.session_date ;;
  }

  measure: baseline {
      sql:  642154  ;;
      value_format_name: none
      type: average
    }

  measure: baseline_3mos_percentage {
    sql: 0.1834695353 ;;
    value_format: " "
    type:  average
  }

  measure: baseline_1yr_percentage {
    sql: 0.2173804809 ;;
    value_format: " "
    type:  average
  }

  measure: baseline_3mos {
    sql: 528206  ;;
    value_format_name: none
    type: average
  }

  measure: unique_visitors {
      label: "Unique Visitors"
      value_format_name: thousands
      type: average
    }
  }

named_value_format: none {
  value_format: " "
}

named_value_format: millions {
  value_format: "0.0,,\"M\""
}

named_value_format: thousands {
  value_format: "0,\"K\""
}

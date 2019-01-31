view: connect_penetration_daily {
  derived_table: {
    sql: SELECT DISTINCT
(EXTRACT(date FROM TIMESTAMP_MILLIS((visitStartTime*1000)+h.time))) as generated_date,
(CASE WHEN cd.index=53 then cd.value else null end) as region,
(CASE WHEN regexp_contains(h.appinfo.screenName, '^connect_') then fullvisitorID END) AS connect_traffic,
(CASE WHEN regexp_contains(h.appinfo.screenName, 'food_dashboard') then fullvisitorID end) AS all_users
FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions` , unnest(customdimensions) as cd, unnest(hits) as h
WHERE SUFFIX Between '20180901'AND '20181230'
and regexp_contains((CASE WHEN cd.index=53 then cd.value else null end), 'us|ca|br|gb|se|fr|de|be|nl|ch|au|nz')
group by 1 ,2,3,4 ;;
  }

dimension_group: date_visited {
  timeframes: [date,raw,week]
  datatype: datetime  # was date, but support changed it to datetime
  type: time
  convert_tz: no
  sql: timestamp(${TABLE}.generated_date) ;;
  }

dimension: region {
  type: string
  sql: ${TABLE}.region ;;
}

measure: connect_users {
  type:count_distinct
  sql: ${TABLE}.connect_traffic ;;
}

measure: all_users {
  type: count_distinct
  sql: ${TABLE}.all_users ;;
}
}

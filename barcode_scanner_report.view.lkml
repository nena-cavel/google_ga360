view: barcode_scanner_report {
  derived_table: {
    sql:SELECT DISTINCT
date as gen_date,
(CASE WHEN cd.index=53 then cd.value END) AS region,
device.operatingSystem AS os ,
h.eventinfo.eventaction as scan_name,
CONCAT(fullvisitorid, CAST(visitId AS STRING), CAST(h.hitnumber AS STRING)) as total_events
FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions`, unnest(customdimensions) as cd, unnest(hits) as h
INNER JOIN
unnest(GENERATE_DATE_ARRAY('2018-05-05', '2018-06-30', INTERVAL 7 day)) as date
ON EXTRACT( WEEK FROM TIMESTAMP_MILLIS((visitStartTime*1000)+h.time)) = extract(week from date)
WHERE SUFFIX Between '20180506'AND '20180631'
AND REGEXP_CONTAINS(h.eventinfo.eventaction, 'barcodescanner_fooddatabase|barcodescanner_crowdsourced|barcodescanner_crowdsourceditem|barcodescanner_foodsnondatabase')
AND (CASE WHEN cd.index=53 then cd.value END) is not null
GROUP BY 1,2,3,4,5 ;;
  }
  dimension_group: week_date {
    type: time
    timeframes: [date,week,week_of_year,raw]
    sql: timestamp(${TABLE}.gen_date) ;;
  }

dimension: region {
  type: string
  sql: ${TABLE}.region ;;
}

dimension: operating_system {
  type: string
  sql: ${TABLE}.operating_system ;;
}

dimension: scan_name {
  type: string
  sql: ${TABLE}.scan_name ;;
}

measure: total_events {
  type: count_distinct
  sql: ${TABLE}.total_events ;;
}
}

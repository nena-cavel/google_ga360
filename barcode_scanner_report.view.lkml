view: barcode_scanner_report {
  derived_table: {
    persist_for: "72 hours"
    sql:SELECT DISTINCT
date as gen_date,
(CASE WHEN cd.index=53 then cd.value END) AS region,
device.operatingSystem AS os ,
h.eventinfo.eventaction as scan_name,
CONCAT(fullvisitorid, CAST(visitId AS STRING), CAST(h.hitnumber AS STRING)) as total_events
FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions`, unnest(customdimensions) as cd, unnest(hits) as h
INNER JOIN
unnest(GENERATE_DATE_ARRAY('2018-01-01', '2019-12-31', INTERVAL 7 day)) as date
ON (EXTRACT( WEEK FROM TIMESTAMP_MILLIS((visitStartTime*1000)+h.time)) = extract(week from date)
  AND EXTRACT( year FROM TIMESTAMP_MILLIS((visitStartTime*1000)+h.time)) = extract(year from date) )
WHERE SUFFIX Between '20180101'AND '20191231'
AND REGEXP_CONTAINS(h.eventinfo.eventaction, 'barcodescanner_fooddatabase|barcodescanner_crowdsourced|barcodescanner_crowdsourceditem|barcodescanner_foodsnondatabase')
AND (CASE WHEN cd.index=53 then cd.value END) is not null
GROUP BY 1,2,3,4,5 ;;
  }
  dimension_group: week_date {
    type: time
    convert_tz: no
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

dimension: scan_name_group {
  type: string
  sql: (CASE WHEN ${TABLE}.scan_name = "barcodescanner_crowdsourced"
  THEN "Crowdsourced"
  WHEN ${TABLE}.scan_name="barcodescanner_crowdsourceditem" THEN "Crowdsourced"
  WHEN ${TABLE}.scan_name= "barcodescanner_fooddatabase" THEN "WW Verified Food"
  WHEN ${TABLE}.scan_name="barcodescanner_foodsnondatabase" THEN "Not in DB"
  end)
  ;;
}

measure: total_events {
  type: count_distinct
  sql: ${TABLE}.total_events ;;
  value_format: "0.000,,\" M\""
}
}

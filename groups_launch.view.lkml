view: groups_launch {
  derived_table: {
    sql:
SELECT DISTINCT
(case when hcd.index=85 THEN hcd.value ELSE NULL END) as group_id,
h.eventinfo.eventaction as event,
geonetwork.city as city ,
geoNetwork.country as country,
device.language as language_market ,
tIMESTAMP_MILLIS(visitStartTime*1000) as gen_time,
(case when cd.index=12 then cd.value END) as users,
COUNT(DISTINCT CONCAT( CAST(visitId AS STRING), CAST(h.hitnumber AS STRING))) as total_events,
row_number()OVER(PARTITION BY hcd.value,h.eventinfo.eventAction ORDER BY tIMESTAMP_MILLIS(visitStartTime*1000)) as row_rank,
sum( CASE WHEN tIMESTAMP_MILLIS(visitStartTime*1000) >timestamp('2018-11-11 17:59:01') then 1 ELSE 0 END) OVER(PARTITION BY hcd.value,h.eventinfo.eventAction ORDER BY tIMESTAMP_MILLIS(visitStartTime*1000)) as launch_numbering,
sum( CASE WHEN tIMESTAMP_MILLIS(visitStartTime*1000) >timestamp('2018-11-29 17:59:01') then 1 ELSE 0 END) OVER(PARTITION BY hcd.value,h.eventinfo.eventAction ORDER BY tIMESTAMP_MILLIS(visitStartTime*1000)) as intl_launch_numbering
FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions`, unnest(customdimensions) as cd, unnest(hits) as h, unnest(h.customdimensions) as hcd
WHERE SUFFIX BETWEEN '20181111' AND '20181231'
and length(case when hcd.index=85 THEN hcd.value ELSE NULL END)>1
AND regexp_contains(h.eventinfo.eventAction, 'connect_')
AND (case when cd.index=12 then cd.value END) IS NOT NULL
Group by 1,hcd.index,hcd.value,2,visitStartTime,3,4,5,7
ORDER BY 1,3;;
  }

dimension: city {
  type: string
  sql: ${TABLE}.city ;;
}

dimension: country {
  type: string
  sql: ${TABLE}.country ;;
}

dimension: group_id {
  type: string
  label_from_parameter: group_id_name
  sql: ${TABLE}.group_id ;;
}
dimension: events {
  type: string
  sql: ${TABLE}.event ;;
  }
dimension_group: gen_time {
  type: time
  timeframes: [time,date,raw]
  datatype: timestamp
  convert_tz: no
  sql: ${TABLE}.gen_time ;;
  }



measure: event_count {
  type: sum
  sql: ${TABLE}.total_events ;;
}

measure: event_count_count {
  type: count
  #sql: ${TABLE}.event ;;
}


 measure: post_count {
  type: number
  sql: if((${event_count})>1,1,0) ;;
}
measure: running_post_count {
  type: running_total
  sql: ${event_count} ;;
}

measure: users {
  type: count_distinct
  sql: ${TABLE}.users ;;
}

dimension: member_uuid {
  type: string
  sql: ${TABLE}.users ;;
}


dimension: row_number {
  type: number
  sql: ${TABLE}.row_rank ;;
}

dimension: launch_numbering {
  type: number
  sql: ${TABLE}.launch_numbering ;;
}

dimension: intl_launch_numbering {
  type: number
  sql: ${TABLE}.intl_launch_numbering ;;
}

  dimension_group: second_post {
    type:time
    timeframes: [time,date,raw]
    datatype: timestamp
    convert_tz: no
    sql:(CASE WHEN (${row_number}=2 AND ${events}='connect_post') THEN ${TABLE}.gen_time else null end);;
  }
 measure: second_post_test {
    type:time
    timeframes: [time,date,raw]
    convert_tz: no
    sql:min(CASE WHEN (${row_number}=2 AND ${events}='connect_post' ) THEN ${TABLE}.gen_time end);;
  }

  measure: second_post_launch {
    type:time
    timeframes: [time,date,raw]
    convert_tz: no
    sql:min(CASE WHEN (${launch_numbering}=2 AND ${events}='connect_post' ) THEN ${TABLE}.gen_time end);;
  }

  measure: second_post_intl_launch {
    type:time
    timeframes: [time,date,raw]
    convert_tz: no
    sql:min(CASE WHEN (${intl_launch_numbering}=2 AND ${events}='connect_post' ) THEN ${TABLE}.gen_time end);;
  }

  measure: first_visit_test {
    type: time
    timeframes: [time,date,raw]
    convert_tz: no
    sql:min(CASE WHEN (${row_number}=1 AND ${events} is not null) THEN ${TABLE}.gen_time else null end);;
  }


  dimension_group: first_visit {
    type: time
   timeframes: [time,date,raw]
  datatype: timestamp
    convert_tz: no
    sql:(CASE WHEN (${row_number}=1 AND ${events} is not null) THEN ${TABLE}.gen_time else null end);;
  }
parameter: group_id_name {
  type: string
  allowed_value: {
    label: "Running"
    value: "ec633201-3810-41ba-998d-d661f14aa6ae"
  }
}



  dimension: time_to_2_posts {
    type: date_hour
    datatype: timestamp
    convert_tz: no
    sql: diff_hours((cast(${first_visit_time} as time)-(cast(${second_post_time} as time)) ;;
  }

  dimension: date_diff {
    type: number
    sql: TIMESTAMP_DIFF(${first_visit_raw}, ${second_post_raw},MINUTE) ;;
  }
  dimension: date_diff_time {
    type: number
    sql: TIME_DIFF(CAST(${first_visit_time} AS TIME), CAST(${second_post_time} AS TIME),MINUTE) ;;
  }

}

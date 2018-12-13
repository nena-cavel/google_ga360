view: groups_kpis {
  derived_table: {
    sql:
   SELECT DISTINCT
(case when hcd.index=85 THEN hcd.value ELSE NULL END) as group_id,
device.language as market,
h.appinfo.screenname as screen_name,
extract(week from tIMESTAMP_MILLIS(visitStartTime*1000)) as gen_time,
(case when cd.index=12 then cd.value END) as users,
COUNT(DISTINCT CONCAT( CAST(visitId AS STRING), CAST(h.hitnumber AS STRING))) as total_events

FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions`, unnest(customdimensions) as cd, unnest(hits) as h, unnest(h.customdimensions) as hcd
WHERE SUFFIX BETWEEN '20181111' AND '20181231'
AND (case when cd.index=12 then cd.value END) IS NOT NULL

Group by 1,2,3,4,5
;;
  }

dimension: session_date {
    type: number
    sql: (${TABLE}.gen_time);;
  }
dimension: group_id {
  type: string
  sql: ${TABLE}.group_id ;;
}
dimension: market {
  type: string
  sql: ${TABLE}.market ;;
}
measure: users {
  type: count_distinct
  sql: ${TABLE}.users ;;
}

measure: groups_users {

  type: count_distinct
  sql: (CASE WHEN length(${group_id}) >5
    then ${TABLE}.users end) ;;
}

measure: connect_users  {
  type: count_distinct
  sql: CASE when (${TABLE}.screen_name = "connect_stream_trending"
  AND ${group_id} is null)
  THEN ${TABLE}.users END;;
}

measure: total_events {
  type: sum
  sql: ${TABLE}.total_events ;;
}

measure: groups_post_count {
  type: sum
  sql: CASE WHEN (${TABLE}.event_name = "connect_post"
    AND length(${TABLE}.group_id)>6 )
  THEN ${TABLE}.total_events end;;
}

dimension: event_count_dimension {
  type:  string
  sql:CASE WHEN ${TABLE}.total_events<3 THEN "0-2"
      WHEN ${TABLE}.total_events Between 3 and 10 then "3 to 10"
      WHEN ${TABLE}.total_events BETWEEN 11 AND 20 THEN "11 to 20"
      WHEN ${TABLE}.total_events>20 THEN "more than 20"
  else "null" end;;

}


dimension: event_name {
  type: string
  sql: ${TABLE}.event_name ;;
}

dimension: screen_name {
  type: string
  sql: ${TABLE}.screen_name ;;
}

measure: group_count {
  type: count_distinct
  sql: ${TABLE}.group_id ;;
}

measure: group_count_posts {
  type: count_distinct
  sql: if(${TABLE}.total_events>2, ${TABLE}.group_id,"null") ;;
}

measure: count_of_posters {
  type: sum
  sql: (CASE WHEN (length(${group_id})>6
  and ${TABLE}.event_name = "connect_post")then ${TABLE}.users end) ;;
}


dimension: group_id_post_grouping {
  type: string
  sql: (CASE WHEN (CASE WHEN (${TABLE}.event_name = "connect_post"
    AND length(${TABLE}.group_id)>6 )
  THEN ${TABLE}.total_events end)  <3 then "0-2"
      when (CASE WHEN (${TABLE}.event_name = "connect_post"
    AND length(${TABLE}.group_id)>6 )
  THEN ${TABLE}.total_events end)  between 3 and 10 THEN "3-10"
      when (CASE WHEN (${TABLE}.event_name = "connect_post"
    AND length(${TABLE}.group_id)>6 )
  THEN ${TABLE}.total_events end) between 11 and 20 then "11 and 20"
      WHEn (CASE WHEN (${TABLE}.event_name = "connect_post"
    AND length(${TABLE}.group_id)>6 )
  THEN ${TABLE}.total_events end) >20 then "more than 20"
      END)
  ;;
}
}

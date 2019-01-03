view: groups_kpi_weekly {
  derived_table: {
    sql: sELECT DISTINCT
(case when hcd.index=85 THEN hcd.value ELSE NULL END) as group_id,
h.eventinfo.eventaction as event,
device.language as language_market ,
device.operatingSystem as operating_system,
EXTRACT( WEEK from tIMESTAMP_MILLIS(visitStartTime*1000)) as gen_time,
date,
(case when cd.index=12 then cd.value END) as users,
COUNT(DISTINCT CONCAT( CAST(visitId AS STRING), CAST(h.hitnumber AS STRING))) as total_events
FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions`, unnest(customdimensions) as cd, unnest(hits) as h, unnest(h.customdimensions) as hcd
iNNER JOIN
unnest(GENERATE_DATE_ARRAY('2018-11-11', '2019-12-31', INTERVAL 1 week)) as date
ON EXTRACT( WEEK from tIMESTAMP_MILLIS(visitStartTime*1000)) = extract(week from date)
WHERE SUFFIX BETWEEN '20181111' AND '20191231'
and length(case when hcd.index=85 THEN hcd.value ELSE NULL END)>1
GROUP BY 1,2,3,4,5,6,7;;
  }
dimension_group: week_date {
    timeframes: [date,week,raw]
    datatype: datetime
    type: time
    convert_tz: no
    sql: timestamp(${TABLE}.date) ;;
}
dimension: session_date {
  type: number
  sql: ${TABLE}.gen_time ;;
}

dimension: operating_system {
  type: string
  sql: ${TABLE}.operating_system ;;
}

dimension: group_id {
  type: string
  sql: ${TABLE}.group_id ;;
}

dimension: user_uuid {
  type: string
  sql: ${TABLE}.users ;;
}

dimension: market {
  type: string
  sql: ${TABLE}.language_market ;;
}

dimension: event_name {
  type: string
  sql: ${TABLE}.event ;;
}

measure: users {
  type: count_distinct
  sql: ${TABLE}.users ;;
}

measure: total_events {
  type: sum
  sql: ${TABLE}.total_events ;;
}

measure: total_posts {
  type: sum
  sql: (Case WHEN ${TABLE}.event = "connect_post"  then ${TABLE}.total_events else null end);;
}

measure: more_than_2_posts{
  type: sum
  sql: CASE WHEN (${TABLE}.event = "connect_post" AND ${TABLE}.total_events>2) THen ${TABLE}.total_events END ;;
}
  measure: more_than_2_posts_groups{
    type: count_distinct
    sql: CASE WHEN (${TABLE}.event = "connect_post" AND ${TABLE}.total_events>2) THen ${TABLE}.group_id END ;;
  }
  measure: more_than_2_postsorcomments_groups{
    type: count_distinct
    sql: CASE WHEN ((${TABLE}.event = "connect_post" or ${TABLE}.event = "connect_comment" or ${TABLE}.event = "connect_reply_to_member")
      AND ${TABLE}.total_events>2)
      THen ${TABLE}.group_id END ;;
  }
  measure: total_posts_avg {
    type: average
    sql: (Case WHEN ${TABLE}.event = "connect_post"  then ${TABLE}.total_events else null end);;
  }

measure: users_posting {
  type: count_distinct
  sql: CASE WHEn ${TABLE}.event = "connect_post" THEn ${TABLE}.users END   ;;
}
  measure: users_reacting {
    type: count_distinct
    sql: CASE WHEn (${TABLE}.event = "connect_post_like"
      OR ${TABLE}.event = "connect_comment"
      OR ${TABLE}.event = "connect_reply_to_member"
      OR ${TABLE}.event = "connect_comment_like"
      OR ${TABLE}.event = "connect_reply_like"
      or ${TABLE}.event = "connect_post_like_tap")
    THEn ${TABLE}.users END   ;;
  }
measure: total_posts_filtered {
  type: sum
  filters: {
    field: event_name
    value: "connect_post"
  }
  sql:${TABLE}.total_events  ;;
}

measure: count_of_groups {
  type: count_distinct
  sql: ${TABLE}.group_id ;;
}

measure: total_groups_by_country {
  type: max
  sql: (Case WHEN ${TABLE}.language_market = "en-US" THEN 60
  WHEN ${TABLE}.language_market = "en-GB" THEN 38
  WHEN ${TABLE}.language_market = "pr-BR" THEN 29
  WHEN ${TABLE}.language_market = "de-DE" THEN 27
  WHEN ${TABLE}.language_market = "sv-SE" THEN 25
  WHEN ${TABLE}.language_market = "fr-CA" THEN 25
  WHEN ${TABLE}.language_market = "en-CA" THEN 24
  WHEN ${TABLE}.language_market = "en-AU" THEN 24
  WHEN ${TABLE}.language_market = "nl-NL" THEN 22
  WHEN ${TABLE}.language_market = "fr-FR" THEN 22
  WHEN ${TABLE}.language_market = "de-CH" THEN 22
  WHEN ${TABLE}.language_market = "fr-BE" THEN 22
  ELSE 391 end);;
}
}

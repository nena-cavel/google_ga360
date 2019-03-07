view: connect_daily_counts {
  derived_table: {
    persist_for: "48 hours"
    sql: SELECT DISTINCT
(EXTRACT(date FROM TIMESTAMP_MILLIS((visitStartTime*1000)+h.time))) as generated_date,
d.FiscalWeekOfYear AS fiscal_week,
d.FiscalYear as fiscal_year,
(CASE WHEN cd.index=53 then cd.value else null end) as region,
COUNT(DISTINCT (CASE WHEN (h.appinfo.screenname = "connect_stream_trending" AND h.type = 'APPVIEW') then fullvisitorid END)) AS connect_traffic,
COUNT(DISTINCT (CASE WHEN (h.appinfo.screenname = "connect_stream_new" AND h.type = 'APPVIEW') then fullvisitorid END)) AS following_traffic,
COUNT(DISTINCT (CASE WHEN (h.appinfo.screenname = "connect_stream_following" AND h.type = 'APPVIEW') then fullvisitorid END)) AS new_traffic,
count(distinct (CASE WHEN (h.appinfo.screenname = "connect_stream_trending" AND h.type = 'APPVIEW') then concat(fullvisitorID, CAST(visitID AS string)) end)) as connect_sessions,
COUNT(DISTINCT (CASE WHEN (h.eventinfo.eventaction = "connect_post" AND h.type = 'EVENT') then fullvisitorid END)) as posters,
count(distinct (CASE WHEN (h.eventinfo.eventaction = "connect_post" and h.type = 'EVENT') then concat(cast(h.hitnumber as string), CAST(visitID AS string)) end)) as count_of_posts,
COUNT(DISTINCT (CASE WHEN (h.type = 'EVENT' AND h.eventinfo.eventaction = 'connect_member_fast_follow' OR h.eventinfo.eventaction = 'connect_user_follow') THEN fullvisitorID END)) as followers,
COUNT(DISTINCT(CASE WHEN (h.type = 'EVENT' and h.eventinfo.eventaction = 'connect_post_like' OR h.eventinfo.eventaction =  'connect_comment_like' OR h.eventinfo.eventaction ='connect_reply_like' OR h.eventinfo.eventaction= 'connect_post_like_tap') then fullvisitorID END)) AS likers,
COUNT(DISTINCT(CASE WHEN (h.type = 'EVENT' and h.eventinfo.eventaction = 'connect_post_like' OR h.eventinfo.eventaction =  'connect_comment_like' OR h.eventinfo.eventaction ='connect_reply_like' OR h.eventinfo.eventaction= 'connect_post_like_tap') then concat(cast(h.hitnumber as string), CAST(visitID AS string)) end)) AS count_of_likes,
COUNT(DISTINCT(CASE WHEN (h.type = 'EVENT' AND h.eventinfo.eventaction = 'connect_comment' OR h.eventinfo.eventaction =  'connect_reply_to_member' ) then fullvisitorID END)) AS commenters,
COUNT(DISTINCT(CASE WHEN (h.type = 'EVENT' AND h.eventinfo.eventaction = 'connect_comment' OR h.eventinfo.eventaction =  'connect_reply_to_member' ) then concat(cast(h.hitnumber as string), CAST(visitID AS string)) end)) AS count_of_comments,
COUNT(DISTINCT (CASE WHEN (h.eventinfo.eventaction = 'connect_post_report' and h.type = 'EVENT') THEN CONCAT(CAST( h.hitnumber as string),cast(visitID as string)) end)) as reported_posts,
COUNT(DISTINCT (CASE WHEN (h.type = 'EVENT' and h.eventinfo.eventaction = 'connect_comment_report' or h.eventinfo.eventaction = "connect_reply_report") THEN CONCAT(CAST( h.hitnumber as string),cast(visitID as string)) end)) as reported_comment,
COUNT(DISTINCT (CASE WHEN (h.type = 'EVENT' AND h.eventinfo.eventaction = 'connect_user_block' OR h.eventinfo.eventaction = 'connect_block_member_profile') THEN CONCAT(CAST( h.hitnumber as string),cast(visitID as string)) end)) as member_blocks,
COUNT(CASE WHEN (h.appinfo.screenname = 'connect_load_more_trending' AND h.type='APPVIEW' ) THEN h.appinfo.screenname end) as post_loads,
COUNT(DISTINCT (CASE WHEN regexp_contains(h.appinfo.screenName, 'food_dashboard') then fullvisitorID end)) AS all_users
FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions` , unnest(customdimensions) as cd, unnest(hits) as h

JOIN  `wwi-datalake-1.CIE_star_schema.DimDate` d -- to derive fiscal week and year
ON d.Date = EXTRACT(date FROM TIMESTAMP_MILLIS((visitStartTime*1000)+h.time))


WHERE SUFFIX Between '20181001'AND '20191230'
and regexp_contains((CASE WHEN cd.index=53 then cd.value else null end), 'us|ca|br|gb|se|fr|de|be|nl|ch|au|nz')
group by 1 ,2, 3, 4 ;;
  }


  dimension_group: date {
    timeframes: [date,raw]
    datatype: datetime
    type: time
    convert_tz: no
    sql: timestamp(${TABLE}.generated_date) ;;
  }

  measure: connect_users {
    type: sum
    sql: ${TABLE}.connect_traffic ;;
  }

  measure: all_app_users {
    type: sum
    sql: ${TABLE}.all_users ;;
  }

  measure: connect_sessions {
    type: sum
    sql: ${TABLE}.connect_sessions ;;
  }

  measure: posters {
    type: sum
    sql: ${TABLE}.posters ;;
  }

  measure: commenters {
    type: sum
    sql: ${TABLE}.commenters ;;
  }

  measure: likers {
    type: sum
    sql: ${TABLE}.likers ;;
  }

  measure: followers {
    type: sum
    sql: ${TABLE}.followers ;;
  }

  measure: count_of_posts {
    type: sum
    sql: ${TABLE}.count_of_posts ;;
  }

  measure: reported_posts {
    type: sum
    sql: ${TABLE}.reported_posts ;;
  }

measure: reported_comments {
  type: sum
  sql: ${TABLE}.reported_comment ;;
}

measure: count_of_comments {
  type: sum
  sql: ${TABLE}.count_of_comments ;;
}

measure: post_loads {
  type: sum
  sql: ${TABLE}.post_loads ;;
}

measure: following_traffic {
  type: sum
  sql: ${TABLE}.following_traffic ;;
}

measure: new_traffic {
  type: sum
  sql: ${TABLE}.new_traffic ;;
}

dimension: region {
  type: string
  sql: ${TABLE}.region ;;
}

dimension: region_group {
  type: string
  sql: CASE WHEN ${TABLE}.region = 'us' THEN 'United States' ELSE 'International' END ;;
}


  dimension: fiscal_year {
    type: number
    description: "The fiscal year the action happened in"
    sql:  ${TABLE}.fiscal_year;;
  }

  dimension: fiscal_week {
    type: number
    description: "The fiscal week the action happened in"
    sql:  ${TABLE}.fiscal_week;;
  }


measure: member_blocks {
  type: sum
  sql: ${TABLE}.member_blocks ;;
}
}

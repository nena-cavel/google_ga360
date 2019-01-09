view: engagement_score {
  derived_table: {
    sql: SELECT DISTINCT
subquery.test_date as session_date,
region,
subquery.operating_system as operating_system,
AVG(subquery.view_profile) AS profile_views,
AVG(subquery.view_comments*2) as comment_views,
AVG(subquery.view_hashtag) as hashtag_views,
AVG(subquery.see_more_posts*0.1) as see_more_of_posts,
AVG(subquery.comments*4) as comments,
AVG(subquery.follow*2) as follows,
AVG(subquery.likes*2) as likes,
(AVG(subquery.view_profile)+AVG(subquery.view_comments*2)+AVG(subquery.view_hashtag)+AVG(subquery.see_more_posts*0.1)+AVG(subquery.comments*4)+AVG(subquery.follow*2)+AVG(subquery.likes*2)) AS engagement_score
FROM
(
SELECT
visitidcalc,
CAST(test.start_time AS date) as test_date,
region,
test.operating_system as operating_system,
SUM(CASE WHEN (test.screen_name = 'connect_stream_trending' AND test.hit_type = 'APPVIEW') THEN test.total_screenviews ELSE 0 END) AS view_stream,
SUM(CASE WHEN (test.screen_name = 'connect_profile' AND test.hit_type = 'APPVIEW') THEN test.total_screenviews ELSE 0 END) AS view_profile,
SUM(CASE WHEN (test.screen_name = 'connect_comments' AND test.hit_type= 'APPVIEW') THEN test.total_screenviews ELSE 0 END) AS view_comments,
SUM(CASE WHEN (test.screen_name = 'connect_stream_hashtag' AND test.hit_type = 'APPVIEW') THEN test.total_screenviews ELSE 0 END) AS view_hashtag,
SUM(CASE WHEN (test.event_name = 'connect_post_see_more' AND test.hit_type = 'EVENT') THEN test.total_screenviews ELSE 0 END) AS see_more_posts,
SUM(CASE WHEN ((test.event_name = 'connect_comment' OR test.event_name = 'connect_reply_to_member') and test.hit_type = 'EVENT') THEN test.total_screenviews ELSE 0 END) AS comments,
SUM(CASE WHEN ((test.event_name = 'connect_member_fast_follow' OR test.event_name = 'connect_user_follow') and test.hit_type = 'EVENT')  THEN test.total_screenviews ELSE 0 END) AS follow,
SUM(CASE WHEN ((test.event_name = 'connect_post_like' OR test.event_name =  'connect_comment_like' OR test.event_name ='connect_reply_like' OR test.event_name= 'connect_post_like_tap') AND test.hit_type = 'EVENT') THEN test.total_screenviews ELSE 0 END) AS likes
FROM
 (
 SELECT DISTINCT
  (fullVisitorId) AS uuid,
  (CASE WHEN cd.index=53 then cd.value else null end) as region,
  device.operatingSystem  AS operating_system,
  concat(cast(visitId as string),fullVisitorID) as visitidcalc,
  (timestamp_seconds(visitStartTime)) as start_time,
  (TIMESTAMP_MILLIS(1000 * (visitStartTime + totals.timeOnSite ))) AS session_end,
   h.appinfo.screenName AS screen_name,
  h.eventInfo.eventAction as event_name,
  h.type AS hit_type,
   COUNT(DISTINCT CONCAT( CAST(visitId AS STRING), CAST(h.hitnumber AS STRING))) as total_screenviews
  FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions`, UNNEST(customdimensions) as cd, unnest(hits) as h


  WHERE SUFFIX Between '20180101'AND '20191231'
  and (REGEXP_CONTAINS(h.appinfo.screenName, 'connect_stream_trending|connect_profile|connect_comments|connect_stream_hashtag')
  or regexp_contains(h.eventInfo.eventAction, 'connect_post_see_more|connect_comment|connect_reply_to_member|connect_member_fast_follow|connect_user_follow|connect_post_like|connect_comment_like|connect_reply_like'))
  AND visitId IS NOT NULL
  and regexp_contains((CASE WHEN cd.index=53 then cd.value else null end), 'us|ca|br|gb|se|fr|de|be|nl|ch|au|nz')
  GROUP BY 1,2,3,4,5,6,7,8,9
  ) test

  GROUP BY 1,2,3,4
  ) subquery
GROUP BY 1,2,3 ;;
  }

  dimension_group: session_date {
    timeframes: [date,day_of_month,day_of_year,month,month_name,month_num]
    type: time
    convert_tz: no
    sql: timestamp(${TABLE}.session_date);;
    }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: region_group {
    type: string
    sql: CASE WHEN ${TABLE}.region = 'us' THEN 'United States' ELSE 'International' END ;;
  }

    dimension: operating_system {
      type: string
      sql: ${TABLE}.operating_system;;
    }

  measure: profile_views {
    type: sum
    sql: ${TABLE}.profile_views ;;
  }

  dimension: profile_views_dim {
    type:  number
    sql: ${TABLE}.profile_views ;;
  }

  measure: comment_views {
    type: sum
    sql: ${TABLE}.comment_views ;;
  }

  dimension: comment_views_dim {
    type:  number
    sql: ${TABLE}.comment_views ;;
  }
  measure: hashtag_views {
    type: sum
    sql: ${TABLE}.hashtag_views ;;
  }

  measure: see_more_of_posts {
    type: sum
    sql: ${TABLE}.see_more_of_posts ;;
  }

  measure: comments {
    type: sum
    sql: ${TABLE}.comments ;;
  }
  measure: follows {
    type: sum
    sql: ${TABLE}.follows ;;
  }

  measure: likes {
    type: sum
    sql: ${TABLE}.likes ;;
  }
measure: eng_score {
  type:  average
  precision: 1
  sql: ${TABLE}.engagement_score ;;
}

  measure: eng_score_sum {
    type:  sum
    precision: 1
    sql: ${TABLE}.engagement_score ;;
  }

}

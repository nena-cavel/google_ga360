view: post_love_score_daily {
  derived_table: {
    sql:
sELECT distinct

date_post_created,
post_type,
(CASE WHEN region = 'fr-CH'
  THEN 'ch'
  WHEN region ='de-CH' then 'ch'
  wheN region = 'nl-BE' THEN 'be'
  WHEN region ='sv-SE' THEN 'se'
  WHEN region ='de-DE' then 'de'
  WHEN region = 'en-GB' then 'gb'
  WHEN region ='en-US' then 'us'
  WHEN region = 'fr-FR' then 'fr'
  WHEN region = 'nl-NL' then 'nl'
  WHEN region = 'fr-CA' then 'ca'
  WHEN region = 'fr-BE' THEN 'be'
  WHEN region = 'en-AU' THEN 'au'
  WHEN region = 'en-CA' then 'ca'
  END) as region,
post_id,

(SUM(
  CASE WHEN engagement_type = 'like' AND hours_after_posting_engagement <= 24 THEN 1 ELSE 0 END
  ) / count(distinct post_id)) AS total_likes,


(SUM(
  CASE WHEN engagement_type = 'comment' AND hours_after_posting_engagement <= 24 THEN 1 ELSE 0 END
  ) / count(distinct post_id)) AS total_comments,

  (SUM(
  CASE WHEN engagement_type = 'like' AND hours_after_posting_engagement <= 24 THEN 1 ELSE 0 END
  ) / count(distinct post_id))+(SUM(
  CASE WHEN engagement_type = 'comment' AND hours_after_posting_engagement <= 24 THEN 1 ELSE 0 END
  ) / count(distinct post_id)) as poster_love,

COUNT(DISTINCT post_id) as number_of_posts

FROM

(
-- this part is intended to be a "tall" version of your previous query, 1 row per engagement, where a Like is an engagement or a Comment is an engagement
-- some posts may have no engagements so have null engagement ids.
-- note that right now there can be multiple posts with the same uuid (create and update?) which will double up entries. This is probably not desirable? Example shown in comment at bottom

  SELECT DISTINCT
  EXTRACT(date FROM payload_post.created_at) as date_post_created,
  payload_post.locale as region,
  payload_post.subclass as post_type,
  cp.payload_post.uuid AS post_id,
  engagements.engagement_type,
  engagements.engagement_id,
  TIMESTAMP_DIFF(engagements.created_at, cp.payload_post.created_at, SECOND)/3600 as hours_after_posting_engagement

  FROM `wwi-datalake-1.wwi_events_pond.connect_Post` cp

  -- left join to a table consisting of all possible likes and comments (perhaps a post has none of either?)

  LEFT JOIN
  (
    SELECT DISTINCT cl.payload_like.likeable.uuid AS uuid,
    cl.payload_like.created_at AS created_at,
    'like' AS engagement_type,
    cl.payload_like.id AS engagement_id

    FROM  `wwi-datalake-1.wwi_events_pond.connect_Like` cl

    UNION ALL

    SELECT DISTINCT cc.payload_comment.post.uuid AS uuid,
    cc.payload_comment.created_at AS created_at,
    'comment' AS engagement_type,
    cc.payload_comment.id AS engagement_id
    FROM `wwi-datalake-1.wwi_events_pond.connect_Comment` cc

   ) engagements

   ON cp.payload_post.uuid = engagements.uuid

  WHERE payload_post.created_at BETWEEN timestamp('2019-03-01 00:00:01') and timestamp('2019-08-31 23:59:59')
  AND headers_action = 'Create'

-- for testing
--AND cp.payload_post.uuid = 'cd98a059-5cc8-4957-a9a7-11948cf33c4c'
--AND engagements.engagement_id IN (80741569,382944963)

--LIMIT 1000

  ) post_engagements
#INNER JOIN
#unnest(GENERATE_DATE_ARRAY('2018-07-01', '2018-12-31', INTERVAL 1 MONTH)) as date
#ON month_post_created = extract(month from date)
WHERE region is not null
GROUP BY 1,2,3,4

order by 3 desc
;;
}
  dimension_group: date {
    timeframes: [date,month,week,month_name,month_num]
    datatype: datetime
    type: time
    convert_tz: no
    sql: timestamp(${TABLE}.date_post_created) ;;
  }

  dimension: post_type {
    type:  string
    sql: ${TABLE}.post_type ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: region_group {
    type: string
    sql: CASE WHEN ${TABLE}.region = 'us' THEN 'United States' ELSE 'International' END ;;
  }

  measure: likes {
    type: sum
    sql: ${TABLE}.total_likes ;;
  }

  measure: avg_likes {
    type: average
    sql: ${TABLE}.total_likes ;;
  }

  measure: median_likes {
    type: median
    sql: ${TABLE}.total_likes ;;
  }
  measure: median_comments {
    type: median
    sql: ${TABLE}.total_comments ;;
  }
  measure: 75_likes {
    type: percentile
    percentile: 75
    sql: ${TABLE}.total_likes ;;
  }
  measure: 75_comments {
    type: percentile
    percentile: 75
    sql: ${TABLE}.total_comments ;;
  }

  measure: 25_likes {
    type: percentile
    percentile: 25
    sql: ${TABLE}.total_likes ;;
  }
  measure: 25_comments {
    type: percentile
    percentile: 25
    sql: ${TABLE}.total_comments ;;
  }
  measure: 90_likes {
    type: percentile
    percentile: 90
    sql: ${TABLE}.total_likes ;;
  }
  measure: 90_comments {
    type: percentile
    percentile: 90
    sql: ${TABLE}.total_comments ;;
  }
  measure: comments {
    type: sum
    sql: ${TABLE}.total_comments ;;
  }
  measure: avg_comments {
    type: average
    sql: ${TABLE}.total_comments ;;
  }
  measure: poster_love {
    type:  average
    sql: ${TABLE}.poster_love ;;
  }

  measure: count {
    type: count

  }

  dimension: post_id {
    type:  string
    sql: ${TABLE}.post_id ;;
  }

  measure: posts {
    type: sum
    sql: ${TABLE}.number_of_posts ;;
  }
}

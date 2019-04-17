view: poster_love {
  derived_table: {
    sql:
#standardSQL

SELECT

date,
region,
post_type,
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
  EXTRACT(MONTH FROM payload_post.created_at) as month_post_created,
  payload_post.subclass as post_type,
  payload_post.locale as region,
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

  WHERE payload_post.created_at BETWEEN timestamp('2018-01-01 00:00:01') and timestamp('2019-12-31 23:59:59')
  AND headers_action = 'Create'

-- for testing
--AND cp.payload_post.uuid = 'cd98a059-5cc8-4957-a9a7-11948cf33c4c'
--AND engagements.engagement_id IN (80741569,382944963)

--LIMIT 1000

  ) post_engagements
INNER JOIN
unnest(GENERATE_DATE_ARRAY('2018-01-01', '2019-12-31', INTERVAL 1 MONTH)) as date
ON month_post_created = extract(month from date)
GROUP BY 1,2,3,4

order by 4 desc
;;
  }
  dimension_group: date {
    timeframes: [date,month,month_name,month_num]
    datatype: datetime
    type: time
    convert_tz: no
    sql: timestamp(${TABLE}.date) ;;
  }

  dimension: post_type {
    type:  string
    sql: ${TABLE}.post_type ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: market_name {
    type: string
    sql: (case when ${TABLE}.region ='en-US' then 'United States'
                WHEN ${TABLE}.region ='de-DE' then 'Germany'
                WHEN ${TABLE}.region ='en-GB' then 'UK'
                WHEN ${TABLE}.region = 'en-CA' then 'Canada'
                WHEN ${TABLE}.region = 'fr-CA' then 'Canada'
                WHEN ${TABLE}.region ='fr-FR' then 'France'
                WHEN ${TABLE}.region ='nl-NL' then 'Netherlands'
                when ${TABLE}.region ='nl-BE' then 'Belgium'
                when ${TABLE}.region = 'fr-BE' then 'Belgium'
                WHEN ${TABLE}.region ='de-CH' then 'Switzerland'
                when ${TABLE}.region = 'fr-CH' then 'Switzerland'
                when ${TABLE}.region ='en-AU' then 'ANZ'
                WHEN ${TABLE}.region ='nz' then 'ANZ'
                WHEN ${TABLE}.region ='sv-SE' then 'Sweden'
                when ${TABLE}.region ='pt-BR' then 'Brazil'
    END) ;;
  }

  measure: likes {
    type: sum
    sql: ${TABLE}.total_likes ;;
  }

  measure: avg_likes {
    type: average
    sql: ${TABLE}.total_likes ;;
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

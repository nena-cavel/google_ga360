view: reported_posts {
  derived_table: {
    sql:
    SELECT DISTINCT
date as month,
subquery.locale as locale,
COUNT(DISTINCT(CASE WHEN ( subquery.row_rank =1 and subquery.flagged_count=0 AND subquery.is_invisible is true and subquery.flagged IS TRUE) THEN subquery.post_id END)) AS auto_nomanageraction,
COUNT(DISTINCT(CASE WHEN (subquery.row_rank =1 and  subquery.flagged_count=0 AND subquery.is_invisible is true and subquery.flagged IS FALSE) THEN subquery.post_id END)) AS auto_banned ,
any_value(autobanned_unbanned) AS autobanned_approved ,
COUNT(DISTINCT(CASE WHEN ((subquery.row_rank=1 and subquery.flagged_count BETWEEN 1 AND 20) AND subquery.flagged IS TRUE) THEN subquery.post_id END)) as report_nomanageraction ,
COUNT(DISTINCT(CASE WHEN ((subquery.row_rank=1 and subquery.flagged_count>0) AND (subquery.is_invisible is FALSE) and (subquery.flagged IS FALSE)) THEN subquery.post_id END)) as reported_approved ,
COUNT(DISTINCT(CASE WHEN ((subquery.row_rank=1 and subquery.flagged_count BETWEEN 1 and 20) AND (subquery.is_invisible is true) and (subquery.flagged IS FALSE)) THEN subquery.post_id END)) AS reported_banned,
COUNT(DISTINCT(CASE WHEN ( subquery.row_rank=1 and subquery.flagged_count>20 AND subquery.is_invisible is true and subquery.flagged IS TRUE) THEN subquery.post_id END))  as reported20_nomanageraction,
COUNT(DISTINCT(CASE WHEN (subquery.row_rank=1 and subquery.flagged_count>20 AND subquery.is_invisible is true and subquery.flagged IS FALSE) THEN subquery.post_id END))  as reported20_managerban,
count(distinct subquery.post_id) as total_posts


FROM
(
SELECT DISTINCT
payload_post.locale AS locale,
payload_post.uuid AS post_id,
payload_post.flagged AS flagged,
payload_post.flags_count AS flagged_count,
payload_post.invisible AS is_invisible,
extract(date from payload_post.created_at) as date_created,
payload_post.updated_at  AS date_updated,
ROW_NUMBER() OVER(PARTITION BY payload_post.uuid  order by payload_post.updated_at desc ) as row_rank
FROM `wwi-data-playground-3.wwi_processed_data_std_views.connect_Post`
WHERE payload_post.is_deleted IS FALSE
AND payload_post.updated_at  > TIMESTAMP('2018-01-01 00:00:01')
#and headers_action = 'Update'
#AND payload_post.uuid = '928d9c1d-e3e8-46f8-a93a-c4f38b948f8a'
) subquery
LEFT JOIN
(
SELECT DISTINCT
EXTRACT(MONTH FROM uberquery.date_updated) as month,
uberquery.locale as locale ,
count(distinct uberquery.posts) as autobanned_unbanned
FROM
(
SELECT
most_recent.date_updated,
most_recent.post_id as posts,
most_recent.locale AS locale,
most_recent.flagged,
rank_two.flagged_two
FROM
(
SELECT DISTINCT
payload_post.locale AS locale,
payload_post.uuid AS post_id,
payload_post.flagged AS flagged,
payload_post.flags_count AS flagged_count,
payload_post.invisible AS is_invisible,
payload_post.updated_at AS date_updated,
ROW_NUMBER() OVER(PARTITION BY payload_post.uuid order by payload_post.updated_at DESC) as row_rank
FROM `wwi-data-playground-3.wwi_processed_data_std_views.connect_Post`
WHERE payload_post.is_deleted IS FALSE
AND payload_post.updated_at > TIMESTAMP('2018-01-01 00:00:01')
and headers_action = 'Update'
AND payload_post.flags_count =0
ORDER BY 2 DESC
)
most_recent
LEFT JOIN
(
SELECT DISTINCT
payload_post.locale AS locale,
payload_post.uuid AS post_id,
payload_post.flagged AS flagged_two,
payload_post.flags_count AS flagged_count,
payload_post.invisible AS is_invisible,
payload_post.updated_at AS date_updated,
ROW_NUMBER() OVER(PARTITION BY payload_post.uuid order by payload_post.updated_at DESC) as row_rank
FROM `wwi-data-playground-3.wwi_processed_data_std_views.connect_Post`
WHERE payload_post.is_deleted IS FALSE
AND payload_post.updated_at > TIMESTAMP('2018-01-01 00:00:01')
and headers_action = 'Update'
AND payload_post.flags_count =0
ORDER BY 2 DESC
) rank_two
ON most_recent.post_id = rank_two.post_id
WHERE (most_recent.row_rank = 1 AND most_recent.flagged IS FALSE AND most_recent.is_invisible IS FALSE)
AND (rank_two.row_rank>1 AND rank_two.flagged_two IS TRUE)

)uberquery
group by 1,2) auto
ON (subquery.locale = auto.locale
  AND EXTRACT (Month FROM subquery.date_created) = auto.month)
INNER JOIN
unnest(GENERATE_DATE_ARRAY('2018-01-01', '2018-12-31', INTERVAL 1 MONTH)) as date
ON EXTRACT (Month FROM subquery.date_created) = extract(month from date)
GROUP BY 1,2;;
  }


dimension: market {
  type: string
  drill_fields: [market]
  sql: ${TABLE}.locale ;;
}

dimension_group: month  {
  timeframes: [month_num, month,raw,date]
type:  time
datatype: datetime
drill_fields: [market]
convert_tz: no
sql: timestamp(${TABLE}.month) ;;
}

measure: auto_nomanageraction {
  type: sum
  sql: ${TABLE}.auto_nomanageraction ;;
}

measure: auto_banned{
  type: sum
  sql: ${TABLE}.auto_banned ;;
}

measure: autobanned_approved {
  type: sum
  sql: ${TABLE}.autobanned_approved ;;
}

measure: reported_approved {
  type: sum
  sql: ${TABLE}.reported_approved ;;
}

measure: reported_banned {
  type: sum
  sql: ${TABLE}.reported_banned ;;
}
measure: reported20_nomanageraction {
  type: sum
  sql: ${TABLE}.reported20_nomanageraction ;;
}

measure: reported20_managerban {
  type: sum
  drill_fields: [market]
  sql: ${TABLE}.reported20_managerban ;;
}

measure: total_posts {
  type: sum
  drill_fields: [market]
  sql: ${TABLE}.total_posts ;;
}

measure: report_nomanageraction {
  type: sum
  drill_fields: [market]
  sql: ${TABLE}.report_nomanageraction ;;
}
}

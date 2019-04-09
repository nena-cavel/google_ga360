view: reported_posts_new {
  derived_table: {
    persist_for: "127 hours"
    sql:
SELECT DISTINCT
week_date as week,
subquery.locale as locale,
COUNT(DISTINCT(CASE WHEN ( subquery.row_rank =1 and subquery.flagged_count=0 AND subquery.is_invisible is true and subquery.flagged IS TRUE) THEN subquery.post_id END)) AS auto_nomanageraction,
COUNT(DISTINCT(CASE WHEN (subquery.row_rank =1 and  subquery.flagged_count=0 AND subquery.is_invisible is true and subquery.flagged IS FALSE) THEN subquery.post_id END)) AS auto_banned ,
COUNT(DISTINCT(CASE WHEN ((subquery.row_rank=1 and subquery.flagged_count >=1) AND subquery.flagged IS TRUE) THEN subquery.post_id END)) as report_nomanageraction ,
COUNT(DISTINCT(CASE WHEN ((subquery.row_rank=1 and subquery.flagged_count>0) AND (subquery.is_invisible is FALSE) and (subquery.flagged IS FALSE)) THEN subquery.post_id END)) as reported_approved ,
COUNT(DISTINCT(CASE WHEN ((subquery.row_rank=1 and subquery.flagged_count >= 1) AND (subquery.is_invisible is true) and (subquery.flagged IS FALSE)) THEN subquery.post_id END)) AS reported_banned,
COUNT(DISTINCT (CASE WHEN (subquery.row_rank = 1 and subquery.flagged_count =0 and subquery.is_invisible is FALSE AND subquery.flagged is TRUE) then subquery.post_id END)) AS actionneeded_noaction,
COUNT(DISTINCT (CASE WHEN (subquery.flagged_count>0 or subquery.is_invisible IS TRUE OR subquery.flagged IS TRUE) THEN subquery.post_id END)) AS all_attention_posts,
count(distinct subquery.post_id) as total_posts

FROM
(
SELECT DISTINCT
payload_post.locale   AS locale,
payload_post.uuid AS post_id,
payload_post.flagged AS flagged,
payload_post.flags_count AS flagged_count,
payload_post.invisible AS is_invisible,
extract(date from payload_post.updated_at) as ref_date_updated,
payload_post.updated_at  AS date_updated,
ROW_NUMBER() OVER(PARTITION BY payload_post.uuid  order by payload_post.updated_at desc ) as row_rank
FROM `wwi-datalake-1.wwi_events_pond.connect_Post`
WHERE payload_post.updated_at  > TIMESTAMP('2018-01-01 00:00:01')
#and headers_action = 'Update'
#AND payload_post.uuid = '928d9c1d-e3e8-46f8-a93a-c4f38b948f8a'
) subquery
INNER JOIN
unnest(GENERATE_DATE_ARRAY('2018-01-07', '2019-12-31', INTERVAL 1 week)) as week_date
ON (EXTRACT(week from ref_date_updated) = extract(week from week_date)
    AND EXTRACT(year from ref_date_updated) = extract(year from week_date))
group by 1,2 ;;
  }

  dimension: market {
    type: string
    drill_fields: [market]
    sql: ${TABLE}.locale ;;
  }

  dimension: market_name {
    type: string
    drill_fields: [market]
    sql: (CASE WHEN ${TABLE}.locale = 'sv-SE' then 'Sweden'
        WHEN regexp_contains(${TABLE}.locale , 'nl-NL|nl-BE') THEN 'Netherlands'
        WHEN ${TABLE}.locale = 'de-CH' THEN 'Swiss-German'
        WHEN ${TABLE}.locale = 'pt-BR' then 'Brazil'
        WHEN ${TABLE}.locale = 'de-DE' then 'Germany'
        WHEN ${TABLE}.locale = 'en-AU' then 'ANZ'
        WHEN ${TABLE}.locale = 'en-GB' THEN 'UK'
        WHEN ${TABLE}.locale = 'fr-CA' THEN 'Fr-Canada'
        WHEN ${TABLE}.locale = 'en-US' then 'US'
        WHEN ${TABLE}.locale = 'fr-CH' THEN 'Fr-Swiss'
        WHEN ${TABLE}.locale = 'fr-FR' then 'France'
        WHEN ${TABLE}.locale = 'en-CA' Then 'En-Canada'
        WHEN ${TABLE}.locale = 'fr-BE' THEN 'Belgium'
        END) ;;
  }

  dimension_group: week  {
    timeframes: [week,week_of_year, raw,date]
    type:  time
    datatype: datetime
    drill_fields: [market]
    convert_tz: no
    sql: timestamp(${TABLE}.week) ;;
  }

  measure: auto_nomanageraction {
    type: sum
    sql: ${TABLE}.auto_nomanageraction ;;
  }

  measure: auto_banned{
    type: sum
    sql: ${TABLE}.auto_banned ;;
  }

  measure: all_needing_moderation {
    type: sum
    sql: ${TABLE}.all_attention_posts ;;
  }

  measure: reported_approved {
    type: sum
    sql: ${TABLE}.reported_approved ;;
  }

  measure: reported_banned {
    type: sum
    sql: ${TABLE}.reported_banned ;;
  }


  measure: total_posts {
    type: sum
    drill_fields: [market]
    sql: ${TABLE}.total_posts ;;
  }

  measure: actionneeded_noaction {
    type: sum
    drill_fields: [market]
    sql: ${TABLE}.actionneeded_noaction ;;
  }

  measure: report_nomanageraction {
    type: sum
    drill_fields: [market]
    sql: ${TABLE}.report_nomanageraction ;;
  }
}

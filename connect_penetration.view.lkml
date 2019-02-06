# If necessary, uncomment the line below to include explore_source.
# include: "google_analytics_block.model.lkml"
view: connect_penetration {
  derived_table: {
    persist_for: "72 hours"
    sql: SELECT DISTINCT
    region,
cast(concat(cast(generated_year as string),'-',cast(generated_month as string),'-','01') as date) as date_calc,
data.connect_traffic as connect_traffic,
data.all_users as all_users
from
(
SELECT DISTINCT
(CASE WHEN cd.index=53 then cd.value else null end) as region,
(EXTRACT(Year FROM TIMESTAMP_MILLIS((visitStartTime*1000)+h.time))) as generated_year,
(EXTRACT(MONTH FROM TIMESTAMP_MILLIS((visitStartTime*1000)+h.time))) as generated_month,
COUNT ( DISTINCT(CASE WHEN regexp_contains(h.appinfo.screenName, '^connect_') then fullvisitorID END)) AS connect_traffic,
COUNT (DIStinct (CASE WHEN regexp_contains(h.appinfo.screenName, 'food_dashboard') then fullvisitorID end)) AS all_users
FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions` , unnest(customdimensions) as cd, unnest(hits) as h
WHERE SUFFIX Between '20180101'AND '20191231'
GROUP BY 1,2,3
) data
WHERE regexp_contains(region, 'us|ca|br|gb|se|fr|de|be|nl|ch|au|nz') ;;
}
dimension_group: month_visited {
  timeframes: [month,month_num,month_name,date]
  datatype: datetime  # was date, but support changed it to datetime
  type: time
  convert_tz: no
  sql: timestamp(${TABLE}.date_calc) ;;
}
measure: connect_users {
  type: sum
  sql: ${TABLE}.connect_traffic ;;
}
  measure: all_users {
    type: sum
    sql: ${TABLE}.all_users ;;
  }
dimension: region {
  type: string
  sql: ${TABLE}.region ;;
}

dimension: region_group {
  type: string
  sql:CASE WHEN regexp_contains(${TABLE}.region , 'au|nz')
          THEN 'ANZ'
          ELSE ${TABLE}.region END;;
}

}

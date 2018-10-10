view: rewards_prize_views_20180910 {
  derived_table: {
  persist_for: "24 hours"
  sql:
    select
    replace(replace(substr(screenname,8,
                length(screenname)-13),'__',' '),'_',' ') as Reward,# count(1) as total_screen_views,
                count(uuid) as total_screen_views,
                count(distinct uuid) as unique_screen_views,
            min(date) as min_date, max(date) as max_date
        FROM
          (SELECT
            date,
            device.operatingSystem AS operatingsystem,
            (CASE
                WHEN cd.index=12 THEN cd.value
                ELSE NULL END) AS uuid,
            h.eventinfo.eventaction AS eventaction,
            h.appInfo.screenName AS screenname,
            h.hitnumber AS hitnumber,
            visitid
          FROM
          `wwi-datalake-1:wwi_ga_pond.ga_sessions` as a
          JOIN
            UNNEST (customdimensions) AS cd
          JOIN
            UNNEST (hits) AS h
          JOIN
            UNNEST (h.customdimensions) AS hcd
          WHERE
            suffix BETWEEN format_date('%Y%m%d', date_sub(current_date(), interval 9 day)) and format_date('%Y%m%d', current_date())
            AND h.appInfo.screenName LIKE 'rewards_%_en_us'
            AND (hcd.index= 3
              AND hcd.value= 'us')
            AND date BETWEEN format_date('%Y%m%d', date_sub(current_date(), interval 8 day)) and format_date('%Y%m%d', date_sub(current_date(), interval 1 day))
            AND h.type = 'APPVIEW'
            AND (CASE WHEN cd.index=12 THEN cd.value ELSE NULL END) IS NOT NULL

            ) as sub
        group by 1
        order by 2 desc ;;
  }
  dimension: max_date {
    type: string
    sql: ${TABLE}.max_date ;;
  }

  dimension: min_date {
    type: string
    sql: ${TABLE}.min_date ;;
  }

  dimension: reward {
    type: string
    sql: ${TABLE}.Reward ;;
  }

  measure: total_screen_views {
    type: max
    sql: ${TABLE}.total_screen_views ;;
  }

  measure: unique_screen_views {
    type: max
    sql: ${TABLE}.unique_screen_views ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

}

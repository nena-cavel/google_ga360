view: rewards_onboarding_fullscreen_views {
  derived_table: {
    persist_for: "24 hours"
    sql:
    select date,
    # replace(replace(substr(screenname,8,
    #             length(screenname)-13),'__',' '),'_',' ') as Reward,

          count(uuid) as total_screen_views,
          count(distinct uuid) as unique_screen_views,
      # min(date) as min_date, max(date) as max_date
        FROM
          (SELECT
            date,
            #device.operatingSystem AS operatingsystem,
            (CASE
                WHEN cd.index=12 THEN cd.value
                ELSE NULL END) AS uuid,
            h.eventinfo.eventaction AS eventaction,
            h.appInfo.screenName AS screenname,
            h.hitnumber AS hitnumber,
            visitid
          FROM
          `wwi-data-playground-3.wwi_processed_data_std_views.ga_session_view` as a
          JOIN
            UNNEST (customdimensions) AS cd
          JOIN
            UNNEST (hits) AS h
          JOIN
            UNNEST (h.customdimensions) AS hcd
          WHERE
            suffix BETWEEN format_date('%Y%m%d', date_sub(current_date(), interval 15 day)) and format_date('%Y%m%d', current_date())
            AND h.appInfo.screenName = 'rewards_onboarding_fullscreen'
            AND (hcd.index= 3
              AND hcd.value= 'us')
            AND date BETWEEN format_date('%Y%m%d', date_sub(current_date(), interval 14 day)) and format_date('%Y%m%d', date_sub(current_date(), interval 1 day))
            AND h.type = 'APPVIEW'
            AND (CASE WHEN cd.index=12 THEN cd.value ELSE NULL END) IS NOT NULL

            ) as sub
        group by 1
        order by 3 desc ;;
  }
  dimension: date {
    type: string
    sql: ${TABLE}.date ;;
  }

  # dimension: min_date {
  #   type: string
  #   sql: ${TABLE}.min_date ;;
  # }

  # dimension: reward {
  #   type: string
  #   sql: ${TABLE}.Reward ;;
  # }

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

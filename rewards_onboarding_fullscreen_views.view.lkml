view: rewards_onboarding_fullscreen_views {
  derived_table: {
    explore_source: ga_sessions {
      column: visitStart_date {}
      column: operatingSystem { field: device.operatingSystem }
      column: appVersion { field: hits_appInfo.appVersion }
      column: unique_visitors {}
      filters: {
        field: ga_sessions.partition_date
        value: "7 days ago for 7 days"
      }
      filters: {
        field: hits_appInfo.appVersion
        value: "7.0.0"
      }
      filters: {
        field: hits_appInfo.screenName
        value: "rewards%"
      }
      filters: {
        field: ga_sessions.visitStart_date
        value: "7 days"
      }
    }
  }
  dimension: visitStart_date {
    label: "Session Visit Start Date"
    type: date_date
  }
  dimension: operatingSystem {
    label: "Session: Device Operating System"
  }
  dimension: appVersion {
    label: "Session: Hits: App Info Appversion"
  }
  dimension: unique_visitors {
    label: "Session Unique Visitors"
    type: number
  }
}




#   derived_table: {
#     # persist_for: "24 hours"
#     sql_trigger_value: select current_date() ;;
#     sql: select date,
#       COUNT(DISTINCT fullVisitorId ) AS unique_screen_views,
#       count(fullVisitorId) AS total_screen_views
#             FROM
#               (SELECT
#                 date,
#                 fullVisitorId,
#                 #device.operatingSystem AS operatingsystem,
#                 (CASE
#                     WHEN cd.index=12 THEN cd.value
#                     ELSE NULL END) AS uuid,
#                 h.eventinfo.eventaction AS eventaction,
#                 h.appInfo.screenName AS screenname,
#                 h.hitnumber AS hitnumber,
#                 visitid
#               FROM
#               `wwi-data-playground-3.wwi_processed_data_std_views.ga_session_view` as ga
#               JOIN
#                 UNNEST (customdimensions) AS cd
#               JOIN
#                 UNNEST (hits) AS h
#               JOIN
#                 UNNEST (h.customdimensions) AS hcd
#               WHERE
#                 suffix BETWEEN format_date('%Y%m%d', date_sub(current_date(), interval 15 day)) and format_date('%Y%m%d', current_date())
#                 AND h.appInfo.screenName = 'rewards_onboarding_fullscreen'
#                 AND (hcd.index= 3
#                   AND hcd.value= 'us')
#                 AND date BETWEEN format_date('%Y%m%d', date_sub(current_date(), interval 14 day)) and format_date('%Y%m%d', date_sub(current_date(), interval 1 day))
#                 AND h.type = 'APPVIEW'
#                 AND (CASE WHEN cd.index=12 THEN cd.value ELSE NULL END) IS NOT NULL
#                 ) as sub
#             group by 1
#             order by 1 asc ;;
#   }
#
#   dimension_group: date {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql:  cast(parse_date('%Y%m%d', ${TABLE}.date) as timestamp) ;;
#     # sql:  cast(${TABLE}.date as timestamp)
#   }
#
#   measure: total_screen_views {
#     type: max
#     sql: ${TABLE}.total_screen_views ;;
#   }
#
#   measure: unique_screen_views {
#     type: max
#     sql: ${TABLE}.unique_screen_views ;;
#   }
#
#   measure: count {
#     type: count
#     drill_fields: []
#   }
# }

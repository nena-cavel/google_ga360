
view: ga_sessions_monthly {
  view_label: "Monthly Sessions Summary"
  derived_table: {
    datagroup_trigger: weekly_cache
    explore_source: ga_sessions {
      timezone: "America/New_York"
      column: visitStart_month {}
      column: operatingSystem {field: device.operatingSystem}
      column: screenName { field: hits_appInfo.screenName}
      column: market {}
      column: connect_users {}
      derived_column: my_day_users {
          sql: case when  screenName = 'food_dashboard' then fullVisitorId end ;;
      }
      column: groups_visits {}
      column: fullVisitorId {}
      derived_column: barcode_scanners {
        sql: CASE WHEN barcode_scan_names is not null then fullVisitorId end ;;
        }
      column: total_barcode_scans {}
      column: barcode_scan_names {field: hits_eventInfo.barcode_scan_names}
#       column: unique_invited_visitors { field: invited_users.unique_visitors }
      filters: {
        field: ga_sessions.partition_date
        value: "70 weeks ago for 70 weeks"
#         value: "1 weeks ago for 1 weeks"
      }
      filters: {
        field: ga_sessions.visitStart_week
        value: "70 weeks ago for 70 weeks"
#           value: "1 weeks ago for 1 weeks"
      }

#       filters: {
#         field: invited_users.partition_date
#         value: "70 weeks ago for 70 weeks"
#         # value: "1 weeks ago for 1 weeks"
#       }
#       filters: {
#         # This filter enables us to force a left join on the invited_users view.
#         field: invited_users.left_join
#         value: "Yes"
#       }

    }
  }
  dimension: visitStart_month {
    view_label: "Session"
    label: "Visit Start Month"
    type: date_month
    convert_tz: no
  }
  dimension: market {
    view_label: "Session"
    label: "Market"
  }

  dimension: operatingSystem {
    view_label: "Session"
    type: string
  }

  dimension: deviceCategory {
    view_label: "Session"
    label: "Device Category"
  }

  measure: connect_users {
    view_label: "Session"
    type: sum
  }

measure: barcode_scanners {
  view_label: "Session"
  type: count_distinct
}

measure: total_barcode_scans {
  view_label: "Session"
  type: sum
}

dimension: barcode_scan_names {
  view_label: "Session"
  type: string
}

  measure: my_day_users {
    view_label: "Session"
    type: count_distinct
  }


  measure: groups_users {
    view_label: "Session"
    type: sum
  }

  measure: unique_visitors {
    view_label: "Session"
    label: "Unique Visitors"
    type: sum
  }


}

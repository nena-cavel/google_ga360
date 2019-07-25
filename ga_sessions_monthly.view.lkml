
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
      column: language { field: device.language}
      column: event_action { field: hits_eventInfo.eventAction}
      column: event_label { field: hits_eventInfo.eventLabel}
      derived_column: group_id {
        sql: case when regexp_contains(event_action, 'connect_groups') then event_label end  ;;
      }
      column: connect_users {}
      derived_column: my_day_users {
          sql: case when  screenName = 'food_dashboard' then fullVisitorId end ;;
      }

      column: fullVisitorId {}
      derived_column: barcode_scanners {
        sql: CASE WHEN barcode_scan_names is not null then fullVisitorId end ;;
        }
      column: total_barcode_scans {}
      derived_column: groups_users {
        sql: case when event_action = 'connect_groups_landing' then fullVisitorId end ;;
      }
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

 dimension: region_name {
   type: string
  sql: CASE WHEN ${market} = 'US' THEN 'United States'
            WHEN ${market} = 'DE' THEN 'Germany'
            WHEN ${market} = 'GB' then 'United Kingdom'
            WHEN ${market} = 'FR' then 'France'
            WHEN ${market} = 'CA' then 'Canada'
            when ${market} = 'SE' then 'Sweden'
            when ${market} = 'AU' then 'ANZ'
            WHEN ${market} = 'NL' then 'Netherlands'
            when ${market} = 'BE' then 'Belgium'
            WHEN ${market} = 'CH' then 'Switzerland'
            end ;;
 }



  dimension: language {
    type: string
  }

  dimension: device_language {
    type: string
    sql: CASE WHEN regexp_contains(${language}, 'en-') then 'English'
              WHEN regexp_contains(${language}, 'de-') then 'German'
              when regexp_contains(${language}, 'fr-') then 'French'
              WHEN regexp_contains(${language}, 'nl-') then 'Dutch'
              WHEN regexp_contains(${language}, 'sv-') then 'Swedish'
              WHEN regexp_contains(${language}, 'pt-') then 'Portuguese'
              END;;
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

dimension: group_id {
  type: string
}

  measure: groups_users {
    view_label: "Session"
    type: count_distinct
  }

  measure: unique_visitors {
    view_label: "Session"
    label: "Unique Visitors"
    type: sum
  }


}

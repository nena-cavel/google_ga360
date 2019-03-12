view: temp_test_view {
  derived_table: {
        explore_source: ga_sessions {
            column: visitStart_date {}
            column: unique_visitors {}
            filters: {
              field: ga_sessions.partition_date
              value: "8 days ago for 8 days"
            }
            filters: {
              field: hits_eventInfo.eventAction
              value: "%track%"
            }
            filters: {
              field: device.isMobile
              value: "Yes"
            }
            filters: {
              field: device.browser
              value: "GoogleAnalytics"
            }
            filters: {
              field: geoNetwork.country
              value: ""
            }
            filters: {
              field: ga_sessions.visitStart_date
              value: "7 days"
            }
            filters: {
              field: ga_sessions.market
              value: "US"
            }
        }
    }


    # dimension: visitStart_date {
    #   label: "Session Visit Start Date"
    #   type: date
    # }
    # dimension: unique_visitors {
    #   label: "Session Unique Visitors"
    #   type: number
    # }

  # dimension_group: session_date {
  #   type: time
  #   timeframes: [
  #     raw,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   convert_tz: no
  #   datatype: date
  #   sql: ${TABLE}.session_date ;;
  #

      dimension_group: session_date {
      type: time
      timeframes: [
        raw,
        date,
        week,
        month,
        quarter,
        year
      ]
      convert_tz: no
      datatype: date
      sql: ${TABLE}.visitStart_date ;;
    }

    measure: baseline {
      sql:  642154  ;;
      value_format_name: none
      type: average
    }

    measure: baseline_3mos_percentage {
      sql: 0.1834695353 ;;
      value_format: " "
      type:  average
    }

    measure: baseline_1yr_percentage {
      sql: 0.2173804809 ;;
      value_format: " "
      type:  average
    }

    measure: baseline_3mos {
      sql: 528206  ;;
      value_format_name: none
      type: average
    }

    measure: unique_visitors {
      label: "Unique Visitors"
      value_format_name: thousands
      type: average
    }
  }

  named_value_format: none {
    value_format: " "
  }

  named_value_format: millions {
    value_format: "0.0,,\"M\""
  }

  named_value_format: thousands {
    value_format: "0,\"K\""
  }

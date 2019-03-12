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
    dimension: visitStart_date {
      label: "Session Visit Start Date"
      type: date
    }
    dimension: unique_visitors {
      label: "Session Unique Visitors"
      type: number
    }
  }

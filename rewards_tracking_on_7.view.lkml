view: rewards_tracking_on_7 {
    derived_table: {
      explore_source: ga_sessions {
        column: appVersion { field: hits_appInfo.appVersion }
        column: unique_visitors {}
        column: total_visitors {}
        filters: {
          field: ga_sessions.partition_date
          value: "7 days ago for 7 days"
        }
        filters: {
          field: device.browser
          value: "GoogleAnalytics"
        }
        filters: {
          field: hits_appInfo.screenName
          value: "Track"
        }
      }
    }
    dimension: appVersion {
      label: "Session: Hits: App Info Appversion"
    }

    dimension: myappversion {
      sql: if((${hits_appInfo.appVersion})="7.0.0", "7","NOT 7") ;;
    }


    measure: unique_visitors {
      label: "Session Unique Visitors"
      type: max
    }
    measure: total_visitors {
      label: "Session Total Visitors"
      type: max
    }
  }

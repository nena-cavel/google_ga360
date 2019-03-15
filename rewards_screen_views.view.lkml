view: rewards_screen_views {
    derived_table: {
      explore_source: ga_sessions {
        column: visitStart_date {}
        column: memberID {}
        column: screenName { field: hits_appInfo.screenName }
        column: market {}
        column: count { field: hits.count }
        column: id {}
        filters: {
          field: ga_sessions.partition_date
          value: "12 weeks ago for 12 weeks"
        }
        filters: {
          field: ga_sessions.visitStart_date
          value: "12 weeks ago for 12 weeks"
        }
        filters: {
          field: hits_appInfo.screenName
          value: "rewards%"
        }
      }
    }
    dimension: visitStart_date {
      label: "Session Visit Start Date"
      type: date
    }
    dimension: memberID {
      label: "Session Memberid"
    }
    dimension: screenName {
      label: "Session: Hits: App Info Screenname"
    }
    dimension: market {
      label: "Session Market"
    }
    measure: count {
      label: "Session: Hits Count"
      type: count
    }
    dimension: id {
      label: "Session ID"
    }
  }

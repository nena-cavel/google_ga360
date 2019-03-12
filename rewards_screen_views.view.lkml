view: rewards_screen_views {
  derived_table: {
    explore_source: ga_sessions {
      column: visitStart_week_of_year {}
      column: memberID {}
      column: id {}
      column: market {}
      column: screenName { field: hits_appInfo.screenName }
      filters: {
        field: ga_sessions.partition_date
        value: "1 weeks ago for 1 weeks"
      }
      filters: {
        field: hits_appInfo.screenName
        value: "rewards%"
      }
      filters: {
        field: ga_sessions.market
        value: "GB,FR,CA,DE,US"
      }
    }
  }
  dimension: visitStart_week_of_year {
    label: "Session Visit Start Week of Year"
    type: date_week_of_year
  }
  dimension: memberID {
    label: "Session Memberid"
  }
  dimension: id {
    label: "Session ID"
  }
  dimension: market {
    label: "Session Market"
  }
  dimension: screenName {
    label: "Session: Hits: App Info Screenname"
  }
}

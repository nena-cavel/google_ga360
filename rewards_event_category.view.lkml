view: rewards_event_category {
  derived_table: {
    explore_source: ga_sessions {
      column: visitStart_date {}
      column: id {}
      column: memberID {}
      column: eventLabel { field: hits_eventInfo.eventLabel }
      column: screenName { field: hits_appInfo.screenName }
      filters: {
        field: ga_sessions.partition_date
        value: "7 days ago for 7 days"
      }
      filters: {
        field: hits_eventInfo.eventCategory
        value: "rewards"
      }
      filters: {
        field: ga_sessions.visitStart_date
        value: "7 days"
      }
    }
  }
  dimension: visitStart_date {
    label: "Session Visit Start Date"
    type: date
  }
  dimension: id {
    label: "Session ID"
  }
  dimension: memberID {
    label: "Session Memberid"
  }
  dimension: eventLabel {
    label: "Session: Hits: Events Info Event Label"
  }
  dimension: screenName {
    label: "Session: Hits: App Info Screenname"
  }
}

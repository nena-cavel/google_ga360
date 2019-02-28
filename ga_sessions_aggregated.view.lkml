datagroup: weekly_cache {
  sql_trigger: select EXTRACT(ISOWEEK FROM CURRENT_DATE('America/New_York')) ;;
}

datagroup: daily_cache {
  sql_trigger: select EXTRACT(DATE FROM CURRENT_DATE('America/New_York')) ;;
}
view: ga_sessions_weekly {
  derived_table: {
    datagroup_trigger: weekly_cache
    explore_source: ga_sessions {
      timezone: "America/New_York"
      column: visitStart_week {}
      column: market {}
      column: is_google_analytics { field: device.is_google_analytics }
      column: is_weightwatchers { field: first_page.is_weightwatchers }
      column: sus1_visitors {}
      column: homepage_visitors {}
      column: deviceCategory { field: device.deviceCategory }
      column: unique_prospects {}
      column: unique_visitors {}
      column: count_sessions_event1 { field: funnel_growth_dashboard.count_sessions_event1_prospects }
      column: count_sessions_event12 { field: funnel_growth_dashboard.count_sessions_event12_prospects }
      column: count_sessions_event123 { field: funnel_growth_dashboard.count_sessions_event123_prospects }
      column: count_sessions_event1234 { field: funnel_growth_dashboard.count_sessions_event1234_prospects }
      column: count_sessions_event12345 { field: funnel_growth_dashboard.count_sessions_event12345_prospects }
      column: unique_invited_visitors { field: invited_users.unique_visitors }
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
      filters: {
        field: funnel_growth_dashboard.partition_date
        value: "70 weeks ago for 70 weeks"
#         value: "1 weeks ago for 1 weeks"
      }

    }
  }
  dimension: visitStart_week {
    view_label: "Session"
    label: "Visit Start Week"
    type: date_week
    convert_tz: no
  }
  dimension: market {
    view_label: "Session"
    label: "Market"
  }
  dimension: is_google_analytics {
    view_label: "Session"
    label: "Device Is Google Analytics"
    type: yesno
  }
  dimension: is_weightwatchers {
    view_label: "Session:First Page Visited"
    label: "Is weightwatchers.com"
    type: yesno
  }

  dimension: deviceCategory {
    view_label: "Session"
    label: "Device Category"
  }
  measure: unique_prospects {
    view_label: "Session"
    label: "Unique Prospects"
    type: sum
  }
  measure: unique_visitors {
    view_label: "Session"
    label: "Unique Visitors"
    type: sum
  }
  measure: sus1_visitors {
    view_label: "Session"
    label: "SUS1 Visitors"
    type: sum
  }
  measure: homepage_visitors {
    view_label: "Session"
    label: "Homepage Visitors"
    type: sum
  }
  measure: count_sessions_event1 {
    view_label: "Funnel Growth Dashboard"
    label: "Sign up Step 1"
    type: sum
  }
  measure: count_sessions_event12 {
    view_label: "Funnel Growth Dashboard"
    label: "Registration"
    description: "Only includes sessions which also completed event 1"
    type: sum
  }
  measure: count_sessions_event123 {
    view_label: "Funnel Growth Dashboard"
    label: "Payment"
    description: "Only includes sessions which also completed events 1 and 2"
    type: sum
  }
  measure: count_sessions_event1234 {
    view_label: "Funnel Growth Dashboard"
    label: "Review"
    description: "Only includes sessions which also completed events 1, 2 and 3"
    type: sum
  }
  measure: count_sessions_event12345 {
    view_label: "Funnel Growth Dashboard"
    label: "Confirmation"
    description: "Only includes sessions which also completed events 1, 2, 3 and 4"
    type: sum
  }
  measure: unique_invited_visitors {
    type: sum
    view_label: "Invited Visitors"
  }
}


view: ga_sessions_daily {
  derived_table: {
    datagroup_trigger: daily_cache
    explore_source: ga_sessions {
      timezone: "America/New_York"
      column: visitStart_date {}
      column: market {}
      column: funnelProspect {}
      column: Prospect {}
      column: is_sus1 { field: hits_contentGroup.is_sus1 }
      column: is_google_analytics { field: device.is_google_analytics }
      column: unique_visitors {}
      column: is_weightwatchers { field: first_page.is_weightwatchers }
      column: deviceCategory { field: device.deviceCategory }
      column: count_sessions_event1 { field: funnel_growth_dashboard.count_sessions_event1 }
      column: count_sessions_event12 { field: funnel_growth_dashboard.count_sessions_event12 }
      column: count_sessions_event123 { field: funnel_growth_dashboard.count_sessions_event123 }
      column: count_sessions_event1234 { field: funnel_growth_dashboard.count_sessions_event1234 }
      column: count_sessions_event12345 { field: funnel_growth_dashboard.count_sessions_event12345 }
      filters: {
        field: ga_sessions.partition_date
        value: "60 weeks ago for 60 weeks"
      }
      filters: {
        field: funnel_growth_dashboard.partition_date
        value: "60 weeks ago for 60 weeks"
      }
      filters: {
        field: ga_sessions.visitStart_week
        value: "60 weeks ago for 60 weeks"
      }
    }
  }
  dimension: visitStart_date {
    view_label: "Session"
    label: "Visit Start Date"
    type: date
    convert_tz: no
  }
  dimension: market {
    view_label: "Session"
    label: "Market"
  }
  dimension: funnelProspect {
    view_label: "Session"
    label: "Funnel prospect"
    type: yesno
  }
  dimension: prospect {
    view_label: "Session"
    label: "Prospect"
    type: yesno
  }
  dimension: is_sus1 {
    view_label: "Session: Hits: ContentGroup"
    label: "Is SUS1 (Yes / No)"
    type: yesno
  }
  dimension: is_google_analytics {
    view_label: "Session"
    label: "Device Is Google Analytics"
    type: yesno
  }
  dimension: is_weightwatchers {
    view_label: "Session:First Page Visited"
    label: "Is weightwatchers.com"
    type: yesno
  }
  dimension: deviceCategory {
    view_label: "Session"
    label: "Device Category"
  }
  measure: unique_visitors {
    view_label: "Session"
    label: "Unique Visitors"
    type: sum
  }
  measure: count_sessions_event1 {
    view_label: "Funnel Growth Dashboard"
    label: "Sign up Step 1"
    type: sum
  }
  measure: count_sessions_event12 {
    view_label: "Funnel Growth Dashboard"
    label: "Registration"
    description: "Only includes sessions which also completed event 1"
    type: sum
  }
  measure: count_sessions_event123 {
    view_label: "Funnel Growth Dashboard"
    label: "Payment"
    description: "Only includes sessions which also completed events 1 and 2"
    type: sum
  }
  measure: count_sessions_event1234 {
    view_label: "Funnel Growth Dashboard"
    label: "Review"
    description: "Only includes sessions which also completed events 1, 2 and 3"
    type: sum
  }
  measure: count_sessions_event12345 {
    view_label: "Funnel Growth Dashboard"
    label: "Confirmation"
    description: "Only includes sessions which also completed events 1, 2, 3 and 4"
    type: sum
  }
}
explore: ga_sessions_weekly {
  persist_with: weekly_cache
}
explore: ga_sessions_daily {}

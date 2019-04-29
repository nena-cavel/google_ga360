
view: ga_sessions_weekly {
  view_label: "Weekly Sessions Summary"
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
      column: connect_users {}
      column: groups_users {}
      column: homepage_prospect_visitors {}
      column: deviceCategory { field: device.deviceCategory }
      column: unique_prospects {}
      column: unique_funnel_prospects {}
      column: unique_visitors {}
      column: transactions_count { field: totals.transactions_count }
      column: count_sessions_event1 { field: funnel_growth_dashboard.count_sessions_event1_prospects }
      column: count_sessions_event12 { field: funnel_growth_dashboard.count_sessions_event12_prospects }
      column: count_sessions_event123 { field: funnel_growth_dashboard.count_sessions_event123_prospects }
      column: count_sessions_event1234 { field: funnel_growth_dashboard.count_sessions_event1234_prospects }
      column: count_sessions_event12345 { field: funnel_growth_dashboard.count_sessions_event12345_prospects }
      column: iaf_copyLink_desktop {}
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
      filters: {
        field: funnel_growth_dashboard.partition_date
        value: "70 weeks ago for 70 weeks"
        # value: "1 weeks ago for 1 weeks"
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

  measure: connect_users {
    type: sum
  }

  measure: iaf_copyLink_desktop {
    type: sum
  }

  measure: groups_users {
    type: sum
  }
  measure: transactions_count {
    view_label: "Session"
    label: "Session Transactions Count"
    type: sum
  }
  measure: unique_prospects {
    view_label: "Session"
    label: "Unique Prospects"
    type: sum
  }
  measure: unique_funnel_prospects {
    view_label: "Session"
    label: "Unique Funnel Prospects"
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
  measure: homepage_prospect_visitors {
    view_label: "Session"
    label: "Homepage Prspect Visitors"
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

view: ga_iaf_weekly {
  view_label: "Weekly Invite A Friend Summary"
  derived_table: {
    datagroup_trigger: weekly_cache
    explore_source: ga_sessions {
      timezone: "America/New_York"
      column: visitStart_week {}
      column: market {}
      column: is_google_analytics { field: device.is_google_analytics }
      column: is_weightwatchers { field: first_page.is_weightwatchers }
      column: homepage_prospect_visitors {}
      column: deviceCategory { field: device.deviceCategory }
      column: unique_visitors {}
      column: transactions_count { field: totals.transactions_count }
      column: unique_invited_visitors { field: invited_users.unique_visitors }
      column: unique_funnel_prospects {field:invited_users.unique_funnel_prospects}
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
        field: invited_users.partition_date
        value: "70 weeks ago for 70 weeks"
        # value: "1 weeks ago for 1 weeks"
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
  measure: transactions_count {
    view_label: "Session"
    label: "Session Transactions Count"
    type: sum
  }
  measure: unique_invited_visitors {
    type: sum
    view_label: "Invited Visitors"
  }
  measure: unique_funnel_prospects {
    type: sum
    view_label: "Invited Visitors"
  }
}

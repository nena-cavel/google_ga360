view: connect_test {
  view_label: "Weekly Sessions Summary"
  derived_table: {
    datagroup_trigger: weekly_cache
    explore_source: ga_sessions {
      timezone: "America/New_York"
      column: visitStart_week {}
      column: market {}
      column: group_id_name {field:hits_eventInfo.group_id_name}
      column: unique_visitors {}
#       column: unique_invited_visitors { field: invited_users.unique_visitors }
      filters: {
        field: ga_sessions.partition_date
        value: "5 weeks ago for 5 weeks"
#         value: "1 weeks ago for 1 weeks"
      }
      filters: {
        field: ga_sessions.visitStart_week
        value: "5 weeks ago for 5 weeks"
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
  dimension: visitStart_week {
    hidden: yes
    view_label: "Session"
    label: "Visit Start Week"
    type: date_week
    convert_tz: no
  }
  dimension: market {
    hidden: yes
    view_label: "Session"
    label: "Market"
  }


dimension: group_id_name {
  view_label: "Connect"
}
  measure: unique_visitors {
    view_label: "Connect"
    type: sum
  }

}

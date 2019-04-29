

  view: session_fact {
    view_label: "Session"
    derived_table: {

      datagroup_trigger: daily_sessions_cache
      explore_source: ga_sessions {
        column: id {}
        column: funnel_prospect_session_count {}
        filters: {
          field: ga_sessions.partition_date
          value: "16 months"
        }
      }
    }
    dimension: id {
      hidden: yes
      label: "Session ID"
    }
    dimension: funnel_prospect_session_count {
      hidden: yes
      label: "Session Funnel Prospect Session Count"
      type: number
    }

    dimension: is_prospect{
      type: yesno
      sql: ${funnel_prospect_session_count} = 1;;
    }
  }

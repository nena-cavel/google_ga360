

  view: session_fact {
    view_label: "Session"
    derived_table: {

      explore_source: ga_sessions {
        timezone: "America/New_York"
        column: visitStart_date {}
        column: id {}
        column: funnel_prospect_session_count {}
        column: completed_onb_session_count_start {field:hits_eventInfo.completed_onb_session_count_start}
        column: completed_onb_session_count_finish {field:hits_eventInfo.completed_onb_session_count_finish}
        column:  iaf_page_desktop_users {}
        column: channelGrouping {}
        column: fullVisitorId {}
        filters: {
          field: ga_sessions.partition_date
          value: "70 weeks ago for 70 weeks"
        }
        filters: {
          field: ga_sessions.visitStart_date
          value: "70 weeks ago for 70 weeks"
        }

      }
      datagroup_trigger: daily_sessions_cache
    }

    dimension: visitStart_date {
      hidden: yes
      view_label: "Session"
      label: "Visit Start Week"
      type: date
      convert_tz: no
    }

    dimension: fullVisitorId {
      hidden: yes
      label: "FullVisitorID"
    }

    dimension: id {
      hidden: yes
      label: "Session ID"
    }

    dimension:  iaf_page_desktop_users {
      hidden: yes
      type: number
    }

    dimension: channelGrouping {
      hidden: yes
      type: string
    }

    dimension: funnel_prospect_session_count {
      hidden: yes
      label: "Session Funnel Prospect Session Count"
      type: number
    }

    dimension:  completed_onb_session_count_start {
      hidden: yes
      label: "Session ONB completed Session Count Start"
      type: number
    }


    dimension:  completed_onb_session_count_finish {
      hidden: yes
      label: "Session ONB completed Session Count Finish"
      type: number
    }

    dimension: did_ONB_start {
      type: yesno
      sql: ${completed_onb_session_count_start}= 1 ;;
    }

    dimension: did_ONB_finish {
      type: yesno
      sql: ${completed_onb_session_count_finish}= 1 ;;
    }


    dimension: did_ONB_completed {
      type: yesno
      sql: ${completed_onb_session_count_finish}= 1 and ${completed_onb_session_count_start}= 1 ;;
    }

    dimension: is_prospect{
      type: yesno
      sql: ${funnel_prospect_session_count} = 1;;
    }
  }

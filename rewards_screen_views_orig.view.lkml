view: rewards_screen_views_orig {
  derived_table: {
    explore_source: ga_sessions {
      column: visitStart_date {}
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
  # CAN THIS BE A DIMENSION_GROUP? CAN IT HAVE THE LIST OF TIMEFRAMES IF IT'S NOT A GROUP?
  # dimension_group: visitStart_date {
  #   label: "Session Visit Start Date"
  #   type: date
  #   timeframes: [
  #     raw,
  #     date,
  #     week,
  #     month,
  #     quarter,
  #     year
  #   ]
  #   convert_tz: no
  #   datatype: date
  #   sql: ${visitStart_date} ;;
  # }

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

  # PARTS BELOW HERE I MADE UP. NO IDEA WHETHER THEY WORK, BECAUSE THE TIME VARIABLE F*CKED UP THE EFFORT
  measure: unique_rewards_visitors {
    label: "Unique Rewards Visitors"
    type: count_distinct
    sql: ${memberID} ;;
  }

  measure: unique_dashboard_visitors {
    label: "Unique Dashboard Visitors"
    type: count_distinct
    sql: case when ${screenName}='rewards_wins_dashboard' then ${memberID} else null end ;;
  }
}




# max(case when hits_appInfo.screenName = 'rewards_wins_dashboard' then 1 else 0 end) as visited_dashboard,
#               max(case when hits_appInfo.screenName = 'rewards_browse_rewards' then 1 else 0 end) as browsed_rewards,
#               max(case when hits_appInfo.screenName like 'rewards_%_en_us' then 1 else 0 end) as viewed_detail,
#               max(case when hits_eventInfo.eventCategory='rewards' and hits_eventInfo.eventLabel like 'redeem%' then 1 else 0 end) as prize_redemption

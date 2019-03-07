connection: "prod-data-playground-std-bq"

# include all the views
include: "*.view"
week_start_day: sunday
# include all the dashboards
include: "*.dashboard"

explore: ga_sessions {
  extends: [ga_sessions_block]
  join: funnel_growth_dashboard {
    from: funnel_growth_dashboard
    type: inner
    relationship:  one_to_one
    sql_on: ${ga_sessions.funnelid}=${funnel_growth_dashboard.id} ;;
  }
 join: invited_users {
   from: invited_users
   type: inner
   relationship: one_to_one
   sql_on: ${invited_users.fullvisitorid}=${ga_sessions.fullVisitorId}
      AND ${invited_users.two_days_later} >= cast(concat(substr(${ga_sessions.date},0,4),'-',substr(${ga_sessions.date},5,2),'-',substr(${ga_sessions.date},7,2)) AS DATETIME)
      AND ${invited_users.iaf} <= Cast(concat(substr(${ga_sessions.date},0,4),'-',substr(${ga_sessions.date},5,2),'-',substr(${ga_sessions.date},7,2)) AS DATETIME);;
 }
  join: b2b_signup_funnel {
    from: b2b_signup_funnel
    type: inner
    relationship:  one_to_one
    sql_on: ${ga_sessions.funnelid}=${b2b_signup_funnel.id} ;;
  }
}


explore: dau_mau_derived {
persist_for: "72 hours"
}

explore: connect_penetration {
  persist_for: "72 hours"
}

explore: engagement_score{
  persist_for: "100 hours"
  join: post_love_score_daily {
    type: inner
    relationship: one_to_one
    sql_on: ${engagement_score.region}=${post_love_score_daily.region}
      AND ${engagement_score.region_group} = ${post_love_score_daily.region_group}
      and ${engagement_score.session_date_date} = ${post_love_score_daily.date_date};;
  }


}

explore: poster_love {
  persist_for: "72 hours"
}

explore:rewards_prize_views_20180910 {
  persist_for: "24 hours"
}

explore: rewards_onboarding_fullscreen_views {
  persist_for: "24 hours"
}

explore: rewards_unique_visitors {
  persist_for: "24 hours"
}

explore: rewards_tracking_on_7 {
  persist_for: "24 hours"
}

explore: post_love_score_daily {
  persist_for: "48 hours"
}

explore: groups_launch {
  persist_for: "48 hours"

}

explore: reported_posts {
  persist_for: "48 hours"
}


explore: daily_uniques_eventaction_track {}

explore: barcode_scanner_report {
  persist_for: "72 hours"
}
explore: connect_daily_counts {
  persist_for: "48 hours"

}

explore: groups_kpis {
  persist_for: "96 hours"
}

explore: groups_kpi_weekly {
persist_for: "96 hours"
}

explore: new_autobanned_words {
  join: new_autobanned_comments {
    type: inner
    relationship: one_to_one
    sql_on: ${new_autobanned_words.week_raw}=${new_autobanned_comments.week_raw}
    AND ${new_autobanned_words.word}=${new_autobanned_comments.word};;
  }
}

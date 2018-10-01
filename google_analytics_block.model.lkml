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
}


explore: dau_mau_derived {
persist_for: "240 hours"
}

explore:rewards_prize_views_20180910 {
  persist_for: "24 hours"
}

# explore:my_day_vs_journey_unique_visitors {
#   persist_for: "168 hours"
# }

explore: rewards_onboarding_fullscreen_views {
  persist_for: "24 hours"
}

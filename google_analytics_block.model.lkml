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
}


explore: dau_mau_derived {
persist_for: "240 hours"
}

explore:rewards_prize_views_20180910 {
  persist_for: "24 hours"
}

explore:my_day_vs_journey_unique_visitors {
  persist_for: "24 hours"
}

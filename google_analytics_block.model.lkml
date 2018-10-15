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
    sql_on: ${ga_sessions.id}=${funnel_growth_dashboard.id} ;;
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
}

explore: poster_love {
  persist_for: "72 hours"
}

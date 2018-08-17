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

#explore:funnel_growth_dashboard {
#  hidden: no
#  join: ga_sessions {
#    from: ga_sessions
#    type: left_outer
#    relationship: one_to_one
#    sql_on: ${funnel_growth_dashboard.id}=${ga_sessions.id} ;;
#  }
#  }

connection: "prod-data-playground-std-bq"

# include all the views
include: "*.view"
week_start_day: sunday
# include all the dashboards
include: "*.dashboard"

#### DATAGROUPS

datagroup: weekly_cache {
  sql_trigger: select EXTRACT(WEEK FROM CURRENT_DATE('America/New_York')) ;;
}

datagroup: daily_sessions_cache {
  sql_trigger: select extract(dayofweek from timestamp_sub(current_timestamp(), interval 11 hour)) as every_day ;;
}

datagroup: static_pdt {
  sql_trigger:  select 1 ;;
}

#### EXPLORES

explore: ga_sessions {
  persist_with: daily_sessions_cache
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
  join: session_fact {
    from: session_fact
    type: left_outer
    relationship: one_to_one
    sql_on: ${ga_sessions.id} = ${session_fact.id} ;;
  }
# join: invited_users_left {
#   from: invited_users
#   type: left_outer
#   relationship: one_to_one
#   sql_on: ${invited_users.fullvisitorid}=${ga_sessions.fullVisitorId}
#       AND ${invited_users.two_days_later} >= cast(concat(substr(${ga_sessions.date},0,4),'-',substr(${ga_sessions.date},5,2),'-',substr(${ga_sessions.date},7,2)) AS DATETIME)
#       AND ${invited_users.iaf} <= Cast(concat(substr(${ga_sessions.date},0,4),'-',substr(${ga_sessions.date},5,2),'-',substr(${ga_sessions.date},7,2)) AS DATETIME);;
#
# }
    join: b2b_signup_funnel {
      from: b2b_signup_funnel
      type: inner
      relationship:  one_to_one
      sql_on: ${ga_sessions.funnelid}=${b2b_signup_funnel.id} ;;
    }
  }

explore: dau_mau_derived {
  label: "DAU and MAU Site Metrics"
  from: dau_mau_derived_daily
  persist_with: monthly_cache_ga
  join: dau_mau_derived_monthly {
    from: dau_mau_derived
    type: inner
    relationship: many_to_one
    sql_on: ${dau_mau_derived.site_region}=${dau_mau_derived_monthly.site_region}
        AND ${dau_mau_derived.application_type}= ${dau_mau_derived_monthly.application_type}
        AND ${dau_mau_derived.visitStartday_month} = ${dau_mau_derived_monthly.visitStartmonth_month};;
  }
}

explore: kpi_funnel_static {
  #join: dau_mau_derived {
  #  sql_on: ${kpi_funnel_static.thedate_date}=${dau_mau_derived.visitStartmonth_date} ;;
 # }
}

#   explore: dau_mau_derived {
#     persist_for: "72 hours"
#     join: dau_mau_derived_daily {
#       type: inner
#       relationship: one_to_many
#       sql_on: ${dau_mau_derived.site_region}=${dau_mau_derived_daily.site_region}
#       AND ${dau_mau_derived.application_type}= ${dau_mau_derived_daily.application_type}
#       and ${dau_mau_derived.visitStartmonth_month} = ${dau_mau_derived_daily.visitStartday_month};;
#     }
#   }

  explore: connect_penetration {
    persist_for: "72 hours"
  }

  explore: engagement_score{
    persist_for: "24 hours"
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

  explore: post_love_score_daily {
   # persist_for: "48 hours"
  }

  explore: groups_launch {
    persist_for: "48 hours"

  }

  explore: reported_posts {
    persist_for: "48 hours"
  }

  explore: daily_uniques_eventaction_track {
    hidden: yes
  }

  explore: rewards_prize_views {
    persist_for: "24 hours"
  }

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

explore: ga_sessions_weekly {
  persist_with: weekly_cache
  description: "Aggregates key GA metrics to the weekly level"
}
explore: ga_iaf_weekly {
  persist_with: weekly_cache
}

explore: new_autobanned_words {
  join: new_autobanned_comments {
    type: inner
    relationship: one_to_one
    sql_on: ${new_autobanned_words.week_raw}=${new_autobanned_comments.week_raw}
    AND ${new_autobanned_words.word}=${new_autobanned_comments.word};;
  }
}

explore: reported_posts_new {
  join: reported_comments_new {
    type: inner
    relationship: one_to_one
    sql_on: ${reported_posts_new.week_raw}=${reported_comments_new.week_raw}
    AND ${reported_posts_new.market}=${reported_comments_new.market};;
  }
}

explore: ga_daily_counts {}
explore: media_posting_funnel {}
explore: video_posting_funnel {}
explore: photo_posting_funnel {}
explore: groups_funnel {}
explore: groups_carousel_funnel  {}
explore: ga_sessions_monthly {
  persist_with: monthly_cache_ga
}

connection: "prod-data-playground-std-bq"

# include all the views
include: "*.view"
week_start_day: sunday
# include all the dashboards
include: "*.dashboard"

#### DATAGROUPS

datagroup: weekly_cache {
  sql_trigger: select EXTRACT(ISOWEEK FROM CURRENT_DATE('America/New_York')) ;;
}

datagroup: daily_sessions_cache {
  sql_trigger: select EXTRACT(DATE FROM CURRENT_DATE('America/New_York')) ;;
}

#### EXPLORES

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
    type: left_outer
    relationship: one_to_one
    sql_on: ${invited_users.fullvisitorid}=${ga_sessions.fullVisitorId}
      AND ${invited_users.two_days_later} >= cast(concat(substr(${ga_sessions.date},0,4),'-',substr(${ga_sessions.date},5,2),'-',substr(${ga_sessions.date},7,2)) AS DATETIME)
      AND ${invited_users.iaf} <= Cast(concat(substr(${ga_sessions.date},0,4),'-',substr(${ga_sessions.date},5,2),'-',substr(${ga_sessions.date},7,2)) AS DATETIME);;
# The following toggle allows you to change the join type from Left to inner.
# Setting  ${invited_users.fullvisitorid} to not null makes the join an inner join.
# Setting 1=1 removes the filter and changes the join type to left outer.
      sql_where: {% if invited_users.left_join._parameter_value == "'Yes'" %}
                            1=1
                        {% else %}
          ${invited_users.fullvisitorid} is not null
                        {% endif %};;
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

  explore: post_love_score_daily {
    persist_for: "48 hours"
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

  explore: rewards_prize_views_20180910 {
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

view: invited_users {
  derived_table: {
    sql: SELECT
        ga_sessions.date,
        ga_sessions.fullVisitorId AS fullvisitorid
      FROM ${ga_sessions.SQL_TABLE_NAME}  AS ga_sessions
      LEFT JOIN UNNEST(ga_sessions.hits) as first_hit
      LEFT JOIN UNNEST([first_hit.contentGroup]) as first_pagename

      WHERE (first_hit.hitNumber = 1) AND (first_pagename.contentGroup3 = 'visi:us:invited')
      GROUP BY 1,2
       ;;
  }

  measure: unique_visitors {
    type: count_distinct
    sql: ${fullvisitorid} ;;
    drill_fields: [detail*]

  }

  dimension: date {
    type: date_time
    sql: ${TABLE}.date ;;
  }

  dimension: fullvisitorid {
    type: string
    sql: ${TABLE}.fullvisitorid ;;
  }

  dimension: id {
    type: string
    sql: CONCAT(${fullvisitorid},'|',${date}) ;;
  }

  dimension: iaf {
    hidden: yes
    type:string
    sql: cast(concat(substr(${TABLE}.date,0,4),'-',substr(${TABLE}.date,5,2),'-',substr(${TABLE}.date,7,2)) AS DATETIME) ;;
  }

 dimension: two_days_later{
  hidden: yes
  type: string
  sql: DATETIME_ADD(${iaf}, INTERVAL 2 DAY);;
 }

  set: detail {
    fields: [date, fullvisitorid]
  }
}

# view: invited_users_left {
#   extends: [invited_users]
#   sql_table_name: ${invited_users.SQL_TABLE_NAME} ;;
#   dimension: iaf {hidden:yes}
#   dimension: two_days_later {hidden: yes}
#   dimension: id {hidden: yes}
#   dimension: fullvisitorid {hidden: yes}
#   measure: unique_visitors {hidden: yes}
# }
# explore: invited_users_left {}

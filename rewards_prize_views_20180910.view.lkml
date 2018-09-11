view: rewards_prize_views_20180910 {
  sql_table_name: jleavitt.rewards_prize_views_20180910 ;;

  dimension: max_date {
    type: string
    sql: ${TABLE}.max_date ;;
  }

  dimension: min_date {
    type: string
    sql: ${TABLE}.min_date ;;
  }

  dimension: reward {
    type: string
    sql: ${TABLE}.Reward ;;
  }

  measure: total_screen_views {
    type: max
    sql: ${TABLE}.total_screen_views ;;
  }

  measure: unique_screen_views {
    type: max
    sql: ${TABLE}.unique_screen_views ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}

view: prize_screen_views_20180907 {
  sql_table_name: jleavitt.Prize_Screen_Views_20180907 ;;

  measure: time_on_screen {
    type: string
    sql: parse_time('%M:%S', ${TABLE}.new_time_on_screen) ;;
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

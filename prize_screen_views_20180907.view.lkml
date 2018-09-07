view: prize_screen_views_20180907 {
  sql_table_name: jleavitt.Prize_Screen_Views_20180907 ;;

  measure: time_on_screen {
    type: sum
    sql: (cast(format_time('%M', parse_time('%M:%S', ${TABLE}.new_time_on_screen)) as int64) * 60) +
    cast(format_time('%S', parse_time('%M:%S', ${TABLE}.new_time_on_screen)) as int64) ;;
  }

  dimension: reward {
    type: string
    sql: ${TABLE}.Reward ;;
  }

  measure: total_screen_views {
    type: average
    sql: ${TABLE}.total_screen_views ;;
  }

  measure: unique_screen_views {
    type: average
    sql: ${TABLE}.unique_screen_views ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}

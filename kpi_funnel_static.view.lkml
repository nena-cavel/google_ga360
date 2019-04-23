
view: kpi_funnel_static {
  sql_table_name: jleavitt.kpi_funnel_data ;;

  measure: members {
    type: sum
    sql: ${TABLE}.members ;;
  }

  dimension: member_type {
    type:  string
    sql: ${TABLE}.member_type ;;
  }

  measure: app_visitors {
    type: sum
    sql: ${TABLE}.app_visitors ;;
  }

  measure: browsed_prizes {
    type: sum
    sql: ${TABLE}.browsed_prizes ;;
  }

  measure: prize_redemptions {
    type: sum
    sql: ${TABLE}.prize_redemptions ;;
  }

  dimension: session_week {
    type: number
    sql: ${TABLE}.session_week ;;
  }

  dimension: week_dates {
    type:  string
    sql: case when extract(month from parse_date('%Y-%m-%d', ${TABLE}.thedate)) = extract(month from date_add(parse_date('%Y-%m-%d', ${TABLE}.thedate), interval 6 day))
              then concat(format_date('%B %e', parse_date('%Y-%m-%d', ${TABLE}.thedate)), "-",
                   cast(extract(day from date_add(parse_date('%Y-%m-%d', ${TABLE}.thedate), interval 6 day)) as string))
              else concat(format_date('%B %e', parse_date('%Y-%m-%d', ${TABLE}.thedate)), " - ",
                   format_date('%B %e',date_add(parse_date('%Y-%m-%d', ${TABLE}.thedate), interval 6 day))) end ;;
  }

  dimension: session_year {
    type: number
    sql: ${TABLE}.session_year ;;
  }

  dimension_group: thedate {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: cast(${TABLE}.thedate as date) ;;
  }

  dimension: uuid {
    type: string
    sql: ${TABLE}.uuid ;;
  }

  measure: viewed_detail {
    type: sum
    sql: ${TABLE}.viewed_detail ;;
  }

  measure: dashboard_visitors {
    type: sum
    sql: ${TABLE}.dashboard_visitors ;;
  }

  measure: rewards_visitors {
    type: sum
    sql: ${TABLE}.rewards_visitors ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}

view: sql_runner_query {
  derived_table: {
    sql: select concat(cast(theyear as string), '-', cast(theweek as string)) as year_week,
      total_wins,breakfast_wins,lunch_wins,dinner_wins,activity_wins,weight_wins,meeting_wins,unique_breakfast_trackers,unique_lunch_trackers,unique_dinner_trackers,unique_activity_trackers,unique_weight_trackers,unique_meeting_trackers
      from `wwi-data-playground-3.jleavitt.weekly_wins_summary`
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: year_week {
    type: string
    sql: ${TABLE}.year_week ;;
  }

  dimension: total_wins {
    type: number
    sql: ${TABLE}.total_wins ;;
  }

  dimension: breakfast_wins {
    type: number
    sql: ${TABLE}.breakfast_wins ;;
  }

  dimension: lunch_wins {
    type: number
    sql: ${TABLE}.lunch_wins ;;
  }

  dimension: dinner_wins {
    type: number
    sql: ${TABLE}.dinner_wins ;;
  }

  dimension: activity_wins {
    type: number
    sql: ${TABLE}.activity_wins ;;
  }

  dimension: weight_wins {
    type: number
    sql: ${TABLE}.weight_wins ;;
  }

  dimension: meeting_wins {
    type: number
    sql: ${TABLE}.meeting_wins ;;
  }

  dimension: unique_breakfast_trackers {
    type: number
    sql: ${TABLE}.unique_breakfast_trackers ;;
  }

  dimension: unique_lunch_trackers {
    type: number
    sql: ${TABLE}.unique_lunch_trackers ;;
  }

  dimension: unique_dinner_trackers {
    type: number
    sql: ${TABLE}.unique_dinner_trackers ;;
  }

  dimension: unique_activity_trackers {
    type: number
    sql: ${TABLE}.unique_activity_trackers ;;
  }

  dimension: unique_weight_trackers {
    type: number
    sql: ${TABLE}.unique_weight_trackers ;;
  }

  dimension: unique_meeting_trackers {
    type: number
    sql: ${TABLE}.unique_meeting_trackers ;;
  }

  set: detail {
    fields: [
      year_week,
      total_wins,
      breakfast_wins,
      lunch_wins,
      dinner_wins,
      activity_wins,
      weight_wins,
      meeting_wins,
      unique_breakfast_trackers,
      unique_lunch_trackers,
      unique_dinner_trackers,
      unique_activity_trackers,
      unique_weight_trackers,
      unique_meeting_trackers
    ]
  }
}

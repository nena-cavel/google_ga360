include: "ga_block.view.lkml"
view: cbs_funnel {
  derived_table: {
    sql: SELECT CONCAT(CAST(sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(sessions.date AS STRING),'')) as id
          , sessions.fullVisitorId as full_visitor_id
          , sessions.suffix as suffix
          , MIN(
             CASE WHEN REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^visi:us:CBS-global$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS event_1
          , MIN(
            CASE WHEN
              REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^visi:..:cbs-pricing-page$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS event_2_first
          , MAX(
            CASE WHEN
              REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^visi:..:cbs-pricing-page$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS event_2_last
          , MIN(
            CASE WHEN
            REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:plan$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS event_3_first
          , MAX(
            CASE WHEN
             REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:plan$')
            THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS event_3_last
          , MIN(
            CASE WHEN
            REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:registration$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS event_4_first
          , MAX(
            CASE WHEN
            REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:registration$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS event_4_last
             , MIN(
            CASE WHEN
            REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:payment$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS event_5_first
          , MAX(
            CASE WHEN
            REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:payment$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS event_5_last
          , MIN(
            CASE WHEN
            REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:review$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS event_6_first
          , MAX(
            CASE WHEN
            REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:review$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS event_6_last
          , MIN(
            CASE WHEN
            REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:confirmation$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS event_7_first
          , MAX(
            CASE WHEN
            REGEXP_CONTAINS(hits_contentGroup.contentGroup3, '^sign:..:confirmation$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS event_7_last
         FROM ${ga_sessions.SQL_TABLE_NAME} AS sessions
          LEFT JOIN UNNEST(sessions.hits) as hits
          LEFT JOIN UNNEST([hits.page]) as hits_page
          LEFT JOIN UNNEST([hits.contentGroup]) as hits_contentGroup
        WHERE {% condition event_time %} TIMESTAMP_SECONDS(sessions.visitStarttime) {% endcondition %}
         GROUP BY 1,2,3
          ;;
  }

  filter: event_time {
    type: date_time
  }
  dimension: id {
    type: string
    primary_key: yes
    #   hidden: TRUE
    sql: ${TABLE}.id ;;
  }

  dimension: full_visitor_id {
    type: number
    #   hidden: TRUE
    sql: ${TABLE}.full_visitor_id ;;
  }
# dimension_group: session_start {
#  type: time
  #   hidden: TRUE
#  convert_tz: no
#  timeframes: [
#   time,
#   date,
#   week,
#   month,
#   year,
#   raw
#  ]
#  sql: ${TABLE}.session_start ;;
# }


  dimension: partition_date {
    type: date_time
    sql: CAST(CONCAT(SUBSTR(${TABLE}.suffix,0,4),'-',SUBSTR(${TABLE}.suffix,5,2),'-',SUBSTR(${TABLE}.suffix,7,2)) AS TIMESTAMP) ;;
  }


  dimension_group: event_1 {
    description: "First occurrence of event 1"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.event_1 ;;
  }
  dimension_group: event_2_first {
    description: "First occurrence of event 2"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.event_2_first ;;
  }
  dimension_group: event_2_last {
    description: "Last occurrence of event 2"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.event_2_last ;;
  }
  dimension_group: event_3_first {
    description: "First occurrence of event 3"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.event_3_first ;;
  }
  dimension_group: event_3_last {
    description: "Last occurrence of event 3"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.event_3_last ;;
  }
  dimension_group: event_4_first {
    description: "First occurrence of event 4"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.event_4_first ;;
  }
  dimension_group: event_4_last {
    description: "Last occurrence of event 4"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.event_4_last ;;
  }

  dimension_group: event_5_first {
    description: "First occurrence of event 5"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.event_5_first ;;
  }
  dimension_group: event_5_last {
    description: "Last occurrence of event 5"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.event_5_last ;;
  }

  dimension_group: event_6_first {
    description: "First occurrence of event 6"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.event_6_first ;;
  }
  dimension_group: event_6_last {
    description: "Last occurrence of event 6"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.event_6_last ;;
  }

  dimension_group: event_7_first {
    description: "First occurrence of event 7"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.event_7_first ;;
  }
  dimension_group: event_7_last {
    description: "Last occurrence of event 7"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.event_7_last ;;
  }

  dimension: reached_event_1 {
    hidden:no
    type: yesno
    sql: (${event_1_time} IS NOT NULL)
      ;;
  }
  dimension: reached_event_2 {
    hidden: no
    type: yesno
    sql: (${event_1_time} IS NOT NULL AND ${event_2_first_time} IS NOT NULL AND ${event_1_time} < ${event_2_last_time})
      ;;
  }
  dimension: reached_event_3 {
    hidden: yes
    type: yesno
    sql: (${event_1_time} IS NOT NULL AND ${event_2_last_time} IS NOT NULL AND ${event_3_last_time} IS NOT NULL
         AND ${event_1_time} < ${event_2_last_time} AND ${event_1_time} < ${event_3_last_time} AND ${event_2_first_time} < ${event_3_last_time})
          ;;
  }
  dimension: reached_event_4 {
    hidden: yes
    type: yesno
    sql: (${event_1_time} IS NOT NULL AND ${event_2_last_time} IS NOT NULL AND ${event_3_last_time} IS NOT NULL AND ${event_4_last_time} IS NOT NULL
         AND ${event_1_time} < ${event_2_last_time} AND ${event_1_time} < ${event_3_last_time} AND ${event_1_time} < ${event_4_last_time} AND ${event_2_first_time} < ${event_3_last_time} AND ${event_2_first_time} < ${event_4_last_time} AND ${event_3_first_time} < ${event_4_last_time})
       ;;
  }

  dimension: reached_event_5 {
    hidden: yes
    type: yesno
    sql: (${event_1_time} IS NOT NULL AND ${event_2_last_time} IS NOT NULL AND ${event_3_last_time} IS NOT NULL AND ${event_4_last_time} IS NOT NULL AND ${event_5_last_time} IS NOT NULL
         AND ${event_1_time} < ${event_2_last_time} AND ${event_1_time} < ${event_3_last_time} AND ${event_1_time} < ${event_4_last_time} AND ${event_1_time} < ${event_5_last_time} AND ${event_2_first_time} < ${event_3_last_time} AND ${event_2_first_time} < ${event_4_last_time}  AND ${event_2_first_time} < ${event_5_last_time} AND ${event_3_first_time} < ${event_4_last_time} AND ${event_3_first_time} < ${event_5_last_time} AND ${event_4_first_time} < ${event_5_last_time})
       ;;
  }

  dimension: reached_event_6 {
    hidden: yes
    type: yesno
    sql: (${event_1_time} IS NOT NULL AND ${event_2_last_time} IS NOT NULL AND ${event_3_last_time} IS NOT NULL AND ${event_4_last_time} IS NOT NULL AND ${event_5_last_time} IS NOT NULL AND ${event_6_last_time} IS NOT NULL
         AND ${event_1_time} < ${event_2_last_time}
        AND ${event_1_time} < ${event_3_last_time}
        AND ${event_1_time} < ${event_4_last_time}
        AND ${event_1_time} < ${event_5_last_time}
        AND ${event_1_time} < ${event_6_last_time}
        AND ${event_2_first_time} < ${event_3_last_time}
        AND ${event_2_first_time} < ${event_4_last_time}
        AND ${event_2_first_time} < ${event_5_last_time}
        AND ${event_2_first_time} < ${event_6_last_time}
        AND ${event_3_first_time} < ${event_4_last_time}
        AND ${event_3_first_time} < ${event_5_last_time}
        AND ${event_3_first_time} < ${event_6_last_time}
        AND ${event_4_first_time} < ${event_5_last_time}
        AND ${event_4_first_time} < ${event_6_last_time}
        AND ${event_5_first_time} < ${event_6_last_time})
       ;;
  }

  dimension: reached_event_7 {
    hidden: yes
    type: yesno
    sql: (${event_1_time} IS NOT NULL AND ${event_2_last_time} IS NOT NULL AND ${event_3_last_time} IS NOT NULL AND ${event_4_last_time} IS NOT NULL AND ${event_5_last_time} IS NOT NULL AND ${event_6_last_time} IS NOT NULL AND ${event_7_last_time} IS NOT NULL
         AND ${event_1_time} < ${event_2_last_time}
        AND ${event_1_time} < ${event_3_last_time}
        AND ${event_1_time} < ${event_4_last_time}
        AND ${event_1_time} < ${event_5_last_time}
        AND ${event_1_time} < ${event_6_last_time}
        AND ${event_1_time} < ${event_7_last_time}
        AND ${event_2_first_time} < ${event_3_last_time}
        AND ${event_2_first_time} < ${event_4_last_time}
        AND ${event_2_first_time} < ${event_5_last_time}
        AND ${event_2_first_time} < ${event_6_last_time}
        AND ${event_2_first_time} < ${event_7_last_time}
        AND ${event_3_first_time} < ${event_4_last_time}
        AND ${event_3_first_time} < ${event_5_last_time}
        AND ${event_3_first_time} < ${event_6_last_time}
        AND ${event_3_first_time} < ${event_7_last_time}
        AND ${event_4_first_time} < ${event_5_last_time}
        AND ${event_4_first_time} < ${event_6_last_time}
        AND ${event_4_first_time} < ${event_7_last_time}
        AND ${event_5_first_time} < ${event_6_last_time}
        AND ${event_5_first_time} < ${event_7_last_time}
        AND ${event_6_first_time} < ${event_7_last_time})
       ;;
  }


  dimension: furthest_step {
    label: "Furthest Funnel Step Reached"
    case: {


      when: {
        sql: ${reached_event_7} = true ;;
        label: "7th"
      }
      when: {
        sql: ${reached_event_6} = true ;;
        label: "6th"
      }
      when: {
        sql: ${reached_event_5} = true ;;
        label: "5th"
      }
      when: {
        sql: ${reached_event_4} = true ;;
        label: "4th"
      }
      when: {
        sql: ${reached_event_3} = true;;
        label: "3rd"
      }
      when: {
        sql: ${reached_event_2} = true  ;;
        label: "2nd"
      }
      when: {
        sql: ${reached_event_1} = true  ;;
        label: "1st"
      }
      else: "no"
    }
  }
  measure: count_sessions {
    type: count_distinct
    drill_fields: [detail*]
    sql: ${id} ;;
  }
  measure: count_sessions_event1 {
    label: "CBS-Global"
    type: count_distinct
    sql: ${full_visitor_id} ;;
    drill_fields: [detail*]
    filters: {
      field: furthest_step
      value: "1st,2nd,3rd,4th, 5th, 6th, 7th"
    }
  }
  measure: count_sessions_event12 {
    label: "CBS Country Pricing Page"
    description: "Only includes sessions which also completed event 1"
    type: count_distinct
    sql: ${full_visitor_id} ;;
    drill_fields: [detail*]
    filters: {
      field: furthest_step
      value: "2nd,3rd,4th,5th, 6th, 7th"
    }
  }
  measure: count_sessions_event123 {
    label: "CBS - Plan"
    description: "Only includes sessions which also completed events 1 and 2"
    type: count_distinct
    sql: ${full_visitor_id} ;;
    drill_fields: [detail*]
    filters: {
      field: furthest_step
      value: "3rd, 4th, 5th, 6th, 7th"
    }
  }
  measure: count_sessions_event1234 {
    label: "CBS - Registration"
    description: "Only includes sessions which also completed events 1, 2 and 3"
    type: count_distinct
    sql: ${full_visitor_id} ;;
    drill_fields: [detail*]
    filters: {
      field: furthest_step
      value: "4th, 5th, 6th, 7th"
    }
  }
  measure: count_sessions_event12345 {
    label: "CBS - Payment"
    description: "Only includes sessions which also completed events 1, 2, 3 and 4"
    type: count_distinct
    sql: ${full_visitor_id} ;;
    drill_fields: [detail*]
    filters: {
      field: furthest_step
      value: "5th, 6th, 7th"
    }
  }

  measure: count_sessions_event123456 {
    label: "CBS - Review"
    description: "Only includes sessions which also completed events 1, 2, 3 and 4"
    type: count_distinct
    sql: ${full_visitor_id} ;;
    drill_fields: [detail*]
    filters: {
      field: furthest_step
      value: "6th, 7th"
    }
  }

  measure: count_sessions_event1234567 {
    label: "CBS - Confirmation"
    description: "Only includes sessions which also completed events 1, 2, 3 and 4"
    type: count_distinct
    sql: ${full_visitor_id} ;;
    drill_fields: [detail*]
    filters: {
      field: furthest_step
      value: "7th"
    }
  }


  set: detail {
    fields: [id, full_visitor_id]
  }
  parameter: value_1 {
    type: number
  }
  parameter: value_2 {
    type: number
  }
  dimension: tier {
    type: string
    sql: CASE WHEN value < value_1 THEN 'Lowest Tier'
      WHEN value > value_1 AND value < ${value_2} THEN 'Medium Tier' ;;
  }
  }


#explore: funnel_growth_dashboard {
#hidden: no
#}

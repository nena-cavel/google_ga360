view: media_posting_funnel {
  derived_table: {
    sql:SELECT CONCAT(CAST(sessions.fullVisitorId AS STRING), '|' , COALESCE(CAST(sessions.date AS STRING),'')) as id
          , sessions.fullVisitorId as full_visitor_id
          , sessions.suffix as suffix
          , MIN (
             CASE WHEN REGEXP_CONTAINS(hits_events.eventAction, '^connect_share_with_us$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
                ) AS share_with_1
          , MIN (
            CASE WHEN
              REGEXP_CONTAINS(hits_events.eventAction, '^connect_post_add_video_photo$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS add_videophoto_2_first
          , Max (
            CASE WHEN
              REGEXP_CONTAINS(hits_events.eventAction, '^connect_post_add_video_photo$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS add_videophoto_2_last
          , MIN (
            CASE WHEN
            REGEXP_CONTAINS(hits_events.eventAction, '^connect_gallery_continue$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS confirm_selection_3_first
          , Max (
            CASE WHEN
            REGEXP_CONTAINS(hits_events.eventAction, '^connect_gallery_continue$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS confirm_selection_3_last
            , MIN (
            CASE WHEN
            REGEXP_CONTAINS(hits_screens.screenname, '^connect_post_theme_done$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS done_editing_4_first
          , Max (
            CASE WHEN
            REGEXP_CONTAINS(hits_screens.screenname, '^connect_post_theme_done$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS done_editing_4_last
          , min (
            CASE WHEN
             REGEXP_CONTAINS(hits_events.eventAction, '^connect_post$')
            THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS post_video_5
         FROM ${ga_sessions.SQL_TABLE_NAME} AS sessions
          LEFT JOIN UNNEST(sessions.hits) as hits
          LEFT JOIN UNNEST([hits.eventInfo]) as hits_events
          LEFT JOIN UNNEST([hits.appInfo]) as hits_screens
        WHERE {% condition event_time %} TIMESTAMP_SECONDS(sessions.visitStarttime) {% endcondition %}
         GROUP BY 1,2,3;;
  }

  filter: event_time {
    type: date_time
  }


  dimension: funnel_date {
    type: date_time
    sql: CAST(CONCAT(SUBSTR(${TABLE}.suffix,0,4),'-',SUBSTR(${TABLE}.suffix,5,2),'-',SUBSTR(${TABLE}.suffix,7,2)) AS TIMESTAMP) ;;
  }

  dimension: id {
    type: string
    primary_key: yes
    #   hidden: TRUE
    sql: ${TABLE}.id ;;
  }

  dimension: totals {
    type: string
    sql: ${TABLE}.totals ;;
  }

  dimension_group: share_with_1 {
    description: "enter posting funnel"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.share_with_1 ;;
  }

  dimension_group: add_videophoto_2_first {
    description: "select video or photo"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.add_videophoto_2_first ;;
  }

  dimension_group: add_videophoto_2_last {
    description: "select video or photo"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.add_videophoto_2_last ;;
  }

  dimension_group: confirm_selection_3_first {
    description: "select a video"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.confirm_selection_3_first ;;
  }

  dimension_group: confirm_selection_3_last {
    description: "select a video"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.confirm_selection_3_last ;;
  }


  dimension_group: done_editing_4_first {
    description: "confirm media selection"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.done_editing_4_first ;;
  }

  dimension_group: done_editing_4_last {
    description: "confirm media selection"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.done_editing_4_last ;;
  }

  dimension_group: post_step5 {
    description: "confirm media selection"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.post_video_5 ;;
  }

  #### step 1 ####

  dimension: reached_event_1 {
    hidden: no
    type: yesno
    sql: (${share_with_1_time} IS NOT NULL);;
  }

  dimension: reached_event_2 {
    hidden: no
    type: yesno
    sql: (${share_with_1_time} IS NOT NULL AND ${add_videophoto_2_first_time} IS NOT NULL AND ${share_with_1_time}  < ${add_videophoto_2_last_time})
      ;;
  }

  dimension: reached_event_3 {
    hidden: no
    type: yesno
    sql: (${share_with_1_time} IS NOT NULL AND ${add_videophoto_2_last_time} IS NOT NULL AND ${confirm_selection_3_last_time} IS NOT NULL
         AND ${share_with_1_time} < ${add_videophoto_2_last_time} AND ${share_with_1_time} < ${confirm_selection_3_last_time} AND ${add_videophoto_2_first_time} < ${confirm_selection_3_last_time})
          ;;
  }

  dimension: reached_event_4 {
    hidden: no
    type: yesno
    sql: (${share_with_1_time} IS NOT NULL AND ${add_videophoto_2_last_time} IS NOT NULL AND ${confirm_selection_3_last_time} IS NOT NULL and ${done_editing_4_last_time} is not null
         AND  ${confirm_selection_3_first_time} < ${done_editing_4_last_time})
          ;;
  }

  dimension: reached_event_5 {
    hidden: no
    type: yesno
    sql: (${share_with_1_time} is not null and ${add_videophoto_2_last_time} is not null and ${confirm_selection_3_last_time} is not null and ${done_editing_4_last_time} is not null and ${post_step5_time} is not null
          and ${done_editing_4_first_time} < ${post_step5_time}) ;;
  }



### Step 3 ###

  measure: count_sessions {
    type: count_distinct
    #drill_fields: [detail*]
    sql: ${id} ;;
  }
  measure: count_sessions_event1 {
    label: "enter posting funnel"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: furthest_step
      value:  "1st,2nd,3rd,4th, 5th"
   # drill_fields: [detail*]
    }
  }
  measure: count_sessions_event12 {
    label: "select video or photo"
    description: "Only includes sessions which also completed event 1"
    type: count_distinct
    sql: ${id} ;;
      filters: {
        field: furthest_step
        value:  "2nd, 3rd, 4th, 5th"
      }
  }

  measure: count_sessions_event123 {
    label: "confirm selection"
    description: "Only includes sessions which also completed event 1 & 2 & 3"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: furthest_step
      value:  "3rd, 4th, 5th"
    }
  }

  measure: count_sessions_event1234 {
    label: "done editing"
    description: "Only includes sessions which also completed event 1 & 2 &3 "
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: furthest_step
      value: "4th, 5th"
    }
  }

  measure: count_sessions_event12345 {
    label: "post"
    description: "Only includes sessions which also completed event 1 & 2 &3 &4"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: furthest_step
      value: "5th"
    }
  }



### Step 2 ####

  dimension: furthest_step {
    label: "Furthest Funnel Step Reached"
    case: {
      when: {
        sql: ${reached_event_5} = true ;;
        label: "5th"
      }

      when: {
        sql: ${reached_event_4} = true ;;
        label: "4th"
      }
      when: {
        sql: ${reached_event_3} = true ;;
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

  }

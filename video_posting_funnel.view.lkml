view: video_posting_funnel {
  derived_table: {
    sql:SELECT CONCAT(CAST(sessions.fullVisitorId AS STRING), '|' , COALESCE(CAST(sessions.date AS STRING),'')) as id
          , sessions.fullVisitorId as full_visitor_id
          , sessions.suffix as suffix
          , Min (
            CASE WHEN
            REGEXP_CONTAINS(hits_events.eventAction, '^connect_gallery_video_length$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS choose_video_1
            , Max (
            CASE WHEN
            REGEXP_CONTAINS(hits_events.eventAction, '^connect_gallery_video_length$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS choose_video_1_last
            , Min (
            CASE WHEN
            REGEXP_CONTAINS(hits_events.eventAction, '^connect_gallery_continue$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS video_confirm_2_first
          , Max (
            CASE WHEN
            REGEXP_CONTAINS(hits_events.eventAction, '^connect_gallery_continue$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS video_confirm_2_last
              , Max (
            CASE WHEN
            REGEXP_CONTAINS(hits_screens.screenname, '^connect_post_theme_done$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS last_chose_photo
          , min (
            CASE WHEN
             REGEXP_CONTAINS(hits_events.eventAction, '^connect_post$')
            THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS post_video_3
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

  dimension_group: funnel_date_group {
    timeframes: [date,raw,week,week_of_year,month,month_name]
    datatype: datetime  # was date, but support changed it to datetime
    type: time
    convert_tz: no
    sql:  CAST(CONCAT(SUBSTR(${TABLE}.suffix,0,4),'-',SUBSTR(${TABLE}.suffix,5,2),'-',SUBSTR(${TABLE}.suffix,7,2)) AS TIMESTAMP) ;;
  }

  dimension_group: choose_video_1 {
    description: "choose a video"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.choose_video_1 ;;
  }

  dimension_group: video_confirm_2_first {
    description: "select video or photo"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.video_confirm_2_first ;;
  }

  dimension_group: video_confirm_2_last {
    description: "select video or photo"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.video_confirm_2_last ;;
  }

  dimension_group: last_chose_photo {
    description: "select video or photo"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.last_chose_photo ;;
  }


  dimension_group: post_video_3 {
    description: "confirm media selection"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.post_video_3 ;;
  }

  #### step 1 ####

  dimension: reached_event_1 {
    hidden: no
    type: yesno
    sql: (${choose_video_1_time} IS NOT NULL);;
  }

  dimension: reached_event_2 {
    hidden: no
    type: yesno
    sql: (${choose_video_1_time} IS NOT NULL AND ${video_confirm_2_last_time} IS NOT NULL AND ${choose_video_1_time}  < ${video_confirm_2_last_time}
       and  ${video_confirm_2_last_time} > ${last_chose_photo_time})
      ;;
  }

  dimension: reached_event_3 {
    hidden: no
    type: yesno
    sql: (${choose_video_1_time} IS NOT NULL AND ${video_confirm_2_last_time} IS NOT NULL AND ${post_video_3_time} IS NOT NULL
         AND ${choose_video_1_time} < ${video_confirm_2_last_time} AND ${choose_video_1_time} < ${post_video_3_time} AND ${video_confirm_2_first_time} < ${post_video_3_time})
          ;;
  }



### Step 3 ###

  measure: count_sessions {
    type: count_distinct
    #drill_fields: [detail*]
    sql: ${id} ;;
  }
  measure: count_sessions_event1 {
    label: "select a video"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: furthest_step
      value:  "1st,2nd,3rd"
   # drill_fields: [detail*]
    }
  }
  measure: count_sessions_event12 {
    label: "confirm video"
    description: "Only includes sessions which also completed event 1"
    type: count_distinct
    sql: ${id} ;;
      filters: {
        field: furthest_step
        value:  "2nd, 3rd"
      }
  }

  measure: count_sessions_event123 {
    label: "post video"
    description: "Only includes sessions which also completed event 1 & 2 & 3"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: furthest_step
      value:  "3rd"
    }
  }




### Step 2 ####

  dimension: furthest_step {
    label: "Furthest Funnel Step Reached"
    case: {

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

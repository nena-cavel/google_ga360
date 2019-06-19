view: groups_funnel {
  derived_table: {
    sql:SELECT CONCAT(CAST(sessions.fullVisitorId AS STRING), '|' , COALESCE(CAST(sessions.date AS STRING),'')) as id
          , sessions.fullVisitorId as full_visitor_id
          , sessions.suffix as suffix
          , MIN (
            CASE WHEN
              REGEXP_CONTAINS(hits_events.eventAction, '^connect_groups_find_group$|^connect_groups_find_first_group$|^connect_groups_popup_findgroup$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS browse_groups_1
          , MIN (
            CASE WHEN
            REGEXP_CONTAINS(hits_events.eventAction, '^connect_groups_see_all_|^connect_groups_see_alldas_bin_ich|connect_groups_see_allmein_weg|connect_groups_see_allessen|connect_groups_see_allumdenken|connect_groups_find_group|connect_groups_find_|connect_groups_see_all')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS see_all_2_first
            , Max (
            CASE WHEN
            REGEXP_CONTAINS(hits_events.eventAction, '^connect_groups_see_all_|^connect_groups_see_alldas_bin_ich|connect_groups_see_allmein_weg|connect_groups_see_allessen|connect_groups_see_allumdenken|connect_groups_find_group|connect_groups_find_|connect_groups_see_all')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS see_all_2_last
          , MIN (
            CASE WHEN
            REGEXP_CONTAINS(hits_events.eventAction, '^connect_groups_type_see_group$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS view_group_3_first
          , Max (
            CASE WHEN
            REGEXP_CONTAINS(hits_events.eventAction, '^connect_groups_type_see_group')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS view_group_3_last

            , MIN (
            CASE WHEN
            REGEXP_CONTAINS(hits_events.eventAction, '^connect_groups_join_public_group$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS join_group_4

         FROM ${ga_sessions.SQL_TABLE_NAME} AS sessions
          LEFT JOIN UNNEST(sessions.hits) as hits
          LEFT JOIN UNNEST([hits.eventInfo]) as hits_events
        WHERE {% condition event_time %} TIMESTAMP_SECONDS(sessions.visitStarttime) {% endcondition %}
         GROUP BY 1,2,3;;
  }

  filter: event_time {
    type: date_time
  }

  dimension_group: funnel_date_group {
    timeframes: [date,raw,week,week_of_year,month,month_name]
    datatype: datetime  # was date, but support changed it to datetime
    type: time
    convert_tz: no
    sql:  CAST(CONCAT(SUBSTR(${TABLE}.suffix,0,4),'-',SUBSTR(${TABLE}.suffix,5,2),'-',SUBSTR(${TABLE}.suffix,7,2)) AS TIMESTAMP) ;;
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

  dimension_group: browse_groups_1 {
    description: "browse groups"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.browse_groups_1 ;;
  }

  dimension_group:  see_all_2_first {
    description: "see all category"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.see_all_2_first ;;
  }

  dimension_group:  see_all_2_last{
    description: "see all category"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.see_all_2_last ;;
  }

  dimension_group: view_group_3_first {
    description: "view a group"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.view_group_3_first ;;
  }

  dimension_group: view_group_3_last {
    description: "view a group"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.view_group_3_last ;;
  }

  dimension_group: join_group_4 {
    description: "join a group"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.join_group_4 ;;
  }



  #### step 1 ####

  dimension: reached_event_1 {
    hidden: no
    type: yesno
    sql: (${browse_groups_1_time} IS NOT NULL);;
  }

  dimension: reached_event_2 {
    hidden: no
    type: yesno
    sql: (${browse_groups_1_time} IS NOT NULL AND ${see_all_2_last_time} is not null AND ${browse_groups_1_time}  < ${see_all_2_last_time})
      ;;
  }

  dimension: reached_event_23 {
    hidden: no
    type: yesno
    sql: (${browse_groups_1_time} IS NOT NULL AND ${see_all_2_last_time} IS NOT NULL AND ${view_group_3_last_time} IS NOT NULL
         AND ${browse_groups_1_time} < ${see_all_2_last_time} AND ${see_all_2_first_time} < ${view_group_3_last_time})
          ;;
  }


  dimension: reached_event_234 {
    hidden: no
    type: yesno
    sql: (${browse_groups_1_time} IS NOT NULL AND ${see_all_2_first_time} IS NOT NULL AND ${view_group_3_last_time} IS NOT NULL and ${join_group_4_time} is not null
         AND ${view_group_3_first_time} < ${join_group_4_time})
          ;;
  }

  dimension: reached_event_13 {
    hidden: no
    type: yesno
    sql: (${browse_groups_1_time} IS NOT NULL  AND ${view_group_3_last_time} IS NOT NULL
         AND ${browse_groups_1_time} <  ${view_group_3_last_time})
          ;;
  }

  dimension: reached_event_134 {
    hidden: no
    type: yesno
    sql: (${browse_groups_1_time} IS NOT NULL AND ${view_group_3_last_time} IS NOT NULL and ${join_group_4_time} is not null
         AND ${view_group_3_first_time} < ${join_group_4_time})
          ;;
  }


### Step 3 ###

  measure: count_sessions {
    type: count_distinct
    #drill_fields: [detail*]
    sql: ${id} ;;
  }
  measure: count_sessions_event1 {
    label: "browse groups"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: furthest_step
      value:  "1st, 2nd, 2-3, 2-3-4, 1-3, 1-3-4"
      # drill_fields: [detail*]
    }
  }

  measure: total_sessions_event1 {
    label: "total browse groups"
    type: count
    filters: {
      field: furthest_step
      value:  "1st, 2nd, 2-3, 2-3-4, 1-3, 1-3-4"
      # drill_fields: [detail*]
    }
  }

  measure: count_sessions_event12 {
    label: "see all groups"
    description: "Only includes sessions which also completed event 1"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: furthest_step
      value:  " 2nd, 2-3, 2-3-4"
    }
  }

  measure: count_sessions_event123 {
    label: "see all groups to view group"
    description: "Only includes sessions which also completed event 1 & 2 & 3"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: furthest_step
      value:  "2-3, 2-3-4"
    }
  }
  measure: count_sessions_event13 {
    label: "browse to view a group"
    description: "Only includes sessions which also completed event 1 & 3"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: furthest_step
      value:  "1-3, 1-3-4"
    }
  }

  measure: count_sessions_event134 {
    label: "browse > view > join"
    description: "Only includes sessions which also completed event 1 & 3"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: furthest_step
      value:  "1-3-4"
    }
  }


  measure: count_sessions_event1234 {
    label: "see all > join"
    description: "Only includes sessions which also completed event 1 & 2 &3 "
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: furthest_step
      value: "2-3-4"
    }
  }




### Step 2 ####

  dimension: furthest_step {
    label: "Furthest Funnel Step Reached"
    case: {
      when: {
        sql: ${reached_event_234} = true ;;
        label: "2-3-4"
      }
      when: {
        sql: ${reached_event_23} = true ;;
        label: "2-3"
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
#########################
#########################

view: groups_carousel_funnel {
  derived_table: {
    sql:SELECT CONCAT(CAST(sessions.fullVisitorId AS STRING), '|' , COALESCE(CAST(sessions.date AS STRING),'')) as id
          , sessions.fullVisitorId as full_visitor_id
          , sessions.suffix as suffix
          , MIN (
            CASE WHEN
              REGEXP_CONTAINS(hits_events.eventAction, '^connect_groups_find_group$|^connect_groups_find_first_group$|^connect_groups_popup_findgroup$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS browse_groups_1
          , MIN (
            CASE WHEN
            REGEXP_CONTAINS(hits_events.eventAction, 'connect_groups_see_food_|connect_groups_see_journey_|connect_groups_see_identity_|connect_groups_see_journey_|connect_groups_see_mindset_|connect_groups_see_activity_|connect_groups_see_Food_|connect_groups_see_hobbies_|connect_groups_see_Hobbies_|connect_groups_see_hobbies_|connect_groups_see_Journey_|connect_groups_see_Mein_Weg_|connect_groups_see_Mon_parcours_|connect_groups_see_Essen_|connect_groups_see_Umdenken_|connect_groups_see_Das_bin_ich_|connect_groups_see_Activité_|connect_groups_see_Cuisine_|connect_groups_see_locations_|connect_groups_see_État_d_esprit_|connect_groups_see_Bewegen_|connect_groups_see_Profil_|connect_groups_see_Eten_|connect_groups_see_Aktivitet_|connect_groups_see_Alimentação_|connect_groups_see_Resa_|connect_groups_see_Beweging_|connect_groups_see_Dit_ben_ik__|connect_groups_see_Mat_|connect_groups_see_Mijn_WW_|connect_groups_see_Feel_good_')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS view_group_2_first
          , Max (
            CASE WHEN
            REGEXP_CONTAINS(hits_events.eventAction, 'connect_groups_see_food_|connect_groups_see_journey_|connect_groups_see_identity_|connect_groups_see_journey_|connect_groups_see_mindset_|connect_groups_see_activity_|connect_groups_see_Food_|connect_groups_see_hobbies_|connect_groups_see_Hobbies_|connect_groups_see_hobbies_|connect_groups_see_Journey_|connect_groups_see_Mein_Weg_|connect_groups_see_Mon_parcours_|connect_groups_see_Essen_|connect_groups_see_Umdenken_|connect_groups_see_Das_bin_ich_|connect_groups_see_Activité_|connect_groups_see_Cuisine_|connect_groups_see_locations_|connect_groups_see_État_d_esprit_|connect_groups_see_Bewegen_|connect_groups_see_Profil_|connect_groups_see_Eten_|connect_groups_see_Aktivitet_|connect_groups_see_Alimentação_|connect_groups_see_Resa_|connect_groups_see_Beweging_|connect_groups_see_Dit_ben_ik__|connect_groups_see_Mat_|connect_groups_see_Mijn_WW_|connect_groups_see_Feel_good_')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS view_group_2_last

            , MIN (
            CASE WHEN
            REGEXP_CONTAINS(hits_events.eventAction, '^connect_groups_join_public_group$')
             THEN TIMESTAMP_MILLIS(UNIX_MILLIS(TIMESTAMP_SECONDS(sessions.visitStarttime)) + hits.time)
             ELSE NULL END
            ) AS join_group_3

         FROM ${ga_sessions.SQL_TABLE_NAME} AS sessions
          LEFT JOIN UNNEST(sessions.hits) as hits
          LEFT JOIN UNNEST([hits.eventInfo]) as hits_events
        WHERE {% condition event_time %} TIMESTAMP_SECONDS(sessions.visitStarttime) {% endcondition %}
         GROUP BY 1,2,3;;
  }

  filter: event_time {
    type: date_time
  }

  dimension_group: funnel_date_group {
    timeframes: [date,raw,week,week_of_year,month,month_name]
    datatype: datetime  # was date, but support changed it to datetime
    type: time
    convert_tz: no
    sql:  CAST(CONCAT(SUBSTR(${TABLE}.suffix,0,4),'-',SUBSTR(${TABLE}.suffix,5,2),'-',SUBSTR(${TABLE}.suffix,7,2)) AS TIMESTAMP) ;;
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

  dimension_group: browse_groups_1 {
    description: "browse groups"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.browse_groups_1 ;;
  }

  dimension_group:  view_group_2_first {
    description: "see all category"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.view_group_2_first ;;
  }

  dimension_group:  view_group_2_last {
    description: "see all category"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.view_group_2_last ;;
  }

  dimension_group: join_group_3 {
    description: "view a group"
    type: time
    convert_tz: no
    timeframes: [time]
    hidden: yes
    sql: ${TABLE}.join_group_3 ;;
  }



  #### step 1 ####

  dimension: reached_event_1 {
    hidden: no
    type: yesno
    sql: (${browse_groups_1_time} IS NOT NULL);;
  }

  dimension: reached_event_2 {
    hidden: no
    type: yesno
    sql: (${browse_groups_1_time} IS NOT NULL AND ${view_group_2_last_time} is not null AND ${browse_groups_1_time}  < ${view_group_2_last_time})
      ;;
  }

  dimension: reached_event_3 {
    hidden: no
    type: yesno
    sql: (${browse_groups_1_time} IS NOT NULL AND ${view_group_2_last_time} IS NOT NULL AND ${join_group_3_time} IS NOT NULL
         AND ${browse_groups_1_time} < ${view_group_2_last_time} AND ${view_group_2_first_time} < ${join_group_3_time} )
          ;;
  }



### Step 3 ###

  measure: count_sessions {
    type: count_distinct
    #drill_fields: [detail*]
    sql: ${id} ;;
  }
  measure: count_sessions_event1 {
    label: "browse groups"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: furthest_step
      value:  "1st, 2nd, 3rd"
      # drill_fields: [detail*]
    }
  }


  measure: count_sessions_event12 {
    label: "view group"
    description: "Only includes sessions which also completed event 1"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: furthest_step
      value:  " 2nd, 3rd"
    }
  }

  measure: count_sessions_event123 {
    label: "join group"
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
        sql: ${reached_event_3} = true  ;;
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

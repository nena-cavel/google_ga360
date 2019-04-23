include: "ga_block.view.lkml"

datagroup: monthly_cache {
  sql_trigger: select EXTRACT(month FROM CURRENT_DATE('America/New_York')) ;;
}

explore: ga_sessions_block {
  extends: [ga_sessions_base]
  extension: required

  always_filter: {
    filters: {
      field: ga_sessions.partition_date
      value: "7 days ago for 7 days"
      ## Partition Date should always be set to a recent date to avoid runaway queries
    }
  }
}

view: ga_sessions {
  extends: [ga_sessions_base]
  measure:  unique_prospects{
    filters: {
      field: Prospect
      value: "yes"
    }
    type: count_distinct
    sql: ${fullVisitorId} ;;
  }
  measure:  unique_funnel_prospects{
    filters: {
      field: Prospect
      value: "yes"
    }
    filters: {
      field: funnelProspect
      value: "yes"
    }
    type: count_distinct
    sql: ${fullVisitorId} ;;
  }
  measure: sus1_visitors {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_contentGroup.is_sus1
      value: "yes"
    }
  }
  measure: homepage_visitors {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_contentGroup.is_homepage
      value: "yes"
    }
  }
#### Step 2: Nena's template for filtered measures
  measure: connect_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.connect_users_dimension
      value: "yes"
    }
  }

  measure: connect_visits {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId}) ;;
    filters: {
      field: hits_appInfo.connect_users_dimension
      value: "yes"
    }
  }

measure:  profile_follows {
  type: count_distinct
  sql: concat(cast(${visitId} as string),${fullVisitorId});;
  filters: {
    field: hits_eventInfo.profile_followers
    value: "yes"
    }
  }

  #dimension: product_owned_group {
 #   type: string
  #  sql: case when  (case when customDimensions.index=10 then customDimensions.value end) = "[ONLINE]"
  #            then "Digital"
   #           WHEN (case when customDimensions.index=10 then customDimensions.value end) = "[MONTHLY_PASS, ETOOLS]"
   #           THEN "Studio"
   #           WHEN (case when customDimensions.index=10 then customDimensions.value end) = "[ETOOLS, MONTHLY_PASS]"
   #           THEN "Studio"
   #           ELSE null
   #           end;;
 # }

  measure: profile_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.profile_user
      value: "yes"
    }
  }

  measure: connect_new_tab_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.connect_new_tab
      value: "yes"
    }
  }

  measure: connect_follow_tab_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.connect_follow_tab
      value: "yes"
    }
  }

  measure: connect_profile_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.connect_profile_views
      value: "yes"
    }
  }

  measure: notifications_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.notifications_page
      value: "yes"
    }
  }

  measure: journey_tab_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.journey_tab
      value: "yes"
    }
  }

  measure: weigh_tracking_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.weight_tracking
      value: "yes"
    }
  }


  measure: connect_profile_views {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId});;
    filters: {
      field: hits_appInfo.connect_profile_views
      value: "yes"
    }
  }

  measure: groups_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.groups_users
      value: "yes"
    }
  }

  measure: connect_likers {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.connect_likers
      value: "yes"
    }
  }


  measure: connect_commenters {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
        field: hits_eventInfo.connect_commenters
        value: "yes"
    }
  }

  measure: notifs_new_follower_clicks {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId}) ;;
    filters: {
      field: hits_eventInfo.notifs_new_follower
      value: "yes"
    }
  }

  measure: notifs_new_comment_clicks {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId}) ;;
    filters: {
      field: hits_eventInfo.notifs_new_comment
      value: "yes"
    }
  }

  measure: notifs_new_like_clicks {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId}) ;;
    filters: {
      field: hits_eventInfo.notifs_new_like
      value: "yes"
    }
  }

  measure: all_notifs_clicks {
    type: count_distinct
    sql:concat(cast(${visitId} as string),${fullVisitorId})  ;;
    filters: {
      field: hits_eventInfo.all_notifs
      value: "yes"
    }
  }

  measure: coach_tab_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.coach_tab
      value: "yes"
    }
  }

measure: get_help_users {
  type: count_distinct
  sql: ${fullVisitorId} ;;
  filters: {
    field: hits_appInfo.get_help
    value: "yes"
  }
}

measure: chat_now_users {
  type: count_distinct
  sql: ${fullVisitorId} ;;
  filters: {
    field: hits_appInfo.chat_now
    value: "yes"
  }
}

  measure: plus_symbol_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.plus_symbol
      value: "yes"
    }
  }

  measure: search_bar_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.search_bar
      value: "yes"
    }
  }

  measure: barcode_scans {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.barcode_scans
      value: "yes"
    }
  }

  measure: connect_posters {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
        field: hits_eventInfo.connect_posters
        value: "yes"
    }
  }

  measure: homepage_prospect_visitors {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_contentGroup.is_homepage
      value: "yes"
    }
    filters: {
      field: Prospect
      value: "yes"
    }
  }
## measures for iaf_ desktop
  measure: my_day_users_desktop {
    type:  count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field:  hits_contentGroup.is_myDay
      value: "yes"
    }
  }

  measure: iaf_page_desktop_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field:  hits_contentGroup.is_iafDesktop
      value: "yes"
    }
  }

  measure: iaf_myDay_users_desktop {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field:  hits_eventInfo.iaf_myDay_desktop
      value: "yes"
    }
  }

  measure: iaf_sendEmail_desktop {
    type: count_distinct
    sql: ${fullVisitorId};;
    filters: {
      field:  hits_eventInfo.iaf_sendEmail_desktop
      value: "yes"
    }
    }


  measure: iaf_copyLink_desktop {
    type: count_distinct
    sql: ${fullVisitorId};;
    filters: {
      field:  hits_eventInfo.iaf_copyLink_desktop
      value: "yes"
    }
  }

  measure: desktop_invites {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field:  hits_eventInfo.invite_desktop
      value: "yes"
    }
  }


dimension: uuid_dimension {
  type: string
  sql: (SELECT value FROM UNNEST(${TABLE}.customDimensions) WHERE index=12) ;;
}

measure: unique_visitors_uuid {
  type: count_distinct
  sql: ${uuid_dimension} ;;
}




  ##measures for iaf derived table
  measure: invite_friend_button {
    type: count_distinct
    sql:  ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.invite_friend
      value: "yes"
    }
  }

  measure: iaf_profile_button {
    type: count_distinct
    sql:  ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.iaf_profile
      value: "yes"
    }
  }

  measure: iaf_my_day_button {
    type: count_distinct
    sql:  ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.iaf_my_day
      value: "yes"
    }
  }

  measure: my_day_users {
    type: count_distinct
    sql:  ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.my_day
      value: "yes"
    }
  }



  measure: iaf_screen_users {
    type: count_distinct
    sql:  ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.iaf_screen
      value: "yes"
    }
  }
  # The SQL_TABLE_NAME must be replaced here for date partitioned queries to work properly. There are several
  # variations of sql_table_name patterns depending on the number of Properties (i.e. websites) being used.


  # SCENARIO 1: Only one property
  sql_table_name: (SELECT * FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions` WHERE SUBSTR(suffix,0,1) != 'i') ;;


  # SCENARIO 2: Multiple properties. The property will dynamically look at the selected dataset using a filter.
  # sql_table_name: {% assign prop = ga_sessions.website_selector._sql %}
  #                 {% if prop contains 'Website1' %} `project.dataset.ga_sessions_*`
  #                 {% elsif prop contains 'Website2' %} `project.dataset.ga_sessions_*`
  #                 {% elsif prop contains 'Website3' %} `project.dataset.ga_sessions_*`
  #                 {% endif %}
  #                 ;;
  #   filter: website_picker {
  #     suggestions: ["Website1","Website2", "Website3"]
  #   }
  #   dimension: website_selector {
  #     type: string
  #     hidden: no
  #     sql: {% parameter website_picker %} ;;
  #   }


  # SCENARIO 3: Multiple properties. The property will dynamically look at the selected dataset. If using this pattern, change the partition_date definition in the ga_block file  to type: date_time (no sql clause)
  # sql_table_name: (SELECT *,'Property1' AS Property FROM `dataset_number.ga_sessions_*` WHERE {% condition partition_date %} TIMESTAMP(PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'^\d\d\d\d\d\d\d\d'))) {% endcondition %}
  #  UNION ALL SELECT *,'Property2' AS Property FROM `dataset_number2.ga_sessions_*` WHERE {% condition partition_date %} TIMESTAMP(PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'^\d\d\d\d\d\d\d\d'))) {% endcondition %});;

  #   dimension: property {
  #     sql: CASE WHEN ${TABLE}.property = 'Property1' THEN 'Name'
  #         WHEN ${TABLE}.property = 'Property2' THEN 'Name2'
  #         ELSE NULL END
  #       ;;
  #  }





  # If you have custom dimensions on sessions, declare them here.

  # dimension: custom_dimension_2 {
  #   sql: (SELECT value FROM UNNEST(${TABLE}.customdimensions) WHERE index=2) ;;
  # }


  # dimension: custom_dimension_2 {
  #   sql: (SELECT value FROM UNNEST(${TABLE}.customdimensions) WHERE index=2) ;;
  # }

#   dimension: custom_dimension_3 {
#     sql: (SELECT value FROM UNNEST(${TABLE}.customdimensions) WHERE index=3) ;;
#   }
}

view: geoNetwork {
  extends: [geoNetwork_base]
}

view: totals {
  extends: [totals_base]
}

view: trafficSource {
  extends: [trafficSource_base]
}

view: device {
  extends: [device_base]
  dimension: is_google_analytics {
    label: "Is Google Analytics"
    type: yesno
    sql: ${browser} = 'GoogleAnalytics' ;;
  }
}

view: hits {
  extends: [hits_base]
}

view: hits_page {
  extends: [hits_page_base]
  dimension: is_weightwatchers {
    label: "Is weightwatchers.com"
    type: yesno
    sql: ${pagePath} = 'weightwatchers.com/' ;;
  }
}

# -- Ecommerce Fields

view: hits_transaction {
  #extends: [hits_transaction_base]  # Comment out to remove fields
}

view: hits_latency {
  extends: [hits_latency_base]
}
view: hits_item {
  extends: [hits_item_base]
}

# -- Advertising Fields

view: adwordsClickInfo {
  #extends: [adwordsClickInfo_base]
}

view: hits_publisher {
  #extends: [hits_publisher_base]   # Comment out this line to remove fields
}

view: hits_contentGroup {
  extends: [hits_contentGroup_base]
  dimension: is_sus1 {
    label: "Is SUS1"
    type: yesno
    sql: ${contentGroup3} like 'sign:__:plan';;
  }

  dimension: is_homepage {
    label: "Is Homepage"
    type: yesno
    sql: ${contentGroup3} like 'visi:__:home';;
  }

  dimension: is_myDay {
    label: " Is My Day"
    type: yesno
    sql: regexp_Contains(${contentGroup3},'^trac:..:nui:my-day:food$') ;;
  }

  dimension: is_iafDesktop {
    label: " Is My Day"
    type: yesno
    sql: regexp_Contains(${contentGroup3},'^trac:..:nui:invite-a-friend$') ;;
  }
}
#  We only want some of the interaction fields.

view: hits_social {
  extends: [hits_social_base]

  dimension: socialInteractionNetwork {hidden: yes}

  dimension: socialInteractionAction {hidden: yes}

  dimension: socialInteractions {hidden: yes}

  dimension: socialInteractionTarget {hidden: yes}

  #dimension: socialNetwork {hidden: yes}

  dimension: uniqueSocialInteractions {hidden: yes}

  #dimension: hasSocialSourceReferral {hidden: yes}

  dimension: socialInteractionNetworkAction {hidden: yes}
}


view: hits_appInfo {
  extends: [hits_appInfo_base]
  dimension: my_day {
    sql: ${screenName} = 'food_dashboard' ;;
    type: yesno
  }

  dimension: iaf_screen {
    sql: ${screenName} = 'Invite_a_friend' ;;
    type: yesno
    }


### Step1: Nena's template for filtered measures
  dimension: connect_user {
    sql: ${screenName} = 'connect_stream_trending' ;;
    type: yesno
  }

  dimension: coach_tab {
    sql: ${screenName} = 'help_help_landing' ;;
    type: yesno
  }

  dimension: chat_now {
    sql: ${screenName}= 'help_chat_window' ;;
    type: yesno
  }

  dimension: get_help {
    sql: ${screenName}= 'help_mobile_faq' ;;
    type: yesno
  }

  dimension: profile_user {
    sql: regexp_contains(${screenName}, 'profile_my_profile|profile_myself_view') ;;
    type: yesno
  }

  dimension: plus_symbol {
    sql: ${screenName} = 'Track' ;;
    type: yesno
  }

dimension: search_bar {
  sql: ${screenName} = 'Search' ;;
  type: yesno
}

dimension: journey_tab {
  sql: ${screenName} = 'rewards_journey_home' ;;
  type: yesno
}

dimension: notifications_page {
  sql: regexp_contains(${screenName},'global_notifications|connect_notifications') ;;
  type: yesno
}

  dimension: connect_new_tab {
    sql: ${screenName} = 'connect_stream_new';;
    type: yesno
  }

  dimension: connect_follow_tab {
    sql: ${screenName} = 'connect_stream_following';;
    type: yesno
  }

  dimension: connect_profile_views {
    type: yesno
    sql: regexp_contains(${screenName}, 'connect_profile|profile_other_view') ;;

  }
}



view: hits_eventInfo {
  extends: [hits_eventInfo_base]
  dimension: play {
    sql: ${eventAction} = "play" ;;
    type: yesno
  }

  dimension: connect_likers {
    sql: regexp_contains(${eventAction}, 'connect_post_like|connect_comment_like|connect_reply_like|connect_post_like_tap') ;;
    type: yesno
  }

dimension: barcode_scans {
  sql: regexp_contains(${eventAction}, 'barcodescanner_') ;;
  type: yesno
}

dimension: group_id_new {
  sql: case when regexp_contains(${eventAction}, 'connect_groups_') then  ${eventLabel} end ;;
  type: string
}

dimension: connect_commenters {
  sql: (${eventAction} =  'connect_comment'
      or ${eventAction} = 'connect_reply_to_member') ;;
  type: yesno
}

dimension: connect_posters {
  sql: ${eventAction}= 'connect_post';;
  type: yesno
}

  dimension: groups_users {
    sql: regexp_contains(${eventAction},'connect_groups_landing|connect_groups_join_first_group|connect_groups_join_public_group') ;;
    type: yesno
  }
dimension: profile_followers {
  sql: ${eventAction} = 'connect_user_follow';;
  type: yesno
}

dimension: weight_tracking {
  sql: ${eventAction} = 'journey_trackedweight';;
  type: yesno
}

dimension: notifs_new_follower {
  sql: ${eventAction} = 'notifications_connect_new_follower'  ;;
  type: yesno
}

dimension: notifs_new_comment {
  sql: ${eventAction} = 'notifications_connect_new_comment' ;;
  type: yesno
}

dimension: notifs_new_like {
  sql: ${eventAction} = 'notifications_connect_new_like' ;;
  type: yesno
}

dimension: all_notifs {
  sql: regexp_contains(${eventAction}, 'notifications_connect_new_follower|notifications_connect_new_comment|notifications_connect_new_like') ;;
  type: yesno
}

  ##events related to iaf
  dimension: iaf_my_day {
    sql: ${eventAction} = 'iaf_my_day_card' ;;
    type: yesno

  }
  dimension: iaf_profile {
    sql: ${eventAction} = 'iaf_profile' ;;
    type: yesno
  }
  dimension: invite_friend {
    sql: ${eventAction} = 'iaf_invite_friends_button' ;;
    type:  yesno
  }
  dimension: iaf_myDay_desktop {
    sql: ${eventAction} = 'send_invite' AND ${eventLabel} = 'my_day' ;;
    type:  yesno
  }

  dimension: iaf_sendEmail_desktop {
    sql: ${eventAction} = 'send_email' AND ${eventLabel} = 'member_invite' ;;
    type:  yesno
  }

  dimension: iaf_copyLink_desktop {
    sql: ${eventAction} = 'copy_link' AND ${eventLabel} = 'member_invite' ;;
    type:  yesno
  }

  dimension: invite_desktop {
    sql: ${eventCategory} = 'invite_a_friend' AND ${eventLabel} = 'member_invite' ;;
    type:  yesno
  }


}

view: hits_product {
  extends:[hits_product_base]

}

#view: hits_product_customdimensions {
#  extends: [hits_product_customdimensions_base]
#}
view: hits_customDimensions {
  extends: [hits_customDimensions_base]
  # dimension: group_id {
  #  sql: (SELECT value FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions`.hits.customDimensions WHERE index=85) ;;
  # }

}

view: hits_customVariables {

  extends: [hits_customVariables_base]
}

view: customDimensions {
  extends: [customDimensions_base]

  dimension: product_owned {
    sql: case when customDimensions.index=10 then customDimensions.value end;;
    type: string
  }
  dimension: product_owned_group {
    type: string
    sql: case when  (case when customDimensions.index=10 then customDimensions.value end) = "[ONLINE]"
              then "Digital"
              WHEN (case when customDimensions.index=10 then customDimensions.value end) = "[MONTHLY_PASS, ETOOLS]"
              THEN "Studio"
              WHEN (case when customDimensions.index=10 then customDimensions.value end) = "[ETOOLS, MONTHLY_PASS]"
              THEN "Studio"
              ELSE null
              end;;
  }



}

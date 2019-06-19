include: "ga_block.view.lkml"

datagroup: monthly_cache_ga {
  sql_trigger: select EXTRACT(month FROM CURRENT_DATE('America/New_York')) ;;
}

explore: ga_sessions_block {
  extends: [ga_sessions_base]
  extension: required

  conditionally_filter:{
    filters: {
      field: ga_sessions.partition_date
      value: "7 days ago for 7 days"
      ## Partition Date should always be set to a recent date to avoid runaway queries
    }
    unless: ["ga_sessions.consolidated_date_filter"]
  }
}

view: ga_sessions {
  filter: consolidated_date_filter {
    default_value: "7 days ago for 7 days"
    description: "This filter applies to both session start time and partition date."
    type: date
    sql: ${partition_date::date} >= date_add(date({% date_start consolidated_date_filter %}), interval -2 day )
     AND ${partition_date::date} <= date_add(date({% date_end consolidated_date_filter %}), interval 2 day)
     AND {% condition consolidated_date_filter %} ${visitStart_raw} {% endcondition %} ;;
    convert_tz: no
  }
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

measure: fullvisitid_count {
  type: count_distinct
  sql: ${fullVisitorId} ;;
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

  measure: android_users {
    type: count_distinct
    sql: case when ${application_type} = 'Android' then ${fullVisitorId} end ;;
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

  measure: total_weight_tracking {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string)) ;;
    filters: {
      field: hits_eventInfo.weight_tracking
      value: "yes"
    }
  }


  measure: journey_weighttracking {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string)) ;;
    filters: {
      field: hits_eventInfo.weight_tracking
      value: "yes"
    }
    filters: {
      field: hits_appInfo.journey_weight_screens
      value: "yes"
    }
  }

  measure: journey_weighttracking_users {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string)) ;;
    filters: {
      field: hits_eventInfo.weight_tracking
      value: "yes"
    }
    filters: {
      field: hits_appInfo.journey_weight_screens
      value: "yes"
    }
  }

  measure: total_profile_weighttracking {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string)) ;;
    filters: {
      field: hits_appInfo.profile_weighttracking
      value: "yes"
    }
  }

  measure: profile_weighttracking_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.profile_weighttracking
      value: "yes"
    }
  }

  measure: weight_changemanagement_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.weight_changemanagement
      value: "yes"
    }
  }

measure: profile_weightseeall_users {
  type: count_distinct
  sql: ${fullVisitorId} ;;
  filters: {
    field: hits_appInfo.profile_weightseeall
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

  measure: groups_visits {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId}) ;;
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

  measure: all_users_following {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.all_follows
      value: "yes"
    }
  }


  measure: total_member_blocks {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId}) ;;
  filters: {
    field:hits_eventInfo.member_blocks
    value:"yes"
    }
  }

  measure: total_reported_comments {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId})  ;;
  filters: {
    field: hits_eventInfo.reported_comments
    value: "yes"
  }
  }

  measure: total_reported_posts {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId}) ;;
  filters: {
    field: hits_eventInfo.reported_posts
    value: "yes"
  }
  }

measure: total_connect_page_loads {
  type: count_distinct
sql: concat(cast(${visitId} as string),cast(hits.hitnumber as string)) ;;
filters: {
  field: hits_appInfo.connect_trending_page_loads
  value: "yes"
}
}

measure: new_feed_users {
  type: count_distinct
  sql: ${fullVisitorId} ;;
filters: {
  field: hits_appInfo.new_feed
  value: "yes"
}
}


  measure: following_feed_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.following_feed
      value: "yes"
    }
  }

measure: connect_trending_page {
  type: count_distinct
  sql: concat(cast(${visitId} as string),${fullVisitorId}) ;;
filters: {
  field: hits_appInfo.connect_trending_page
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

  measure: barcode_scanners {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.barcode_scans
      value: "yes"
    }
  }

  measure: total_barcode_scans {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string)) ;;
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


  measure: connect_posts {
    type: count_distinct
    sql:  concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string)) ;;
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
  measure: myday_meal_screens_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.myday_meal_screens
      value: "yes"
    }
  }

  measure: connect_share_withus_clicks {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string)) ;;
    filters: {
      field: hits_eventInfo.share_with_us_connect
      value: "yes"
    }
}

measure: select_video_clicks {
  type: count_distinct
  sql: concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string)) ;;
  filters: {
    field: hits_eventInfo.selected_video
    value: "yes"
  }
}

measure: connect_start_recording {
  type: count_distinct
  sql:  concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string))  ;;
  filters: {
    field: hits_eventInfo.start_recording_video
    value: "yes"
  }
}

measure: connect_finish_recording {
  type: count_distinct
  sql:  concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string))  ;;
  filters: {
    field: hits_eventInfo.finish_recording_video
    value: "yes"
  }
}

measure: connect_media_gallery {
  type: count_distinct
  sql: concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string))  ;;
  filters: {
    field: hits_appInfo.connect_media_gallery
    value: "yes"
  }
}

measure: choose_photovideot_clicks {
  type: count_distinct
  sql: concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string)) ;;
  filters: {
    field: hits_eventInfo.choose_photo_connect
    value: "yes"
  }
}

measure: capture_media_clicks {
  type: count_distinct
  sql: concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string)) ;;
  filters: {
    field: hits_appInfo.connect_capture_media
    value: "yes"
  }
}

measure: add_videophoto_connect_clicks {
  type: count_distinct
  sql: concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string))  ;;
  filters: {
    field: hits_eventInfo.add_videophoto_connect
    value: "yes"
  }
}

measure: backbutton_connectpost_clicks {
  type: count_distinct
  sql: concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string))  ;;
  filters: {
    field: hits_eventInfo.backbutton_connectpost
    value: "yes"
  }
}

measure: next_fromeditpost_connect_clicks {
  type: count_distinct
  sql: concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string)) ;;
  filters: {
    field: hits_appInfo.next_fromeditpost_connect
    value: "yes"
  }
}

  measure: myday_connect_carousel_users {
    type: count_distinct
    sql: ${fullVisitorId}  ;;
    filters: {
      field: hits_eventInfo.myday_connect_carousel
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


measure: view_incarousel_group {
  type: count_distinct
  sql: concat(cast(${visitId} as string),${fullVisitorId}) ;;
  filters: {
    field: hits_eventInfo.view_incarousel_group
    value: "yes"
  }
}

measure: browse_groups {
  type: count_distinct
  sql: concat(cast(${visitId} as string),${fullVisitorId}) ;;
  filters: {
    field: hits_eventInfo.browse_groups
    value: "yes"
  }
}

  measure: browse_groups_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.browse_groups
      value: "yes"
    }
  }

  measure: see_all_groups {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId}) ;;
    filters: {
      field: hits_eventInfo.see_all_groups
      value: "yes"
    }
  }

  measure: groups_either_selection {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId}) ;;
    filters: {
      field: hits_eventInfo.groups_either_selection
      value: "yes"
    }
  }

measure: users_joining_groups {
  type: count_distinct
  sql: ${fullVisitorId} ;;
  filters: {
    field: hits_eventInfo.join_group
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

  dimension: connect_media_gallery {
    sql: ${screenName} = 'connect_post_media' ;;
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

  dimension: profile_weighttracking {
    sql: ${screenName} = 'profile_trackweightcta' ;;
    type: yesno
  }


  dimension: profile_weightseeall {
    type: yesno
    sql: ${screenName} = 'profile_weightseeall' ;;
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

  dimension: myday_meal_screens {
    sql: regexp_contains(${screenName}, 'food_meal_breakfast|food_meal_breakfastlog|food_meal_dinner|food_meal_dinnerlog|food_meal_lunch|food_meal_lunchlog|food_meal_snacklog|food_meal_snack') ;;
    type: yesno
  }

dimension: connect_capture_media {
  sql: ${screenName} = 'connect_post_camera' ;;
  type: yesno
}

  dimension: next_fromeditpost_connect {
    sql: ${screenName}= 'connect_post_theme_done' ;;
    type: yesno
  }

dimension: new_feed {
  type: yesno
  sql: ${screenName} = 'connect_stream_new' ;;
}

dimension: following_feed {
  type: yesno
  sql: ${screenName} = 'connect_stream_following' ;;
}

dimension: journey_weight_screens {
  type: yesno
  sql: regexp_contains(${screenName}, 'journey_weightlossprogress|journey_weighttable') ;;
}


dimension: connect_trending_page_loads {
  type: yesno
  sql: regexp_contains(${screenName} , 'connect_stream_trending|connect_load_more_trending') ;;
}

dimension: connect_trending_page {
  type: yesno
  sql: ${screenName} = 'connect_stream_trending' ;;
  }

}



view: hits_eventInfo {
  extends: [hits_eventInfo_base]
  dimension: play {
    sql: ${eventAction} = "play" ;;
    type: yesno
  }

dimension: share_with_us_connect {
  sql: ${eventAction}='connect_share_with_us' ;;
  type: yesno
}

dimension:  start_recording_video {
  sql: ${eventAction} = 'connect_capture_tap_video_icon' ;;
  type: yesno
}

dimension: finish_recording_video {
  sql: ${eventAction} = 'connect_recording_done';;
  type: yesno
}

dimension: selected_video {
  sql: ${eventAction} = 'connect_gallery_video_length' ;;
  type: yesno
}

dimension: choose_photo_connect {
  sql: ${eventAction} = 'connect_gallery_continue' ;;
  type: yesno
}

dimension: browse_groups {
  sql: regexp_contains(${eventAction}, '^connect_groups_find_group$|^connect_groups_find_first_group$|^connect_groups_popup_findgroup$') ;;
  type: yesno
}

dimension: see_all_groups {
  sql: regexp_contains(${eventAction}, '^connect_groups_see_all_|^connect_groups_see_alldas_bin_ich$|connect_groups_see_allmein_weg$|connect_groups_see_allessen$|connect_groups_see_allumdenken$|connect_groups_see_allbewegen$|connect_groups_see_allprofil$|connect_groups_see_allmon_parcours$|connect_groups_see_allaliment$|connect_groups_see_all_tat_d_esprit$') ;;
  type: yesno
}

dimension: view_incarousel_group {
  sql: regexp_contains(${eventAction}, 'connect_groups_see_food_|connect_groups_see_journey_|connect_groups_see_identity_|connect_groups_see_journey_|connect_groups_see_mindset_|connect_groups_see_activity_|connect_groups_see_Food_|connect_groups_see_hobbies_|connect_groups_see_Hobbies_|connect_groups_see_hobbies_|connect_groups_see_Journey_|connect_groups_see_Mein_Weg_|connect_groups_see_Mon_parcours_|connect_groups_see_Essen_|connect_groups_see_Umdenken_|connect_groups_see_Das_bin_ich_|connect_groups_see_Activité_|connect_groups_see_Cuisine_|connect_groups_see_locations_|connect_groups_see_État_d_esprit_|connect_groups_see_Bewegen_|connect_groups_see_Profil_|connect_groups_see_Eten_|connect_groups_see_Aktivitet_|connect_groups_see_Alimentação_|connect_groups_see_Resa_|connect_groups_see_Beweging_|connect_groups_see_Dit_ben_ik__|connect_groups_see_Mat_|connect_groups_see_Mijn_WW_|connect_groups_see_Feel_good_') ;;
  type: yesno
}

dimension: groups_either_selection {
  sql: regexp_contains(${eventAction}, '^connect_groups_see_all_|^connect_groups_see_alldas_bin_ich$|connect_groups_see_allmein_weg$|connect_groups_see_allessen$|connect_groups_see_allumdenken$|connect_groups_see_allbewegen$|connect_groups_see_all_tat_d_esprit$|connect_groups_see_allprofil$|connect_groups_see_allaliment$|connect_groups_see_food_|connect_groups_see_journey_|connect_groups_see_identity_|connect_groups_see_journey_|connect_groups_see_mindset_|connect_groups_see_activity_|connect_groups_see_Food_|connect_groups_see_hobbies_|connect_groups_see_Hobbies_|connect_groups_see_hobbies_|connect_groups_see_Journey_|connect_groups_see_Mein_Weg_|connect_groups_see_Mon_parcours_|connect_groups_see_Essen_|connect_groups_see_Umdenken_|connect_groups_see_Das_bin_ich_|connect_groups_see_Activité_|connect_groups_see_Cuisine_|connect_groups_see_locations_|connect_groups_see_État_d_esprit_|connect_groups_see_Bewegen_|connect_groups_see_Profil_|connect_groups_see_Eten_|connect_groups_see_Aktivitet_|connect_groups_see_Alimentação_|connect_groups_see_Resa_|connect_groups_see_Beweging_|connect_groups_see_Dit_ben_ik__|connect_groups_see_Mat_|connect_groups_see_Mijn_WW_|connect_groups_see_Feel_good_') ;;
  type: yesno
}

dimension: backbutton_connectpost {
  sql: ${eventAction} = 'connect_post_flow_back_button' ;;
  type: yesno
}
  dimension: add_videophoto_connect {
    sql: ${eventAction}= 'connect_post_add_video_photo' ;;
    type: yesno
  }
dimension: join_group {
  sql: ${eventAction} = 'connect_groups_join_public_group' ;;
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

  dimension: barcode_scan_names {
    type: string
    sql: (CASE WHEN regexp_contains(${eventAction}, "barcodescanner_crowdsourced|barcodescanner_crowdsourceditem")
        THEN "Crowdsourced"
        WHEN ${eventAction}= "barcodescanner_fooddatabase" THEN "WW Verified Food"
        WHEN ${eventAction}="barcodescanner_foodsnondatabase" THEN "Not in DB"
        end)
        ;;
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

dimension: myday_iaf {
  sql: ${eventAction} = 'iaf_my_day_card' ;;
  type: yesno
}

dimension: myday_connect_carousel {
  type: yesno
  sql: regexp_contains(${eventAction}, 'connect_mini_post_1|connect_mini_post_2|connect_mini_post_3|connect_seemoreposts_myday') ;;
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



dimension: weight_changemanagement {
  sql:  ${eventLabel} = 'see_on_profile' ;;
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

dimension: all_follows {
  sql: regexp_contains(${eventAction}, 'connect_user_follow|connect_member_fast_follow') ;;
  type: yesno
}

dimension: member_blocks {
  sql: regexp_contains(${eventAction}, 'connect_user_block|connect_block_member_profile') ;;
  type: yesno
}

dimension: reported_comments {
  sql: regexp_contains(${eventAction}, 'connect_comment_report|connect_reply_report') ;;
  type: yesno
}

dimension: reported_posts {
  sql: ${eventAction} = 'connect_post_report' ;;
  type: yesno
}

dimension: tracked_food {
  sql: regexp_contains(${eventAction}, 'tracking_trackedfood|food_frequentFoods_tracked|tracking_trackeditem|food_frequents_tracked|tracking_trackedrecipe|tracking_trackedmeal') ;;
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

  dimension: aaptiv_card_name {
    sql: case when ${eventAction} in ('activity_card_aaptiv', 'aaptivcard') then 'Aaptiv'
      when ${eventAction} in ('activity_card_aaptiv_Start_getting_st_0', 'activity_card_aaptiv_Start_getting_stron', 'activity_card_aaptiv_Start_getting_', 'activity_card_aaptiv_Start_getting' , 'activity_card_aaptiv_Start_getting_stro',
      'activity_card_aaptiv_Commencer___de', 'activity_card_aaptiv_Commencer_à_d' then 'Start Getting Stronger'
      when ${eventAction} in ('activity_card_aaptiv_Basic_walking_wo_0' , 'activity_card_aaptiv_Basic_walking_worko', 'activity_card_aaptiv_Basic_walking_work', 'activity_card_aaptiv_Basic_walking_work', 'activity_card_aaptiv_Basic_walking',
      'activity_card_aaptiv_Entra_nement_d' then 'Basic Walking'
      when ${eventAction} in ('activity_card_aaptiv_Walk_to_the_beat_0', 'activity_card_aaptiv_Walk_to_the_beat', 'activity_card_aaptiv_Walk_to_the_be', 'activity_card_aaptiv_Walk_to_the_b', 'activity_card_aaptiv_Marcher_en_ryt', 'activity_card_aaptiv_Marcher_en_ry', 'activity_card_aaptiv_Courir_en_mesu',
      'activity_card_aaptiv_Courir_en_mes') then 'Walk to the Beat'
      when ${eventAction} in ('activity_card_aaptiv_Pick_up_the_pace_0', 'activity_card_aaptiv_Pick_up_the_pace', 'activity_card_aaptiv_Pick_up_the_pa', 'activity_card_aaptiv_Pick_up_the_p', 'activity_card_aaptiv_Acc_l_rer_le_r', 'activity_card_aaptiv_Accélérer_le_',
      'activity_card_aaptiv_De_la_marche_a') then 'Pick Up the Pace'
      when ${eventAction} in ('activity_card_aaptiv_Fast_and_total_t_0', 'activity_card_aaptiv_Fast_and_total_trai', 'activity_card_aaptiv_Fast_and_total_tra', 'activity_card_aaptiv_Fast_and_total', 'activity_card_aaptiv_Fast_and_tota', 'activity_card_aaptiv_Entra_nement_r',
      'activity_card_aaptiv_Entra_nement_c') then 'Fast and Total Training'
      when ${eventAction} in ('activity_card_aaptiv_Find_your_streng_0', 'activity_card_aaptiv_Find_your_strength', 'activity_card_aaptiv_Find_your_stre', 'activity_card_aaptiv_Find_your_str', 'activity_card_aaptiv_Trouvez_votre_', 'activity_card_aaptiv_Trouvez_votre',
      'activity_card_aaptiv_D_couvrez_votr') then 'Find your Strength'
      when ${eventAction} in ('activity_card_aaptiv_Jog_run_interval_0', 'activity_card_aaptiv_Jog_run_intervals', 'activity_card_aaptiv_Jog_run_interv', 'activity_card_aaptiv_Jog_run_inter', 'activity_card_aaptiv_Intervalles_jo', 'activity_card_aaptiv_Intervalles_j',
      'activity_card_aaptiv_Entra_nement_f'then 'Jog/Run'
      when ${eventAction} in ('activity_card_aaptiv_Get_strong_faste_0', 'activity_card_aaptiv_Get_strong_faster', 'activity_card_aaptiv_Get_strong_fas', 'activity_card_aaptiv_Get_strong_fa', 'activity_card_aaptiv_Devenir_fort_', 'activity_card_aaptiv_Devenir_fort_p', 'activity_card_aaptiv_Circuit_d_entr',
      'activity_card_aaptiv_Circuit_d_ent') then 'Get Strong Faster'
      when ${eventAction} in ('activity_card_aaptiv_Cardio___strengt_0', 'activity_card_aaptiv_Cardio___strength', 'activity_card_aaptiv_Cardio___stren', 'activity_card_aaptiv_Cardio___stre', 'activity_card_aaptiv_Cardio___renfo', 'activity_card_aaptiv_Cardio___renf',
      'activity_card_aaptiv_Cardio___muscu') then 'Cardio + Strength'


     else 'Other' end
              ;;
    suggestions: [ "Aaptiv", "Start Getting Stronger", "Basic Walking", "Walk to the Beat", "Pick Up the Pace", "Fast and Total Training", "Find your Strength", "Jog/Run",
      "Get Strong Faster", "Cardio + Strength"]
    }

  dimension: aaptiv_cards {
    sql: case when  ${aaptiv_card_name} in ( "Aaptiv", "Start Getting Stronger", "Basic Walking", "Walk to the Beat", "Pick Up the Pace", "Fast and Total Training", "Find your Strength", "Jog/Run",
      "Get Strong Faster", "Cardio + Strength" ) then ${aaptiv_card_name}
        else null end
         ;;
    type: string

  }

  dimension: aaptiv_cards_yesno {
    sql:  ${aaptiv_card_name} in ( "Aaptiv", "Start Getting Stronger", "Basic Walking", "Walk to the Beat", "Pick Up the Pace", "Fast and Total Training", "Find your Strength", "Jog/Run",
      "Get Strong Faster", "Cardio + Strength")

               ;;
    type: yesno

  }




  dimension: card_name {
    sql: case when ${eventAction} = 'food_card_mindset' then 'Headspace'
              when ${eventAction} = 'activity_card_aaptiv' then 'Aaptiv'
 when ${hits_appInfo.screenName} = 'Search' then 'Search'
               when (${eventAction} = 'food_browse_Recipes' or ${eventAction} = 'browse_recipe') then 'Discover Recipes'
               when ${hits_appInfo.screenName} = 'connect_stream_trending' then 'Connect (Bottom of My Day)'
              when ${eventAction} = 'connect_seemoreposts_myday' then 'Connect (See More)'
              when ${eventAction} = 'iaf_my_day_card' then 'Invite a Friend'
              when ${hits_appInfo.screenName} = 'food_browse_Restaurants' then 'Restaurants'
              when ${hits_appInfo.screenName} = 'food_rollovercard' then 'Rollover Card'

              when ${hits_appInfo.screenName} = 'activity_dashboard' then 'Activity Dashboard'
              when ${eventAction} = 'onb_skip_tutorials' then 'Onboarding - Skip Tutorial'
              when ${eventAction} = 'onb_start_tutorial1' then 'Onboarding - Start Tutorial'
              when ${hits_appInfo.screenName} in ('food_card_recipes_Starter_Meals','food_card_recipes_Meals_for_Protein_Lovers','food_card_recipes_Meals_for_Carb_Lovers',
                       'food_card_recipes_Ideas_for_Veggie_Lovers','food_card_recipes_Family_Friendly_Meals', 'food_card_recipes_Endlich_Frühling_', 'food_card_recipes_Endlich_Fr_hling_', 'food_card_recipes_Iss__was_dir_schmeckt', 'food_card_recipes_Iss__was_dir_schmeckt_',
                      'food_card_recipes_Eintöpfe___Suppen', 'food_card_recipes_Bei_Partys_und_Festen', 'food_card_recipes_Snacks', 'food_card_recipes_Quick___easy', 'food_card_recipes_Seasonal', 'food_card_recipes_0_5_SmartPoints_', 'food_card_recipes_0_5_SmartPoints__recipes',
                      'food_card_recipes_Family_friendly','food_card_recipes_Go_veg_', ' food_card_recipes_Simple_snacks' ) then 'Recipe Tenure'

  when (${hits_appInfo.screenName} not in ('food_card_recipes_Starter_Meals','food_card_recipes_Meals_for_Protein_Lovers','food_card_recipes_Meals_for_Carb_Lovers',
                       'food_card_recipes_Ideas_for_Veggie_Lovers','food_card_recipes_Family_Friendly_Meals', 'food_card_recipes_Endlich_Frühling_', 'food_card_recipes_Endlich_Fr_hling_', 'food_card_recipes_Iss__was_dir_schmeckt', 'food_card_recipes_Iss__was_dir_schmeckt_',
                      'food_card_recipes_Eintöpfe___Suppen', 'food_card_recipes_Bei_Partys_und_Festen', 'food_card_recipes_Snacks', 'food_card_recipes_Quick___easy', 'food_card_recipes_Seasonal', 'food_card_recipes_0_5_SmartPoints_', 'food_card_recipes_0_5_SmartPoints__recipes',
                      'food_card_recipes_Family_friendly','food_card_recipes_Go_veg_', ' food_card_recipes_Simple_snacks'  ) and ${hits_appInfo.screenName} like 'food_card_recipes_%')  then 'Recipe Date'

when (${hits_appInfo.screenName} not in ('food_card_article_Don_t_Know_What_to_Eat_', 'food_card_article_Meal_planning_and_shopping_tips', 'food_card_article_What_is_Connect_', 'food_card_article_Should_I_tap_into_my_Weekly_SmartPoints_', 'food_card_article_The_importance_of_tracking_your_weight', 'food_card_article_What_s_your__why__',
              'food_card_article_Tips_for_dining_out', 'food_card_article_Ideas_for_Smart_Snacking', 'food_card_article_How_do_I_estimate_portions_', 'food_card_article_Tips_for_syncing_your_fitness_device', 'food_card_article_Why_does_fruit_count_in_a_smoothie_', 'food_card_article_The_importance_of_practicing_awareness',
              'food_card_article_How_to_avoid_emotional_eating', 'food_card_article_The_importance_of_non_weight_goals', 'food_card_article_Keep_going_strong_with_WellnessWins_', 'food_card_article_Should_I_tap_into_my_weekly_SmartPoints_', 'food_card_article_Ideas_for_smart_snacking',
              'food_card_article_Tips_for_syncing_your_fitness_device_', 'food_card_article_The_importance_of_practicing_awareness_', 'food_card_article_Du_weißt_nicht__was_du_essen_sollst_', 'food_card_article_Du_wei_t_nicht__was_du_essen_sollst_', 'food_card_article_Du_weisst_nicht__was_du_essen_sollst_',
              'food_card_article_Dein_Einmaleins_im_Supermarkt', 'food_card_article_Muss_ich_meine_wöchentlichen_SmartPoints_nutzen_', 'food_card_article_Muss_ich_meine_w_chentlichen_SmartPoints_nutzen_', 'food_card_article_Wiegen_ist_wichtig__aber_nicht_alles', 'food_card_article_Wiegen_ist_wichtig__aber_nicht_alles_',
              'food_card_article_Alles_im__Gr_nen_Bereich_', 'food_card_article_Alles_im__Grünen_Bereich_', 'food_card_article_zero_Points__Lebensmitteln', 'food_card_article_Zero_Points_Lebensmittel', 'food_card_article_Einladungen_und_Restaurants', 'food_card_article_Warum_du_nicht_nur_zero_Points_Lebensmittel_essen_solltest',
              'food_card_article_Warum_du_nicht_nur_zero_Points__Lebensmittel_essen_solltest', 'food_card_article_Portionsgrößen_schätzen', 'food_card_article_Portionsgr__en_sch_tzen', 'food_card_article_Portionen_richtig_schätzen', 'food_card_article_Portionen_richtig_schätzen_', 'food_card_article_Portionen_richtig_sch_tzen',
              'food_card_article_Portionen_richtig_sch_tzen_', 'food_card_article_Portionsgrössen_schätzen', 'food_card_article_Essen_auf_Partys_und_Veranstaltungen', 'food_card_article_Im_Urlaub_und_auf_Reisen', 'food_card_article_Bewusst__und_nicht_aus_Langeweile_essen', 'food_card_article_Bewusst_und_nicht_aus_Langeweile_essen',
              'food_card_article_Snacks_für_unterwegs', 'food_card_article_Snacks_f_r_unterwegs', 'food_card_article_Snacks_für_Unterwegs','food_card_article_What_can_I_eat_', 'food_card_article_Meal_planning_and_shopping_tips', 'food_card_article_Should_I_tap_into_my_weekly_SmartPoints_', 'food_card_article_Should_I_tap_into_my_Weekly_SmartPoints_', 'food_card_article_Should_I_tap_into_my_weekly_SmartPoints__', 'food_card_article_Why_we_weigh_in',
              'food_card_article_What_is_the_tracking_zone_', 'food_card_article_Your_questions_answered_about_eating_ZeroPoint__foods', 'food_card_article_Tips_for_eating_out', 'food_card_article_SmartPoints__are_there_to_be_enjoyed_', 'food_card_article_How_do_I_estimate_portions_on_the_go_',
              'food_card_article_Yep__you_can_still_enjoy_your_social_life_', 'food_card_article_Eating_on_the_go', 'food_card_article_How_to_do_I_eat_more_mindfully_', 'food_card_article_Hack_Your_Snacks', 'food_card_article_Hack_your_snacks'
              ) and ${hits_appInfo.screenName} like 'food_card_article_%') then 'Article Date'

               when ${hits_appInfo.screenName} in ('food_card_article_Don_t_Know_What_to_Eat_', 'food_card_article_Meal_planning_and_shopping_tips', 'food_card_article_What_is_Connect_', 'food_card_article_Should_I_tap_into_my_Weekly_SmartPoints_', 'food_card_article_The_importance_of_tracking_your_weight', 'food_card_article_What_s_your__why__',
              'food_card_article_Tips_for_dining_out', 'food_card_article_Ideas_for_Smart_Snacking', 'food_card_article_How_do_I_estimate_portions_', 'food_card_article_Tips_for_syncing_your_fitness_device', 'food_card_article_Why_does_fruit_count_in_a_smoothie_', 'food_card_article_The_importance_of_practicing_awareness',
              'food_card_article_How_to_avoid_emotional_eating', 'food_card_article_The_importance_of_non_weight_goals', 'food_card_article_Keep_going_strong_with_WellnessWins_', 'food_card_article_Should_I_tap_into_my_weekly_SmartPoints_', 'food_card_article_Ideas_for_smart_snacking',
              'food_card_article_Tips_for_syncing_your_fitness_device_', 'food_card_article_The_importance_of_practicing_awareness_', 'food_card_article_Du_weißt_nicht__was_du_essen_sollst_', 'food_card_article_Du_wei_t_nicht__was_du_essen_sollst_', 'food_card_article_Du_weisst_nicht__was_du_essen_sollst_',
              'food_card_article_Dein_Einmaleins_im_Supermarkt', 'food_card_article_Muss_ich_meine_wöchentlichen_SmartPoints_nutzen_', 'food_card_article_Muss_ich_meine_w_chentlichen_SmartPoints_nutzen_', 'food_card_article_Wiegen_ist_wichtig__aber_nicht_alles', 'food_card_article_Wiegen_ist_wichtig__aber_nicht_alles_',
              'food_card_article_Alles_im__Gr_nen_Bereich_', 'food_card_article_Alles_im__Grünen_Bereich_', 'food_card_article_zero_Points__Lebensmitteln', 'food_card_article_Zero_Points_Lebensmittel', 'food_card_article_Einladungen_und_Restaurants', 'food_card_article_Warum_du_nicht_nur_zero_Points_Lebensmittel_essen_solltest',
              'food_card_article_Warum_du_nicht_nur_zero_Points__Lebensmittel_essen_solltest', 'food_card_article_Portionsgrößen_schätzen', 'food_card_article_Portionsgr__en_sch_tzen', 'food_card_article_Portionen_richtig_schätzen', 'food_card_article_Portionen_richtig_schätzen_', 'food_card_article_Portionen_richtig_sch_tzen',
              'food_card_article_Portionen_richtig_sch_tzen_', 'food_card_article_Portionsgrössen_schätzen', 'food_card_article_Essen_auf_Partys_und_Veranstaltungen', 'food_card_article_Im_Urlaub_und_auf_Reisen', 'food_card_article_Bewusst__und_nicht_aus_Langeweile_essen', 'food_card_article_Bewusst_und_nicht_aus_Langeweile_essen',
              'food_card_article_Snacks_für_unterwegs', 'food_card_article_Snacks_f_r_unterwegs', 'food_card_article_Snacks_für_Unterwegs',  'food_card_article_What_can_I_eat_', 'food_card_article_Meal_planning_and_shopping_tips', 'food_card_article_Should_I_tap_into_my_weekly_SmartPoints_', 'food_card_article_Should_I_tap_into_my_Weekly_SmartPoints_', 'food_card_article_Should_I_tap_into_my_weekly_SmartPoints__', 'food_card_article_Why_we_weigh_in',
              'food_card_article_What_is_the_tracking_zone_', 'food_card_article_Your_questions_answered_about_eating_ZeroPoint__foods', 'food_card_article_Tips_for_eating_out', 'food_card_article_SmartPoints__are_there_to_be_enjoyed_', 'food_card_article_How_do_I_estimate_portions_on_the_go_',
              'food_card_article_Yep__you_can_still_enjoy_your_social_life_', 'food_card_article_Eating_on_the_go', 'food_card_article_How_to_do_I_eat_more_mindfully_', 'food_card_article_Hack_Your_Snacks', 'food_card_article_Hack_your_snacks'
              ) then 'Article Tenure'

              when ${hits_appInfo.screenName} in ('food_browse_recipes_Popular', 'food_browse_recipes_Low_SmartPoints_Mains', 'food_browse_recipes_Low_SmartPoints_Sides', 'food_browse_recipes_Zero_SmartPoints_Toppings___Dips', 'food_browse_recipes_No_Cook', 'food_browse_recipes_Quick___Easy', 'food_browse_recipes_Chicken_Every_Way',
              'food_browse_recipes_Cooking_for_One') then 'Default Collections - Discover Recipes'
              when ${hits_appInfo.screenName} like ('food_card_recipes_%') then 'All Recipes'
              when ${hits_appInfo.screenName} like ('food_card_article_%') then 'All Articles'
              when ${eventAction} = 'food_browse_recipebuilder' then 'Recipe Builder'
              when ${hits_appInfo.screenName} = 'MemberRecipes' then 'Member Recipes'
              when ${eventAction} = 'food_browse_seeall' then 'See All'
              when ${eventAction} = 'food_browse_favorites' then 'Favorites'
              when ${hits_appInfo.screenName} = 'Favorites' then 'Favorites (+)'
              when ${eventAction} = 'food_browse_featuredcollectionscroll' then 'Featured Collection Scroll'
               when ${eventAction} = 'food_browse_created' then 'Created'


              -- Continue with the rest of the cards
              else 'Other' end
              ;;
    suggestions: ["Search","Headspace", "Aaptiv", "Recipe Tenure","Discover Recipes","Connect", "Invite a Friend", "Restaurants", "Rollover Card" ,"Activity Dashboard", "Onboarding - Skip Tutorial","Onboarding - Start Tutorial", "All Recipes","All Articles", "Article Tenure", "Default Collections - Discover Recipes", "Other", "Article Date", "Recipe Date", "Created", "Featured Collection Scroll", "Favorites (+)", "Favorites", "See All",  "Member Recipes", "Recipe Builder" ]
  }


dimension: my_day_cards {
  sql: case when  ${card_name} in ("Search","Headspace", "Aaptiv", "Recipe Tenure","Discover Recipes","Connect (Bottom of My Day)","Connect (See More)", "Invite a Friend", "Restaurants", "Rollover Card" ,"Activity Dashboard", "Onboarding - Skip Tutorial", "Onboarding - Start Tutorial", "Article Tenure", "Article Date", "Recipe Date") then ${card_name}
  else null end
   ;;
  type: string

}

  dimension: my_day_cards_yesno {
    sql:  ${card_name} in ("Search","Headspace", "Aaptiv", "Recipe Tenure","Discover Recipes","Connect (Bottom of My Day)","Connect (See More)", "Invite a Friend", "Restaurants", "Rollover Card" ,"Activity Dashboard", "Onboarding - Skip Tutorial", "Onboarding - Start Tutorial", "Article Tenure", "Article Date", "Recipe Date")

         ;;
    type: yesno

  }

dimension: recipe_and_articles_cards {

  sql:  case when ${card_name} in ("Recipe Tenure",  "Recipe Date", "All Recipes", "Article Tenure", "Article Date","All Articles")  then ${card_name}
  else null end;;
  type:  string
}

  dimension: recipe_and_articles_cards_yesno {

    sql:  ${card_name} in ("Recipe Tenure",  "Recipe Date", "All Recipes", "Article Tenure", "Article Date","All Articles")
     ;;
    type:  yesno
  }

  dimension: recipe_and_article_card_category{
    sql: case when ${recipe_and_articles_cards} in ('Article Tenure', 'Article Date')  then 'All Articles'
         when ${recipe_and_articles_cards} in ('Recipe Tenure', 'Recipe Date') then 'All Recipes' END;;
    drill_fields: ["recipe_and_articles_cards"]
  }


dimension: discover_recipe_cards {

  sql:  case when ${card_name} in ("Created", "Featured Collection Scroll", "Favorites (+)", "Favorites", "See All",  "Member Recipes", "Recipe Builder", "Discover Recipes")  then ${card_name}
  else null end;;
  type:  string
}

  dimension: discover_recipe_card_yesno {

    sql:  ${card_name} in ("Created", "Featured Collection Scroll", "Favorites (+)", "Favorites", "See All",  "Member Recipes", "Recipe Builder", "Discover Recipes")
      ;;
    type:  yesno
}

dimension: tenure_or_date {
  label: "Card type - Tenure or Date"
  sql: case when ${card_name} in ('Recipe Date', 'Article Date') then 'Date-Based Card'
            when ${card_name} in ('Recipe Tenure', 'Article Tenure') then 'Tenure-Based Card'
       else null end;;
  suggestions: ["Date-Based Card","Tenure-Based Card" ]
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

  dimension: post_type {
    type: string
    sql: case when hits_customDimensions.index=76 then hits_customDimensions.value end ;;
  }

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

  dimension: region_name {
    type: string
    sql: case when  (case when customDimensions.index=53 then customDimensions.value end) = "us"
              then "United States"
              WHEN (case when customDimensions.index=53 then customDimensions.value end) = "de"
              THEN "Germany"
              WHEN (case when customDimensions.index=53 then customDimensions.value end) = "gb"
              THEN "UK"
              WHEN (case when customDimensions.index=53 then customDimensions.value end) = "fr"
              THEN "France"
              WHEN (case when customDimensions.index=53 then customDimensions.value end) = "ca"
              THEN "Canada"
              WHEN (case when customDimensions.index=53 then customDimensions.value end) = "se"
              THEN "Sweden"
              WHEN (case when customDimensions.index=53 then customDimensions.value end) = "au"
              THEN "ANZ"
              WHEN (case when customDimensions.index=53 then customDimensions.value end) = "nl"
              THEN "Netherlands"
              WHEN (case when customDimensions.index=53 then customDimensions.value end) = "be"
              THEN "Belgium"
              WHEN (case when customDimensions.index=53 then customDimensions.value end) = "ch"
              THEN "Switzerland"
              ELSE null
              end ;;
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

#dimension: post_type {
#  type: string
#  sql: case when customDimensions.index=76 then customDimensions.value end ;;
#}

}

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

  measure: natural_search_users {
    filters: {
      field: channelGrouping
      value: "Natural Search"
    }
    type: count_distinct
    sql: ${fullVisitorId} ;;
  }

  measure: natural_search_signups{
    filters: {
      field: channelGrouping
      value: "Natural Search"
    }
    type: sum_distinct
    sql_distinct_key: concat(${hits_item.transactionId},${hits_product.v2ProductName},${hits.id}) ;;
    sql: ${totals.transactions} ;;
  }

  measure: natural_search_digital_signups{
    filters: {
      field: channelGrouping
      value: "Natural Search"
    }
    filters: {
      field: hits_product.Product
      value: "Digital"
    }
    type: sum_distinct
    sql_distinct_key: concat(${hits_item.transactionId},${hits_product.v2ProductName},${hits.id}) ;;
    sql: ${totals.transactions} ;;
  }

  measure: natural_search_studio_signups{
    filters: {
      field: channelGrouping
      value: "Natural Search"
    }
    filters: {
      field: hits_product.Product
      value: "Studio"
    }
    type: sum_distinct
    sql_distinct_key: concat(${hits_item.transactionId},${hits_product.v2ProductName},${hits.id}) ;;
    sql: ${totals.transactions} ;;
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

  measure: profile_mthlypass {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_appInfo.profile_mthlypass
      value: "yes"
    }
  }

  measure: chat_with_coach {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.chat_with_coach
      value: "yes"
    }
  }

  measure: find_studio {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.profile_mtgfinderweb
      value: "yes"
    }
  }

  measure: personal_coaching {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.personal_coaching
      value: "yes"
    }
  }

  measure: more_resources {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.more_resources
      value: "yes"
    }
  }

  measure: myday_groups_carousel_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.myday_groups_carousel
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

  measure: weight_mydaycard_users {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    filters: {
      field: hits_eventInfo.weight_mydaycard
      value: "yes"
    }
  }

  measure: weight_mydaycard_sessions {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId});;
    filters: {
      field: hits_eventInfo.weight_mydaycard
      value: "yes"
    }
  }

  measure: journey_messages_users {
    type: count_distinct
    sql: ${fullVisitorId};;
    filters: {
      field: hits_appInfo.journey_messages
      value: "yes"
    }
  }

measure:  profile_follows {
  type: count_distinct
  sql: concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string)) ;;
  filters: {
    field: hits_eventInfo.profile_followers
    value: "yes"
    }
  }

  measure:  feed_follows {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string)) ;;
    filters: {
      field: hits_eventInfo.feed_fast_follow
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
    sql:  concat(cast(${visitId} as string),${fullVisitorId}) ;;
    filters: {
      field: hits_appInfo.connect_profile_views
      value: "yes"
    }
  }

  measure: total_connect_profile_views {
    type: count_distinct
    sql:concat(cast(${visitId} as string),${fullVisitorId},cast(hits.hitnumber as string)) ;;
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

  measure: close_mydayweight_total {
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId}) ;;
    filters: {
      field: hits_eventInfo.close_myday_weightcard
      value: "yes"
    }
  }

  measure: mini_post_total_x{
    type: count_distinct
    sql: concat(cast(${visitId} as string),${fullVisitorId}) ;;
    filters: {
      field: hits_eventInfo.mini_post_x
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

  measure: total_connect_comments {
    type: count_distinct
    sql: concat(cast(${visitId} as string),cast(hits.hitnumber as string)) ;;
    filters: {
      field: hits_eventInfo.connect_commenters
      value: "yes"
    }
  }

  measure: total_connect_likes {
    type: count_distinct
    sql: concat(cast(${visitId} as string),cast(hits.hitnumber as string)) ;;
    filters: {
      field:  hits_eventInfo.connect_likers
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

#  dimension: device_language {
#    type: string
#
 # }

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

  dimension: journey_messages {
    sql: ${screenName} = 'journey_messages' ;;
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

  dimension: profile_mthlypass {
    sql: ${screenName} = 'profile_mthlypass';;
    type: yesno
  }

  dimension: connect_follow_tab {
    sql: ${screenName} = 'connect_stream_following';;
    type: yesno
  }

  dimension: connect_profile_views {
    type: yesno
    sql: regexp_contains(${screenName}, '^connect_profile$|^profile_other_view$') ;;

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
  sql: regexp_contains(${eventAction}, 'groups_my_day_browse|^connect_groups_find_group$|^connect_groups_find_first_group$|^connect_groups_popup_findgroup$') ;;
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

dimension: myday_groups_carousel {
  sql: regexp_contains(${eventAction}, 'groups_my_day_browse|groups_my_day_') ;;
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
  sql: (case when regexp_contains(${eventAction}, 'connect_groups_') then  ${eventLabel} ELSE NULL END) ;;
  type: string
}

dimension: group_id_name {
  type: string
  sql: (case when ${group_id_new} = '6ad99fd2-3dd7-4bf6-ae09-7bdb5f940395' then 'Black Women'
              WHEN ${group_id_new} = 'bfb51aec-f1bd-4ab3-9667-a97b04636cc8' then 'Arizona Members'
              WHEN ${group_id_new} = 'f8bb2853-68d2-4f1b-b2ed-9ef81c6d0ea4' THEN 'Cincinnati Members'
              WHEN ${group_id_new} = '2357dc29-e414-43d9-bbe2-71dbb529fad5' THEN 'Dry WW'
              WHEN ${group_id_new} = '4a2d8345-3118-4adb-884d-1d6862876392' THEN 'San Antonio Members'
              WHEN ${group_id_new} = 'e7f04720-549e-4aa3-a842-247dcd9c7b8c' THEN 'Latinas'
              WHEN ${group_id_new} = '0ba56447-dab4-4db3-9ae9-ad4e9207915f' THEN 'Portland Members'
              WHEN ${group_id_new} = '52bc0eb3-cec4-4df3-9b62-35f424bf1124' THEN 'Kansas City Members'
              WHEN ${group_id_new} = 'ef4233b6-6936-448a-a55c-629fa4e5dfb3' THEN 'Triathlon Prep'
              WHEN ${group_id_new} = '956da33d-5de0-43eb-979f-3ea0541be575' THEN 'Minneapolis Members'
              WHEN ${group_id_new} = 'eac9b5a8-5196-4b4f-aa43-e3d5298f8b25' THEN 'Wisconsin Members'
              WHEN ${group_id_new} = 'fd937f96-5c80-4bb3-919d-b89bcd22b63b' THEN 'Washington, DC Members'
              WHEN ${group_id_new} = '6b03f7f3-e9b4-4afa-a9c0-af9feb387b5b' THEN 'Seattle Members'
              WHEN ${group_id_new} = '52d817ac-d285-4dd0-b69a-a4d34e8a14a6' then 'San Diego Members'
              WHEN ${group_id_new} = 'ddcfc003-7eac-4b08-a8f3-6068d4bde4e8' then 'Michigan Members'
              WHEN ${group_id_new} = '7f63ed8d-5036-43e8-9377-71f6e808890b' then 'Bay Area Members'
              WHEN ${group_id_new} = 'd530acd3-976a-40db-a4b7-fcc09d819e44' then 'Living with Diabetes'
              WHEN ${group_id_new} = '15349788-2b5d-4f57-bbf0-72278f03b375' then 'Food Finds'
              WHEN ${group_id_new} = 'a1294e41-83b9-4bbe-ac05-e48759f375d4' then 'Bride To Be'
              WHEN ${group_id_new} = 'e428367d-28d0-4c73-8de4-b64a23edf7a8' then 'Maschen statt naschen'
              WHEN ${group_id_new} = 'ca232bce-71cf-4f8b-a634-fa17da1cfec9' then 'Fashionistas'
              WHEN ${group_id_new} = '47a2f052-174f-4f1c-810a-02017d3eeff4' then 'En stabilisation'
              WHEN ${group_id_new} = '2d1adf78-acf5-4820-8607-0dc647b01480' then 'Gratidão'
              WHEN ${group_id_new} = '2507eb10-9d56-497f-9926-33e0dab8b698' then 'Autocompaixão'
              WHEN ${group_id_new} = '99a3930e-7062-4256-8a54-210ed4a1e74f' then 'Self-Compassion'
              WHEN ${group_id_new} = '74d95b92-9dc2-4bc5-ac6c-d5bbfcaed281' then 'New to Activity'
              WHEN ${group_id_new} = 'eb56eb99-b035-48f8-8cc9-2d49465f10a2' then 'Gratitude'
              WHEN ${group_id_new} = '45f7ec26-605d-409c-97af-7e61e6badebc' then 'Cardio'
              WHEN ${group_id_new} = '7f125194-14ec-411b-9369-5116a82ace3b' then 'Jardinage'
              WHEN ${group_id_new} = '91a42458-8566-4179-9d2b-fbf990073469' then 'Mindfulness'
              WHEN ${group_id_new} = 'a13032ed-9f91-4a83-9dea-79c69a5b8968' then 'Always Improving'
              WHEN ${group_id_new} = '0058ad3b-06cd-4758-9dd4-0e886a092ded' then 'New to Activity'
              WHEN ${group_id_new} = 'de1f3f0b-0bc8-4d39-a6ad-5a5a8b98e42e' then 'Meditation'
              WHEN ${group_id_new} = '1bc9de2f-3e06-41e0-9750-76dc963b240c' then 'Eu amo viajar'
              WHEN ${group_id_new} = 'a2671644-cc94-499c-85cd-d14870aad0ea' then 'Se remettre sur la bonne voie'
              WHEN ${group_id_new} = '21bfc85a-3f73-4ab1-abcc-4eed2b1d7864' then 'Gratitude'
              WHEN ${group_id_new} = '8c53d9a2-2467-4cb9-8a14-1296085fcaf7' then 'Academia'
              WHEN ${group_id_new} = '1f769abf-a08e-4151-b0c8-1d94277b6130' then 'New to Activity'
              WHEN ${group_id_new} = '0df55cfc-bdc1-4e4b-95a6-15059b6988aa' then 'Mindfulness'
              WHEN ${group_id_new} = 'bc3f5620-94c2-49b6-b1bb-1264a8c962a9' then 'Mindfulness'
              WHEN ${group_id_new} = 'ae8bbdd0-0d0f-4aba-9f79-68757749db59' then 'Hitta glädje'
              WHEN ${group_id_new} = 'aaf38e1e-91b1-4d34-95ae-54c2f36e13ff' then 'Caminhada'
              WHEN ${group_id_new} = 'd08b1005-7ca2-408e-af8c-29d134662636' then 'Glúten Free'
              WHEN ${group_id_new} = 'f2e33ee6-094d-4ebd-abff-fe23814c93a4' then 'PontosFit'
              WHEN ${group_id_new} = '64911e21-6265-431f-96ce-0213f5638132' then 'Mindfullness'
              WHEN ${group_id_new} = 'abd62f2a-fd78-4306-bee3-77af12c96a2d' then 'Step Trackers'
              WHEN ${group_id_new} = '7d423e33-77cb-4159-bd3a-d3a8f9a9e1cb' then 'My Why'
              WHEN ${group_id_new} = '20950dfa-4c09-46a6-8cc2-e3d7f86e98b8' then 'Gratitude'
              WHEN ${group_id_new} = '68d621f2-8f20-40f7-9d89-b00e0a64ee76' then 'Mindfulness'
              WHEN ${group_id_new} = '447fac0b-0b11-4e44-878c-1c4904dfa68b' then '60+'
              WHEN ${group_id_new} = '6055d6ef-2ff9-4593-ab4a-5c009ed1b015' then 'Nurses of WW'
              WHEN ${group_id_new} = '64bf8f32-d376-4127-9d8c-c9d3571cc2bd' then '5K Prep'
              WHEN ${group_id_new} = '4b30b70b-1e43-4fb6-8bc4-0fadc0f3595b' then 'Crafts'
              WHEN ${group_id_new} = 'ace452e4-a08b-4caf-88f7-68742b42e132' then 'Instant Pot Lovers'
              WHEN ${group_id_new} = '4b9eff42-75e6-4090-bcec-d2c5050041bb' then 'Tennis'
              WHEN ${group_id_new} = '6883d2b8-4e38-488b-b481-cf1fe19fbba0' then 'Wine Lovers'
              WHEN ${group_id_new} = 'd6324a08-11b9-4eb2-90ae-a4a8dd5ec9b2' then 'Brides'
              WHEN ${group_id_new} = 'c75277c6-abf5-47dc-bdd5-2d6a3d117523' then '70s Plus'
              WHEN ${group_id_new} = 'e9141ed5-a6b7-45f1-b7e6-6ccab193f6ec' then 'Aaptiv Lovers'
              WHEN ${group_id_new} = 'b1d8cb1a-93bc-461d-81ba-9a7d33f6dd46' then 'Futurs mariés'
              WHEN ${group_id_new} = '220f0bca-3307-4e90-b635-3e04de2128a5' then 'Kosher'
              WHEN ${group_id_new} = '2298d494-68c8-4ace-9de8-d07c24c711dc' then 'Then and Now'
              WHEN ${group_id_new} = 'ec1cc3ea-6b84-43e1-91f7-3e702fcac2db' then 'Hommes'
              WHEN ${group_id_new} = '80e2fd5a-836f-4b01-acda-cf258bd316a6' then 'Pilates'
              WHEN ${group_id_new} = '32e40f54-8c2d-4198-9b5d-e4309267a1a2' then 'Skiing'
              WHEN ${group_id_new} = '3751fa15-639e-4e2d-9e4a-b04433014d4c' then 'LGBTQ+'
              WHEN ${group_id_new} = '763c19e3-8c4c-4882-ae42-69807de33322' then 'Cooking for 1'
              WHEN ${group_id_new} = '9e9ca186-36d4-43c8-968e-ba49c42ed00f' then 'Stay-at-Home Parents'
              WHEN ${group_id_new} = 'c2f79559-7f49-4f0b-9ae1-7c7d02e7df78' then 'In My 60s'
              WHEN ${group_id_new} = '7d3c5420-a985-406a-b991-4de26623913d' then 'Club des tortues'
              WHEN ${group_id_new} = 'f469124e-f31c-4261-9b9b-746709065e43' then 'Pfundsgruppe'
              WHEN ${group_id_new} = '7c4cc791-37c2-42e5-a7e4-ab8286443d60' then 'Rezepte'
              WHEN ${group_id_new} = 'b323b46b-3df4-48db-8443-aaf1cdd6bdde' then '(K)eine Frage des Alters'
              WHEN ${group_id_new} = '5cbf129e-3e1c-409c-8b37-353e6a2a695e' then '10 lb club'
              WHEN ${group_id_new} = 'd810a00b-e436-4ba5-a201-64237ddff5d3' then 'In My 50s'
              WHEN ${group_id_new} = '355ca630-cac2-44aa-b015-ab5b914dfa79' then 'Mamas unter sich'
              WHEN ${group_id_new} = '868b313c-379e-45d8-9066-c2b14b48db66' then 'Nouveaux'
              WHEN ${group_id_new} = 'ef1dbeb0-8ff2-4b3b-87fa-48a97fe0c6f2' then '100+ lb club'
              WHEN ${group_id_new} = '11576244-e8bf-4302-9569-67055857c4ba' then 'Végétarien'
              WHEN ${group_id_new} = 'b5814e8a-e423-45d1-b37e-a405e6865452' then 'Neu hier'
              WHEN ${group_id_new} = 'bf3bd975-1c76-457d-a63a-d15aa39f3ab6' then 'Vegans'
              WHEN ${group_id_new} = '0a14dde6-402f-4bfa-91d3-ca8274b0f201' then 'In My 20s'
              WHEN ${group_id_new} = '32c0c675-aa54-422d-b973-fa6a6fa90260' then 'Running'
              WHEN ${group_id_new} = 'cb6972a3-8c36-49d5-bdab-afc3bc55e230' then 'Recipes'
              WHEN ${group_id_new} = '03849453-b810-4acb-9d38-573549c7f88a' then 'Turtle Club'
              WHEN ${group_id_new} = '0e0d0164-6e2d-4c9f-850a-eea25063aa34' then 'Meal Prep'
              WHEN ${group_id_new} = '10bbd814-6132-4293-af82-bcfe4f21cb88' then 'Gluten Free'
              WHEN ${group_id_new} = '9d62112f-c794-4a3c-9474-6278a669e04e' then '25 lb club'
              WHEN ${group_id_new} = 'd4782fdb-36ad-4587-857a-1cea847a4848' then 'Foodies'
              WHEN ${group_id_new} = 'ef6e3b74-965c-485f-9194-d638ce6bda25' then 'In My 40s'
              WHEN ${group_id_new} = '81675bab-5a08-4afa-b6dd-265813ade60f' then 'Recipes'
              WHEN ${group_id_new} = '4dadf0b0-3dc9-4cd3-9576-b52b82248663' then 'Meal Prep'
              WHEN ${group_id_new} = '322ebe16-a251-4089-8443-d5d00ca0fdec' then 'Living with Pets'
              WHEN ${group_id_new} = 'edade505-35fa-4f32-af17-b9ed75fb8c6f' then 'Motivé'
              WHEN ${group_id_new} = '7f56e262-b062-4729-b99b-634b7edd7113' then 'Newbies'
              WHEN ${group_id_new} = '39bbf1de-655c-44df-804f-ceba729ee043' then 'Vegetarian'
              WHEN ${group_id_new} = '70bc7079-0a72-4342-b58f-9f7cad55fd4a' then 'Durchstarten'
              WHEN ${group_id_new} = '475e530a-fa02-4b2a-82d6-e7f8263e0500' then '50 lb club'
              WHEN ${group_id_new} = '2e0c2b51-0aa0-449f-930f-dd0971cec3db' then 'Yoga'
              WHEN ${group_id_new} = '6ebd0b30-c782-402e-b40b-f49acf8a598d' then 'In my 20s'
              WHEN ${group_id_new} = '3693fb03-7b38-4e40-aab0-18cff786bcc5' then 'In my 30s'
              WHEN ${group_id_new} =  '4bec5a1a-2e0b-49f5-a652-972d60714503' then 'Menu Prep'
              WHEN ${group_id_new} =  '635f37fb-54b4-402f-adae-349784bb5a06' then 'Book Club'
              WHEN ${group_id_new} =  '6cfb4ff8-63f0-4317-88ed-b40bf7d787e4' then 'Crafty Corner'
              WHEN ${group_id_new} =  '7e3d26a7-821f-4712-8f88-43bd5adddede' then 'Mums and Dads'
              WHEN ${group_id_new} =  '9153474f-6e7f-4369-b7e4-b530b9a930cd' then 'Running'
              WHEN ${group_id_new} =  '9719900f-fce9-485c-9c1e-5da7162c42a6' then 'In my 30s'
              WHEN ${group_id_new} =  '21968ac7-336f-44b2-a522-292f4d091117' then 'Foodies'
              WHEN ${group_id_new} =  '8b17ae2f-86b9-4f02-9241-f47fb317ac56' then 'Vélo'
              WHEN ${group_id_new} =  '453a250f-801a-4e4f-b51f-b6eab0c4f7fb' then 'Futurs mariés'
              WHEN ${group_id_new} =  'de1f3f0b-0bc8-4d39-a6ad-5a5a8b98e42e' then 'Meditation'
              WHEN ${group_id_new} =  'a2aed4a4-263e-43ec-ae29-c45408add273' then 'Les hommes WW'
              WHEN ${group_id_new} =  '68cdf35f-8550-4e1d-92f6-94908276f25b' then 'En pleine conscience'
              WHEN ${group_id_new} =  '6e2962aa-9e5d-4f56-b7fc-01e45411c469' then 'Végétaliens'
              WHEN ${group_id_new} =  'baa4d146-ec95-4a5d-910a-e1d954eaa8a9' then 'Étudiants WW'
              WHEN ${group_id_new} =  '8d7258a7-c712-4a76-b28f-baec9d8fead6' then 'Club de lecture'
              WHEN ${group_id_new} =  '95acbd0c-8dc5-459d-abba-f1cda62ac13b' then 'Manutenção'
              WHEN ${group_id_new} =  '3fea7df3-b30a-4c26-953b-05e2b5feb977' then 'Gym'
              WHEN ${group_id_new} =  '551db6e4-405b-40a0-92a9-d99e450b8e09' then 'Voyager'
              WHEN ${group_id_new} =  'abdf508c-1a31-4d09-add3-58be0b4f0b15' then 'Hommes'
              WHEN ${group_id_new} =  'e74376b3-f68f-4b64-ab5f-01423a3ad3b4' then 'Avós'
              WHEN ${group_id_new} =  'b93432de-6017-466a-89b5-56000ecda564' then 'Noivas & Noivos'
              WHEN ${group_id_new} =  '9703e166-4fe5-433f-a0cd-08c9e459d408' then 'Tuinieren'
              WHEN ${group_id_new} =  '4022ed1d-4fd5-4ffd-8195-3affffe63aee' then 'Reizen'
              WHEN ${group_id_new} =  '25e630b2-dcde-4bdd-84b3-884f26750441' then 'Gars WW'
              WHEN ${group_id_new} =  'b42edd7e-d18a-409f-8661-19c1e4770119' then 'Devagar e sempre'
              WHEN ${group_id_new} =  'b98e0f2e-cffc-460d-8a9d-b013be61a416' then 'Course à pied'
              WHEN ${group_id_new} =  '1037b908-032c-4362-9fe0-6ad2caa58346' then 'Garten'
              WHEN ${group_id_new} =  'b5d11202-cd08-415f-a735-99fbf9455f30' then 'Lire'
              WHEN ${group_id_new} =  'b6ba453e-bd40-4e53-82aa-5095dd4c87a5' then 'Amamentando'
              WHEN ${group_id_new} =  '58e56300-45de-4e06-bc9a-abfccaf63b53' then 'Pets'
              WHEN ${group_id_new} =  '8e970dd2-59e3-4cab-8024-66b26a5ea9fd' then 'Végétalien'
              WHEN ${group_id_new} =  '0a529775-9318-4ebf-9b86-feb620b068c7' then 'Fitness'
              WHEN ${group_id_new} =  '2f3b18d7-ab50-49a1-ab5f-aa2b20100af2' then 'Mon histoire'
              WHEN ${group_id_new} =  '4619e313-4fc7-460b-99f1-11dd417bde3c' then 'Mindfulness'
              WHEN ${group_id_new} =  '718d1e95-84b4-4d04-8832-a5b0c94d1eff' then 'Fietsen'
              WHEN ${group_id_new} =  '617e65ae-9881-4ed6-96ad-b15516266b17' then 'Kitchen Novices'
              WHEN ${group_id_new} =  'ab9abd11-d1ce-4531-9511-1bb815e9612e' then '1 Year In'
              WHEN ${group_id_new} =  '76cdcbf3-e8e1-4cf6-94fa-81e3dcbf321a' then 'Meal preppen'
              WHEN ${group_id_new} =  '6a385303-75dd-4082-866d-39d1dddb5dde' then 'Goal Setting'
              WHEN ${group_id_new} =  '72062975-0bf5-483b-9397-cb2c05253eed' then 'Goal Setting'
              WHEN ${group_id_new} =  '068e786c-3328-4c06-ba0b-ceafbfd2bb37' then 'Get Back on Track'
              WHEN ${group_id_new} =  'b7d79c1a-8213-4d57-af1d-773b56c9d8c3' then 'WW on the road'
              WHEN ${group_id_new} =  'ae63367b-41b8-490d-8f02-f43450acccae' then 'Hiking'
              WHEN ${group_id_new} =  '5cc9e4e8-c83f-4f3e-868b-7d6ed5e20995' then 'Vegetarisch'
              WHEN ${group_id_new} =  '9748291f-2dfd-47c8-bc59-8ab55bbcc13a' then 'Family friendly foodies'
              WHEN ${group_id_new} =  '6ed5e4cc-f523-4699-95ed-84e37e7534fa' then 'Dairy Free'
              WHEN ${group_id_new} = '7398a634-723c-454d-ab68-953e72ea30e4' then 'Newbies'
              WHEN ${group_id_new} = '21968ac7-336f-44b2-a522-292f4d091117' then 'Foodies'
              WHEN ${group_id_new} = 'c0484f1c-6602-4a84-986e-1669eae60125' then 'Grandparents'
              WHEN ${group_id_new} = '86f69da3-092a-4b7a-bd77-44459b818d22' then 'Crossfit Enthusiasts'
              WHEN ${group_id_new} = '563dd7a2-6bf6-41a4-ad5d-89a4d86a67a1' then 'Courir'
              when ${group_id_new} = 'd32853ef-fb31-4480-ba7f-605fab8e3329' then 'Get Back on Track'
              when ${group_id_new} = '4cee7bb6-c212-4997-af4f-feceb8c49ef8' then 'Meal Prep'
              when ${group_id_new} = '77d61645-d54f-476d-b2d9-75ee51cb7bb7' then 'Book Lovers'
              when ${group_id_new} = '8979c120-f06a-4f78-835f-d2f834bc6f0a' then 'Mannen'
              when ${group_id_new} = 'b460d2bc-62f8-4625-8344-70abe47acf21' then 'Studenten'
              when ${group_id_new} = 'bb9b3c0c-a4a9-4092-b7f7-b458f7933273' then 'Opnieuw beginnen'
              when ${group_id_new} = '1f0e2e07-d3df-489d-b9b2-ed93dd4b4fba' then 'Préparation de repas'
              when ${group_id_new} = '37f3365f-d4a8-43f9-ac9e-1ae3f0d4ac91' then 'Students'
              when ${group_id_new} = 'baa4d146-ec95-4a5d-910a-e1d954eaa8a9' then 'Étudiants WW'
              when ${group_id_new} = '80a331b5-2696-4eb9-bd9d-c722ac61af81' then 'Huisdieren'
              when ${group_id_new} = '4f45b5d2-092e-492b-aff2-a9209e616980' then 'Here for Health'
              when ${group_id_new} = '1018889a-9b00-442a-8443-24f85a6cf85c' then 'Sportschool'
              when ${group_id_new} = 'a625537b-e779-4a1c-831d-25ce3817c655' then 'Für die ganze Familie'
              WHEN ${group_id_new} = 'c128b21c-753f-4807-95f2-af661eff9138' THEN 'Meine Motivation'
              WHEN ${group_id_new} = 'fdc3424b-f0d5-4194-b4ba-68cb8e18b105' THEN 'Glutenfrei'
              WHEN ${group_id_new} = '4bd07f76-1a54-4e2a-be45-47281cd0a7ff' THEN 'Endspurt'
              WHEN ${group_id_new} = '45cc51cc-2412-489e-a2b5-38a3057da3cb' THEN 'Erhaltung'
              WHEN ${group_id_new} = '589f6f9b-d05d-4718-bf66-10f7a5f2d56a' THEN 'Hålla vikten'
              WHEN ${group_id_new} = 'b20e0c36-eb7c-4fbf-9ee8-c946a2207a4b' THEN 'Tiere'
              WHEN ${group_id_new} = 'f2abc75c-2f43-491b-8027-a984f3028de8' THEN 'Amis des animaux'
              WHEN ${group_id_new} = '1627767d-2d94-4714-8afe-c89964893d9c' THEN 'Loisirs créatifs'
              WHEN ${group_id_new} = '1810c72e-f945-4317-bcb9-f00b4f30d455' THEN 'Yoga'
              WHEN ${group_id_new} = '85d65a9f-0119-43e3-ad53-2edf53352ba5' THEN 'Foodhacks'
              WHEN ${group_id_new} = '2a7e1993-e0f4-487a-bcac-666d8def707a' THEN 'Blau ist das Ziel'
              WHEN ${group_id_new} = '30738689-739e-4367-8d3f-149980c44e10' THEN 'Corrida'
              WHEN ${group_id_new} = '3cf71a6a-6275-4899-83a7-c790b479a12b' THEN 'Zen'
              WHEN ${group_id_new} = '2faea726-d0fc-42d5-9443-335624ab428f' THEN 'Mitt varför'
              WHEN ${group_id_new} = 'ec3167e7-25f4-4b4a-8e05-1d9de0379a15' THEN 'Passionnés de cuisine'
              WHEN ${group_id_new} =  '14ab4f5e-4cc1-4aed-aee4-21e065d4b3a2' then 'In my 20s'
              WHEN ${group_id_new} =  '7c7735a9-bc8a-4761-b764-01a5d81e5f03' then 'Pour les mamans'
              WHEN ${group_id_new} =  '3c3d9f7c-9e0f-449d-9067-ae436581fe02' then 'Wandelen'
              WHEN ${group_id_new} =  'eb10dbe9-898b-4c4d-b398-ef35f2bea259' then 'Mijn verhaal'
              when ${group_id_new} = '89638b22-d0f0-4f8b-bbb1-e61bbb8d9c1e' then 'Stabiliser'
              when ${group_id_new} = 'd05b4824-c3a6-4291-ba71-a423c5d8f2d8' then 'Nouvelles mamans'
              when ${group_id_new} = '26ac535a-cfc2-4e7a-a7d5-d469d4fadc98' then 'Vardagspusslet'
              when ${group_id_new} = 'c4551f83-267a-406a-9910-5fbd9f1f2109' then 'Créativité'
              when ${group_id_new} = '33716424-afc4-48ba-a1b0-67b3364f99c1' then 'Étudiants'
              when ${group_id_new} = '8fd0cf8f-7080-4b8d-be23-fb12d1311c75' then 'Low Carb'
              when ${group_id_new} = '7d423e33-77cb-4159-bd3a-d3a8f9a9e1cb' then 'My Why'
              when ${group_id_new} = '8c53d9a2-2467-4cb9-8a14-1296085fcaf7' then 'Academia'
              when ${group_id_new} = 'a2671644-cc94-499c-85cd-d14870aad0ea' then 'Se remettre sur la bonne voie'
              when ${group_id_new} = '7f125194-14ec-411b-9369-5116a82ace3b' then 'Jardinage'
              when ${group_id_new} = 'e9145864-d124-4720-8b13-859018ded2f1' then 'Achtsamkeit'
              when ${group_id_new} = '718d1e95-84b4-4d04-8832-a5b0c94d1eff' then 'Fietsen'
              ELSE ${group_id_new}
              END) ;;
}


dimension: connect_commenters {
  sql: regexp_contains(${eventAction},  'connect_comment|connect_reply_to_member|add-comment$') ;;
  type: yesno
}

dimension: myday_iaf {
  sql: ${eventAction} = 'iaf_my_day_card' ;;
  type: yesno
}

dimension: chat_with_coach {
  sql: ${eventAction} = 'resources_chat_with_a_coach_clicked' ;;
  type: yesno
}

dimension:profile_mtgfinderweb {
    sql: ${eventAction} = 'profile_mtgfinderweb' ;;
    type: yesno
  }
  dimension: personal_coaching {
    sql: ${eventAction} = 'resources_personal_coaching_clicked' ;;
    type: yesno
  }

  dimension: more_resources {
    sql: ${eventAction} = 'resources_more_resources_clicked' ;;
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

dimension: close_myday_weightcard {
  sql: ${eventAction}= 'close_myday_weightcard' ;;
  type: yesno
}

  dimension: mini_post_x {
    sql: ${eventAction}= 'connect_mini_post_x' ;;
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

dimension: feed_fast_follow {
  sql: ${eventAction} = 'connect_member_fast_follow' ;;
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

  dimension: weight_mydaycard {
    sql:  ${eventAction} = 'track_weight_mydaycard' ;;
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


  dimension: headspace_card_name {
    sql: case when ${eventAction} in ('food_card_mindset','headspace') then 'Headspace'
    when (${eventAction} in ('food_card_mindset_Basics', 'food_card_mindsetBasics', 'food_card_mindset_Grunderna', 'food_card_mindsetGrunderna', 'food_card_mindsetBasis', 'food_card_mindset_Basis', 'food_card_mindset_Einfache_Atemübung', 'food_card_mindset_Einfache_Atem_bung', 'food_card_mindset_Les_bases', 'food_card_mindset_Notions_de_base',
    'food_card_mindset_Base') or (${eventAction} = 'meditation' and ${eventLabel} in ('Basics', 'Les_bases', 'Grunderna', 'Basis',
    'Notions_de_base', 'Base'))) then 'Basics'
    when  (${eventAction} in ('food_card_mindset_intro', 'food_card_mindset_Changing_Perspectives', 'food_card_mindset_Nya_perspektiv', 'food_card_mindset_Veranderende_perspecti', 'food_card_mindset_Perspectives_changeant', 'food_card_mindset_Perspektiven__ndern', 'food_card_mindset_Changez_de_perspective', 'food_card_mindset_Perspectives_changeant', 'food_card_mindset_Changer_de_perspective', 'food_card_mindset_featured_Changing_Pers', 'food_card_mindset_featured_Changing_Per', 'food_card_mindset_featured_Perspektiven', 'food_card_mindset_featured_Perspektiven_', 'food_card_mindset_featured_Changez_de_pe', 'food_card_mindset_featured_Changez_de_p',
    'food_card_mindset_featured_Nya_perspekti', 'food_card_mindset_featured_Veranderende_', 'food_card_mindset_featured_Veranderende', 'food_card_mindset_featured_Perspectives_', 'food_card_mindset_featured_Perspectives', 'food_card_mindset_featured_Nya_perspekt', 'food_card_mindset_featured_Changer_de_pe',
    'food_card_mindset_featured_Changer_de_p') or (${eventAction} = 'meditation' and ${eventLabel} in ('Changing_Perspectives', 'Changing_perspectives', 'Perspektiven__ndern', 'Changez_de_perspective', 'Perspectives_changeantes',
    'Nya_perspektiv', 'Changer_de_perspectives', 'Nouvelles_perspectives', 'Nieuwe_inzichten')))  then 'Changing Perspectives'
    when  (${eventAction} in ('food_card_mindsetTake_a_Moment_to_Pause', 'food_card_mindset_Take_a_Moment_to_Pause', 'food_card_mindset_Unna_dig_en_paus', 'food_card_mindsetUnna_dig_en_paus', 'food_card_mindsetNeem_een_moment_om_te_', 'food_card_mindset_Neem_een_moment_om_te_', 'food_card_mindset_Du_fühlst_dich_überf', 'food_card_mindset_Accordez_vous_une_paus', 'food_card_mindset_Du_fühlst_dich_überfo', 'food_card_mindset_Du_f_hlst_dich__berfor', 'food_card_mindset_Prenez_un_moment_pour', 'food_card_mindset_Prenez_un_moment_pour_', 'food_card_mindset_Prends_un_moment_pour', 'food_card_mindset_Prends_un_moment_pour_', 'food_card_mindset_Prenez_le_temps_d_une',
    'food_card_mindset_Prenez_le_temps_d_une_') or (${eventAction} = 'meditation' and ${eventLabel} in ('Take_a_Moment_to_Pause', 'Nimm_dir_einen_Moment_f_r_eine_Pause', 'Neem_een_moment_om_te_pauzeren', 'Unna_dig_en_paus', 'Prends_un_moment_pour_faire_une_pause',
    'Accordez_vous_une_pause', 'Prenez_un_moment_pour_faire_une_pause', 'Einfache_Atem_Technik')))then 'Take a Moment to Pause'
    when  (${eventAction} in ('food_card_mindsetEnd_of_Day', 'food_card_mindset_End_of_Day', 'food_card_mindset_Slut_p__dagen', 'food_card_mindsetSlut_på_dagen', 'food_card_mindsetEinde_van_de_dag', 'food_card_mindset_Einde_van_de_dag', 'food_card_mindset_Fin_de_la_journ_e', 'food_card_mindset_Entspannen_am_Abend', 'food_card_mindset_Fin_de_la_journée', 'food_card_mindset_Fin_de_journée',
    'food_card_mindset_Fin_de_journ_e') or (${eventAction} = 'meditation' and ${eventLabel} in ('End_of_Day', 'Fin_de_la_journ_e', 'Slut_p__dagen', 'Fin_de_journ_e',
    'Einde_van_de_dag', 'Entspannen_am_Abend'))) then 'End of Day'
when  (${eventAction} in ('food_card_mindsetEngage_your_Senses_whe', 'food_card_mindset_Engage_your_Senses_whe', 'food_card_mindset_Engage_your_Senses_wh', 'food_card_mindset_Engagera_dina_sinnen_n', 'food_card_mindsetEngagera_dina_sinnen_n', 'food_card_mindsetBetrek_je_zintuigen_ti', 'food_card_mindset_Achtsam_Essen', 'food_card_mindset_Eveillez_vos_sens_lors', 'food_card_mindset_Impliquez_vos_sens_qua', 'food_card_mindset_Achtsames_Essen', 'food_card_mindset_Eveillez_vos_sens_lor', 'food_card_mindset_Eveille_tes_sens_en_m', 'food_card_mindset_Eveille_tes_sens_en_ma', 'food_card_mindset_Impliquez_vos_sens_qu',
'food_card_mindset_Betrek_je_zintuigen_ti') or (${eventAction} = 'meditation' and ${eventLabel} in ('Engage_your_Senses_when_Eating', 'Achtsames_Essen', 'Eveillez_vos_sens_lorsque_vous_mangez', 'Betrek_je_zintuigen_tijdens_het_eten', 'Impliquez_vos_sens_quand_vous_mangez', 'Eveille_tes_sens_en_mangeant',
'Engagera_dina_sinnen_n_r_du__ter')))then 'Engage Your Senses When Eating'
when  ${eventAction} in ('food_card_mindset_featured_Accepting_the', 'food_card_mindset_featured_Accepting_th', 'food_card_mindset_featured_Gedanken_akze', 'food_card_mindset_featured_Gedanken_akz', 'food_card_mindset_featured_Accepter_ses_', 'food_card_mindset_featured_Accepter_ses', 'food_card_mindset_Accepting_the_Mind', 'food_card_mindset_Accepter_ses_pens_es', 'food_card_mindset_Gedanken_akzeptieren', 'food_card_mindset_Accepter_ses_pens_es', 'food_card_mindset_Gedanken_akzeptieren',
'food_card_mindset_Accepter_ses_pens_es') then 'Accepting the Mind'
when  (${eventAction} in ('food_card_mindset_Walking_in_Your_Home', 'food_card_mindset_Walking_in_your_home', 'food_card_mindset_Achtsames_Gehen', 'food_card_mindset_Marchez_dans_votre_mai',
'food_card_mindset_Marcher_en_toute_con') or (${eventAction} = 'meditation' and ${eventLabel} in ('Achtsames_Gehen'))) then 'Walking in Your Home'
when  ${eventAction} in ('food_card_mindset_Refresh_Meditation', 'food_card_mindset_Refresh_Meditatio', 'food_card_mindset_Deine_Auszeit',
'food_card_mindset_Relaxation') then 'Refresh'
when (${eventAction} in ('food_card_mindset_Focus_Meditation', 'food_card_mindset_Focus_meditation', 'food_card_mindset_Fokus_Meditation', 'food_card_mindset_Fokuserad_meditat', 'food_card_mindset_Fokuserad_meditation', 'food_card_mindset_Focus_op_meditati', 'food_card_mindset_Focus_op_meditatie', 'food_card_mindset_Focus_sur_la_m_di',
'food_card_mindset_Focus_sur_la_m_ditatio') or (${eventAction} = 'meditation' and ${eventLabel} in ('Focus', 'Fokuserad', 'Concentrer', 'Concentration'))) then 'Focus'
when  ${eventAction} in ('food_card_mindset_Monkey_Mind', 'food_card_mindset_Fokus_Meditation', 'food_card_mindset_Fokuserad_meditat', 'food_card_mindset_Je_geest_trainen', 'food_card_mindset_Trainier_deinen_G', 'food_card_mindset_Trainier_deinen_Geist', 'food_card_mindset_Entra_nez_votre_e', 'food_card_mindset_Entra_ne_ton_espr', 'food_card_mindset_Entra_nez_votre_esprit', 'food_card_mindset_Entra_ne_ton_esprit', 'food_card_mindset_Apprivoisez_l_esp', 'food_card_mindset_Apprivoisez_l_esprit_d',
'food_card_mindset_Exercer_son_menta') then 'Monkey Mind'
when  (${eventAction} in ('food_card_mindset_Take_a_Break', 'food_card_mindset_Neem_even_pauze', 'food_card_mindset_Mach_mal_Pause', 'food_card_mindset_Faites_une_pause', 'food_card_mindset_Prenez_une_pause', 'food_card_mindset_Prends_toi_une_pa',
'food_card_mindset_Prends_toi_une_pause') or (${eventAction} = 'meditation' and ${eventLabel} in ('Prenez_le_temps_d_une_pause'))) then 'Take a Break'
when (${eventAction} = 'meditation' and ${eventLabel} in ('Walk_at_Home_or_Anywhere', 'Walk_at_home_or_anywhere', 'Ta_en_promenad', 'Bewust_wandelen__thuis_of_ergens_anders', 'Marcher_en_toute_conscience',
'Marchez_chez_vous___ou_n_importe_o_')) then 'Walk at Home or Anywhere'
when (${eventAction} = 'meditation' and ${eventLabel} in ('Appreciate_Cooking', 'Appreciate_cooking', 'Achtsames_Kochen', 'Uppskatta_matlagning', 'Bewust_koken',
'Appr_ciez__vraiment__la_cuisine', 'Manger_en_toute_conscience'))
then 'Appreciate Cooking'
when (${eventAction} = 'meditation' and ${eventLabel} in ('Ta_en_promenad', 'Walk_in_your_neighborhood', 'Walk_in_your_neighbourhood', 'Wandelen_in_je_buurt', 'Dreh_eine_Runde_um_den_Block', 'Marchez_dans_votre_quartier',
'Faites_une_promenade_dans_le_voisinage', 'Faites_une_promenade_dans_le_voisinage')) then 'Walk in Your Neighborhood'
when (${eventAction} = 'meditation' and ${eventLabel} in ('Release_and_restore', 'release_and_restore', 'Sl_pp_tag_och__terst_ll', 'Ontspannen_en_batterij_weer_opladen', 'Loslassen_und_st_rken', 'Relaxez_vous_et_rechargez_vos_batteries',
'Lib_rez_et_ressourcez', 'Rel_cher_et_r_cup_rer')) then 'Release & Restore'
when (${eventAction} = 'meditation' and ${eventLabel} in ('Sleep_music', 'sleep_music', 'Avslappningsmusik', 'Muziek_in_slaap_te_vallen', 'Einschlaf_Musik', 'Musique_pour_dormir', 'Musique_propice_au_sommeil',
'S_endormir_en_musique')) then 'Sleep Music'




    else 'Other' end
              ;;
    suggestions: [ "Headspace", "Basics", "Changing Perspectives", "Take a Moment to Pause", "End of Day", "Engage Your Senses When Eating",
      "Accepting the Mind", "Walking in Your Home", "Refresh", "Focus", "Monkey Mind", "Take a Break", "Walk at Home or Anywhere", "Appreciate Cooking", "Walk in Your Neighborhood", "Release & Restore", "Sleep Music"]
    }

  dimension: headspace_cards {
    sql: case when  ${headspace_card_name} in ("Basics", "Changing Perspectives", "Take a Moment to Pause", "End of Day", "Engage Your Senses When Eating",
      "Accepting the Mind", "Walking in Your Home", "Refresh", "Focus", "Monkey Mind", "Take a Break", "Walk at Home or Anywhere", "Appreciate Cooking" , "Walk in Your Neighborhood", "Release & Restore", "Sleep Music") then ${headspace_card_name}
        else null end
         ;;
    type: string

  }

  dimension: headspace_cards_yesno {
    sql:  ${headspace_card_name} in ("Basics", "Changing Perspectives", "Take a Moment to Pause", "End of Day", "Engage Your Senses When Eating",
      "Accepting the Mind", "Walking in Your Home", "Refresh", "Focus", "Monkey Mind", "Take a Break", "Walk at Home or Anywhere", "Appreciate Cooking" , "Walk in Your Neighborhood", "Release & Restore", "Sleep Music")

               ;;
    type: yesno

  }

  dimension: headspace {
    sql: case when  ${headspace_card_name} in ("Headspace") then ${headspace_card_name}
        else null end
         ;;
    type: string

  }

  dimension: headspace_yesno {
    sql:  ${headspace_card_name} in ("Headspace")

                     ;;
    type: yesno

  }


  dimension: headspace_action_card_name {
    sql: case when (${eventCategory} = ('mindset') and ${eventAction} = ('media_play')) then 'Played Meditation'
          when (${eventCategory} = ('mindset') and ${eventAction} = ('media_100')) then 'Completed Meditation'
 else 'Other' end
              ;;
    suggestions: [ "Played Meditation", "Completed Meditation"]
    }



  dimension: headspace_actions {
    sql: case when  ${headspace_action_card_name} in ("Played Meditation", "Completed Meditation") then ${headspace_action_card_name}
        else null end
         ;;
    type: string

  }

  dimension: headspace_actions_yesno {
    sql:  ${headspace_action_card_name} in ("Played Meditation", "Completed Meditation")

                           ;;
    type: yesno

  }


  dimension: headspace_play_card_name {
    sql: case when (${eventAction} = 'media_play' and ${eventLabel} in ('Appreciate_Cooking', 'Appreciate_cooking', 'Uppskatta_matlagning', 'Achtsames_Kochen', 'Bewust_koken', 'Appr_ciez__vraiment__la_cuisine',
    'Manger_en_toute_conscience')) then 'Appreciate Cooking: Media Play'
      when (${eventAction} = 'media_play' and ${eventLabel} in ('Basics', 'Grunderna', 'Basis', 'Les_bases', 'Notions_de_base',
      'Base')) then 'Basic: Media Play'
      when (${eventAction} = 'media_play' and ${eventLabel} in ('End_of_Day', 'Entspannen_am_Abend', 'Slut_p__dagen', 'Fin_de_la_journ_e', 'Einde_van_de_dag',
      'Fin_de_journ_e')) then 'End of Day: Media Play'
      when (${eventAction} = 'media_play' and ${eventLabel} in ('Eveillez_vos_sens_lorsque_vous_mangez', 'Achtsames_Essen'))
      then 'Engage Your Senses when Eating: Media Play'
      when (${eventAction} = 'media_play' and ${eventLabel} in ('Focus', 'Fokus', 'Fokuserad', 'Concentrer',
      'Concentration')) then 'Focus: Media Play'
      when (${eventAction} = 'media_play' and ${eventLabel} in ('Prenez_le_temps_d_une_pause')) then 'Take a Break: Media Play'
      when (${eventAction} = 'media_play' and ${eventLabel} in ('Einfache_Atem_Technik', 'Prenez_un_moment_pour_faire_une_pause', 'Nimm_dir_einen_Moment_f_r_eine_Pause',
      'Accordez_vous_une_pause')) then 'Take a Moment to Pause: Media Play'
      when (${eventAction} = 'media_play' and ${eventLabel} in ('Walk_at_Home_or_Anywhere', 'Walk_at_home_or_anywhere', 'Ta_en_promenad', 'Bewust_wandelen__thuis_of_ergens_anders', 'Marchez_chez_vous___ou_n_importe_o_',
      'Marcher_en_toute_conscience')) then 'Walk at Home or Anywhere: Media Play'
when (${eventAction} = 'media_play' and ${eventLabel} in ('Achtsames_Gehen')) then 'Walking in Your Home: Media Play'


when (${eventAction} = 'media_100' and ${eventLabel} in ('Achtsames_Kochen', 'Appr_ciez__vraiment__la_cuisine', 'Appreciate_Cooking', 'Appreciate_cooking', 'Bewust_koken', 'Manger_en_toute_conscience', 'Uppskatta_matlagning'))
then 'Appreciate Cooking: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Base', 'Basics', 'Basis', 'Grunderna', 'Les_bases', 'Notions_de_base')) then 'Basic: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Einde_van_de_dag', 'End_of_Day', 'Entspannen_am_Abend', 'Fin_de_journ_e', 'Fin_de_la_journ_e', 'Slut_p__dagen')) then 'End of Day: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Eveillez_vos_sens_lorsque_vous_mangez')) then 'Engage Your Senses when Eating: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Concentration', 'Concentrer', 'Focus', 'Fokus', 'Fokuserad')) then 'Focus: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Prenez_le_temps_d_une_pause')) then 'Take a Break: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Einfache_Atem_Technik', 'Prenez_un_moment_pour_faire_une_pause')) then 'Take a Moment to Pause: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Bewust_wandelen__thuis_of_ergens_anders', 'Marchez_chez_vous___ou_n_importe_o_', 'Ta_en_promenad', 'Walk_at_Home_or_Anywhere', 'Walk_at_home_or_anywhere'))
then 'Walk at Home or Anywhere: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Achtsames_Gehen')) then 'Walking in Your Home: Media 100'



 else 'Other' end
              ;;
    suggestions: ["Appreciate Cooking: Media Play", "Basic: Media Play", "End of Day: Media Play", "Engage Your Senses when Eating: Media Play", "Focus: Media Play", "Take a Break: Media Play", "Take a Moment to Pause: Media Play", "Walk at Home or Anywhere: Media Play",
      "Walking in Your Home: Media Play",
      "Appreciate Cooking: Media 100", "Basic: Media 100", "End of Day: Media 100", "Engage Your Senses when Eating: Media 100", "Focus: Media 100", "Take a Break: Media 100", "Take a Moment to Pause: Media 100", "Walk at Home or Anywhere: Media 100", "Walking in Your Home: Media 100"]
    }



  dimension: headspace_playcard_name {
    sql: case when  ${headspace_play_card_name} in ("Appreciate Cooking: Media Play", "Basic: Media Play", "End of Day: Media Play", "Engage Your Senses when Eating: Media Play", "Focus: Media Play", "Take a Break: Media Play", "Take a Moment to Pause: Media Play",
    "Walk at Home or Anywhere: Media Play", "Walking in Your Home: Media Play",
      "Appreciate Cooking: Media 100", "Basic: Media 100", "End of Day: Media 100", "Engage Your Senses when Eating: Media 100", "Focus: Media 100", "Take a Break: Media 100",
      "Take a Moment to Pause: Media 100", "Walk at Home or Anywhere: Media 100", "Walking in Your Home: Media 100") then ${headspace_play_card_name}
        else null end
         ;;
    type: string

  }

  dimension: headspace_playcard_name_yesno {
    sql:  ${headspace_play_card_name} in ("Appreciate Cooking: Media Play", "Basic: Media Play", "End of Day: Media Play", "Engage Your Senses when Eating: Media Play", "Focus: Media Play", "Take a Break: Media Play", "Take a Moment to Pause: Media Play",
    "Walk at Home or Anywhere: Media Play", "Walking in Your Home: Media Play",
      "Appreciate Cooking: Media 100", "Basic: Media 100", "End of Day: Media 100", "Engage Your Senses when Eating: Media 100", "Focus: Media 100", "Take a Break: Media 100", "Take a Moment to Pause: Media 100",
      "Walk at Home or Anywhere: Media 100", "Walking in Your Home: Media 100")

                           ;;
    type: yesno

}



  dimension: aaptiv_card_name {
    sql: case when ${eventAction} in ('activity_card_aaptiv','aaptivcard') then 'Aaptiv'
    when ${eventAction} = 'workout' and  (${eventLabel} = 'Start_walking' or ${eventLabel} = 'start_walking') then 'Start Walking'
    when (${eventAction} = 'workout' and  ${eventLabel} in ('Stretch_and_relax', 'stretch_and_relax')) then 'Stretch and Relax'
      when (${eventAction} = 'workout' and  ${eventLabel} in ('walk_to_the_music', 'Walk_to_the_music')) then 'Walk to the Music'
      when (${eventAction} = 'workout' and  ${eventLabel} in ('power_your_walk', 'Power_your_walk')) then 'Power Your Walk'
      when (${eventAction} = 'workout' and  ${eventLabel} in ('Ease_into_yoga', 'ease_into_yoga')) then 'Ease into Yoga'
      when (${eventAction} = 'workout' and  ${eventLabel} in ('find_your_strength', 'Find_your_strength')) then 'Find Your Strength'
     when (${eventAction} = 'workout' and  ${eventLabel} in ('run_to_the_beat', 'Run_to_the_beat')) then 'Run to the Beat'
when (${eventAction} = 'workout' and  ${eventLabel} in ('Build_stamina', 'build_stamina')) then 'Build Stamina'
when (${eventAction} = 'workout' and  ${eventLabel} in ('keep_on_moving', 'Keep_on_moving')) then 'Keep on Moving'
when (${eventAction} = 'workout' and  ${eventLabel} in ('find_your_speed', 'Find_your_speed')) then 'Find Your Speed'


      when (${eventAction} in ('activity_card_aaptiv_Start_getting_st_0', 'activity_card_aaptiv_Start_getting_stron', 'activity_card_aaptiv_Start_getting_', 'activity_card_aaptiv_Start_getting' , 'activity_card_aaptiv_Start_getting_stro',
      'activity_card_aaptiv_Commencer___de', 'activity_card_aaptiv_Commencer_à_d') or (${eventAction} = 'workout' and ${eventLabel} in ('Start_getting_stronger', 'Krafttraining_f_r_Einsteiger',
      'Commencer___devenir_plus_fort', 'Entra_nement_de_musculation_pour_d_butants')))  then 'Start Getting Stronger'
      when (${eventAction} in ('activity_card_aaptiv_Basic_walking_wo_0' , 'activity_card_aaptiv_Basic_walking_worko', 'activity_card_aaptiv_Basic_walking_work', 'activity_card_aaptiv_Basic_walking_work', 'activity_card_aaptiv_Basic_walking',
      'activity_card_aaptiv_Entra_nement_d') or (${eventAction} = 'workout' and ${eventLabel} in ('Basic_walking_workout', 'Entra_nement_de_base___la_marche', 'Walking_Workout_f_r_Einsteiger',
      'Entra_nement_de_jogging_pour_d_butants')))then 'Basic Walking'
      when (${eventAction} in ('activity_card_aaptiv_Walk_to_the_beat_0', 'activity_card_aaptiv_Walk_to_the_beat', 'activity_card_aaptiv_Walk_to_the_be', 'activity_card_aaptiv_Walk_to_the_b', 'activity_card_aaptiv_Marcher_en_ryt', 'activity_card_aaptiv_Marcher_en_ry', 'activity_card_aaptiv_Courir_en_mesu',
      'activity_card_aaptiv_Courir_en_mes') or (${eventAction} = 'workout' and  ${eventLabel} in ('Walk_to_the_beat', 'Marcher_en_rythme', 'Walking_im_Takt',
      'Courir_en_mesure'))) then 'Walk to the Beat'
      when (${eventAction} in ('activity_card_aaptiv_Pick_up_the_pace_0', 'activity_card_aaptiv_Pick_up_the_pace', 'activity_card_aaptiv_Pick_up_the_pa', 'activity_card_aaptiv_Pick_up_the_p', 'activity_card_aaptiv_Acc_l_rer_le_r', 'activity_card_aaptiv_Accélérer_le_',
      'activity_card_aaptiv_De_la_marche_a') or (${eventAction} = 'workout' and ${eventLabel} in ('Pick_up_the_pace', 'Acc_l_rer_le_rythme', 'Vom_Walken_zum_Joggen',
      'De_la_marche_au_jogging')))then 'Pick Up the Pace'
      when (${eventAction} in ('activity_card_aaptiv_Fast_and_total_t_0', 'activity_card_aaptiv_Fast_and_total_trai', 'activity_card_aaptiv_Fast_and_total_tra', 'activity_card_aaptiv_Fast_and_total', 'activity_card_aaptiv_Fast_and_tota', 'activity_card_aaptiv_Entra_nement_r',
      'activity_card_aaptiv_Entra_nement_c') or (${eventAction} = 'workout' or  ${eventLabel} in ('Fast_and_total_training', 'Entra_nement_rapide_et_total', 'HIT_Ganzk_rper_Workout',
      'Entra_nement_corporel_complet'))) then 'Fast and Total Training'
      when (${eventAction} in ('activity_card_aaptiv_Find_your_streng_0', 'activity_card_aaptiv_Find_your_strength', 'activity_card_aaptiv_Find_your_stre', 'activity_card_aaptiv_Find_your_str', 'activity_card_aaptiv_Trouvez_votre_', 'activity_card_aaptiv_Trouvez_votre',
      'activity_card_aaptiv_D_couvrez_votr') or (${eventAction} = 'workout' and ${eventLabel} in ('Find_your_strength', 'Trouvez_votre_point_fort', 'Entdecke_deine_Kraft',
      'D_couvrez_votre_force_physique', 'Trouve_ton_point_fort' )))then 'Find your Strength'
      when (${eventAction} in ('activity_card_aaptiv_Jog_run_interval_0', 'activity_card_aaptiv_Jog_run_intervals', 'activity_card_aaptiv_Jog_run_interv', 'activity_card_aaptiv_Jog_run_inter', 'activity_card_aaptiv_Intervalles_jo', 'activity_card_aaptiv_Intervalles_j',
      'activity_card_aaptiv_Entra_nement_f') or (${eventAction} = 'workout' and ${eventLabel} in ('Jog_run_intervals', 'Intervalltraining', 'Intervalles_jog_course',
      'Entra_nement_fractionn_')))then 'Jog/Run'
      when (${eventAction} in ('activity_card_aaptiv_Get_strong_faste_0', 'activity_card_aaptiv_Get_strong_faster', 'activity_card_aaptiv_Get_strong_fas', 'activity_card_aaptiv_Get_strong_fa', 'activity_card_aaptiv_Devenir_fort_', 'activity_card_aaptiv_Devenir_fort_p', 'activity_card_aaptiv_Circuit_d_entr',
      'activity_card_aaptiv_Circuit_d_ent') or (${eventAction} = 'workout' and  ${eventLabel} in ('Get_strong_faster', 'Devenir_fort_plus_rapidement', 'Kraft_Zirkeltraining',
      'Course_fractionn_e', 'Circuit_d_entra_nement___la_musculation'))) then 'Get Strong Faster'
      when (${eventAction} in ('activity_card_aaptiv_Cardio___strengt_0', 'activity_card_aaptiv_Cardio___strength', 'activity_card_aaptiv_Cardio___stren', 'activity_card_aaptiv_Cardio___stre', 'activity_card_aaptiv_Cardio___renfo', 'activity_card_aaptiv_Cardio___renf',
      'activity_card_aaptiv_Cardio___muscu') or (${eventAction} = 'workout' and  ${eventLabel} in ('Cardio___strength', 'Cardio___renforcement', 'Cardio___Kraft',
      'Cardio___muscu')))then 'Cardio + Strength'





     else 'Other' end
              ;;
    suggestions: [ "Aaptiv", "Start Getting Stronger", "Basic Walking", "Walk to the Beat", "Pick Up the Pace", "Fast and Total Training", "Find your Strength", "Jog/Run",
      "Get Strong Faster", "Cardio + Strength", "Start Walking", "Stretch and Relax", "Walk to the Music", "Power Your Walk", "Ease into Yoga", "Find Your Strength", "Run to the Beat", "Build Stamina", "Keep on Moving", "Find Your Speed"]
    }

  dimension: aaptiv_cards {
    sql: case when  ${aaptiv_card_name} in ( "Start Getting Stronger", "Basic Walking", "Walk to the Beat", "Pick Up the Pace", "Fast and Total Training", "Find your Strength", "Jog/Run",
      "Get Strong Faster", "Cardio + Strength", "Start Walking", "Stretch and Relax", "Walk to the Music", "Power Your Walk", "Ease into Yoga", "Find Your Strength", "Run to the Beat", "Build Stamina", "Keep on Moving", "Find Your Speed"
      ) then ${aaptiv_card_name}
        else null end
         ;;
    type: string

  }

  dimension: aaptiv_cards_yesno {
    sql:  ${aaptiv_card_name} in ("Start Getting Stronger", "Basic Walking", "Walk to the Beat", "Pick Up the Pace", "Fast and Total Training", "Find your Strength", "Jog/Run",
      "Get Strong Faster", "Cardio + Strength", "Start Walking", "Stretch and Relax", "Walk to the Music", "Power Your Walk", "Ease into Yoga", "Find Your Strength", "Run to the Beat", "Build Stamina", "Keep on Moving", "Find Your Speed"
      )

               ;;
    type: yesno

  }

  dimension: aaptiv {
    sql: case when  ${aaptiv_card_name} in ("Aaptiv") then ${aaptiv_card_name}
        else null end
         ;;
    type: string

  }

  dimension: aaptiv_yesno {
    sql:  ${aaptiv_card_name} in ("Aaptiv")

               ;;
    type: yesno

  }


  dimension: aaptiv_action_card_name {
    sql: case when (${eventCategory} = ('aaptiv') and ${eventAction} = ('media_play')) then 'Played Workout'
          when (${eventCategory} = ('aaptiv') and ${eventAction} = ('media_100')) then 'Completed Workout'
 else 'Other' end
              ;;
    suggestions: [ "Played Workout", "Completed Workout"]
  }



  dimension: aaptiv_actions {
    sql: case when  ${aaptiv_action_card_name} in ("Played Workout", "Completed Workout") then ${aaptiv_action_card_name}
        else null end
         ;;
    type: string

  }

  dimension: aaptiv_actions_yesno {
    sql:  ${aaptiv_action_card_name} in ("Played Workout", "Completed Workout")

                                 ;;
    type: yesno

  }


  dimension: aaptiv_play_card_name {
    sql: case when (${eventAction} = 'media_play' and ${eventLabel} in ('Basic_walking_workout', 'Walking_Workout_f_r_Einsteiger', 'Entra_nement_de_base___la_marche', 'Entra_nement_de_jogging_pour_d_butants')) then 'Basic Walking: Media Play'
            when (${eventAction} = 'media_play' and ${eventLabel} in ('Cardio___strength', 'Cardio___Kraft', 'Cardio___renforcement', 'Cardio___muscu')) then 'Cardio + Strength: Media Play'
            when (${eventAction} = 'media_play' and ${eventLabel} in ('Fast_and_total_training', 'HIT_Ganzk_rper_Workout', 'Entra_nement_rapide_et_total')) then 'Fast and Total Training: Media Play'
            when (${eventAction} = 'media_play' and ${eventLabel} in ('Find_your_strength', 'Entdecke_deine_Kraft', 'Trouvez_votre_point_fort', 'Trouve_ton_point_fort', 'D_couvrez_votre_force_physique'))
            then 'Find your Strength: Media Play'
            when (${eventAction} = 'media_play' and ${eventLabel} in ('Get_strong_faster', 'Kraft_Zirkeltraining', 'Devenir_fort_plus_rapidement', 'Course_fractionn_e', 'Circuit_d_entra_nement___la_musculation')) then 'Get Strong Faster: Media Play'
            when (${eventAction} = 'media_play' and ${eventLabel} in ('Jog_run_intervals', 'Intervalltraining', 'Intervalles_jog_course', 'Entra_nement_fractionn_')) then 'Jog/Run: Media Play'
            when (${eventAction} = 'media_play' and ${eventLabel} in ('Pick_up_the_pace', 'Vom_Walken_zum_Joggen', 'Acc_l_rer_le_rythme', 'De_la_marche_au_jogging')) then 'Pick Up the Pace: Media Play'
            when (${eventAction} = 'media_play' and ${eventLabel} in ('Start_getting_stronger', 'Krafttraining_f_r_Einsteiger', 'Commencer___devenir_plus_fort', 'Entra_nement_de_musculation_pour_d_butants')) then 'Start Getting Stronger: Media Play'
      when (${eventAction} = 'media_play' and ${eventLabel} in ('Walk_to_the_beat', 'Walking_im_Takt', 'Marcher_en_rythme', 'Courir_en_mesure')) then 'Walk to the Beat: Media Play'



when (${eventAction} = 'media_100' and ${eventLabel} in ('Basic_walking_workout', 'Entra_nement_de_base___la_marche', 'Entra_nement_de_jogging_pour_d_butants', 'Walking_Workout_f_r_Einsteiger')) then 'Basic Walking: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Cardio___Kraft', 'Cardio___renforcement', 'Cardio___strength')) then 'Cardio + Strength: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Entra_nement_corporel_complet', 'Entra_nement_rapide_et_total', 'Fast_and_total_training', 'HIT_Ganzk_rper_Workout')) then 'Fast and Total Training: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Entdecke_deine_Kraft', 'Find_your_strength', 'Trouvez_votre_point_fort')) then 'Find your Strength: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Course_fractionn_e', 'Devenir_fort_plus_rapidement', 'Get_strong_faster', 'Kraft_Zirkeltraining', 'Krafttraining_f_r_Einsteiger')) then 'Get Strong Faster: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Entra_nement_fractionn_', 'Intervalles_jog_course', 'Intervalltraining', 'Jog_run_intervals')) then 'Jog/Run: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Acc_l_rer_le_rythme', 'De_la_marche_au_jogging', 'Pick_up_the_pace', 'Vom_Walken_zum_Joggen')) then 'Pick Up the Pace: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Commencer___devenir_plus_fort', 'Entra_nement_de_musculation_pour_d_butants', 'Start_getting_stronger')) then 'Start Getting Stronger: Media 100'
when (${eventAction} = 'media_100' and ${eventLabel} in ('Courir_en_mesure', 'Marcher_en_rythme', 'Walk_to_the_beat', 'Walking_im_Takt')) then 'Walk to the Beat: Media 100'


        ;;
    suggestions: ["Start Getting Stronger: Media Play", "Basic Walking: Media Play", "Walk to the Beat: Media Play", "Pick Up the Pace: Media Play", "Fast and Total Training: Media Play", "Find your Strength: Media Play", "Jog/Run: Media Play",
      "Get Strong Faster: Media Play", "Cardio + Strength: Media Play",
      "Basic Walking: Media 100", "Cardio + Strength: Media 100", "Fast and Total Training: Media 100", "Find your Strength: Media 100", "Get Strong Faster: Media 100","Jog/Run: Media 100", "Pick Up the Pace: Media 100","Pick Up the Pace: Media 100",
      "Start Getting Stronger: Media 100", "Walk to the Beat: Media 100"]
  }



  dimension: aaptiv_playcard_name {
    sql: case when  ${aaptiv_play_card_name} in ("Start Getting Stronger: Media Play", "Basic Walking: Media Play", "Walk to the Beat: Media Play", "Pick Up the Pace: Media Play", "Fast and Total Training: Media Play", "Find your Strength: Media Play", "Jog/Run: Media Play",
      "Get Strong Faster: Media Play", "Cardio + Strength: Media Play",
      "Basic Walking: Media 100", "Cardio + Strength: Media 100", "Fast and Total Training: Media 100", "Find your Strength: Media 100", "Get Strong Faster: Media 100","Jog/Run: Media 100", "Pick Up the Pace: Media 100","Pick Up the Pace: Media 100",
      "Start Getting Stronger: Media 100", "Walk to the Beat: Media 100") then ${aaptiv_play_card_name}
        else null end
         ;;
    type: string

  }

  dimension: aaptiv_playcard_name_yesno {
    sql:  ${aaptiv_play_card_name} in ("Start Getting Stronger: Media Play", "Basic Walking: Media Play", "Walk to the Beat: Media Play", "Pick Up the Pace: Media Play", "Fast and Total Training: Media Play", "Find your Strength: Media Play", "Jog/Run: Media Play",
      "Get Strong Faster: Media Play", "Cardio + Strength: Media Play",
      "Basic Walking: Media 100", "Cardio + Strength: Media 100", "Fast and Total Training: Media 100", "Find your Strength: Media 100", "Get Strong Faster: Media 100","Jog/Run: Media 100", "Pick Up the Pace: Media 100","Pick Up the Pace: Media 100",
      "Start Getting Stronger: Media 100", "Walk to the Beat: Media 100")

                                 ;;
    type: yesno

  }






  dimension: card_name {
    sql: case when (${eventAction} in ('food_card_mindset','headspace') and ${hits.type} = 'EVENT') then 'Headspace'
              when (${eventAction} in ('activity_card_aaptiv','aaptivcard') and ${hits.type} = 'EVENT') then 'Aaptiv'
              when (${hits_appInfo.screenName} = 'Search' and ${hits.type} = 'APPVIEW') then 'Search'
               when ((${eventAction} = 'food_browse_Recipes' or ${eventAction} = 'browse_recipe') and ${hits.type} = 'EVENT') then 'Discover Recipes'
               when (${hits_appInfo.screenName} = 'connect_stream_trending' and ${hits.type} = 'APPVIEW') then 'Connect (Bottom of My Day)'
              when (${eventAction} = 'connect_seemoreposts_myday' and ${hits.type} = 'EVENT') then 'Connect (See More)'
              when (${eventAction} = 'iaf_my_day_card' and ${hits.type} = 'EVENT') then 'Invite a Friend'
              when (${hits_appInfo.screenName} = 'food_browse_Restaurants' and ${hits.type} = 'APPVIEW') then 'Restaurants'
              when (${hits_appInfo.screenName} = 'food_rollovercard' and ${hits.type} = 'APPVIEW') then 'Rollover Card'

              when (${hits_appInfo.screenName} = 'activity_dashboard' and ${hits.type} = 'APPVIEW') then 'Activity Dashboard'
              when (${hits_appInfo.screenName} = 'rewards_journey_home' and ${hits.type} = 'EVENT') then 'Journey (Bottom of My Day)'
              when (${eventAction} = 'onb_skip_tutorials' and ${hits.type} = 'EVENT') then 'Onboarding - Skip Tutorial'
              when (${eventAction} = 'onb_start_tutorial1' and ${hits.type} = 'EVENT') then 'Onboarding - Start Tutorial'
              when (${hits_appInfo.screenName} in ('food_card_recipes_Starter_Meals','food_card_recipes_Meals_for_Protein_Lovers','food_card_recipes_Meals_for_Carb_Lovers',
                       'food_card_recipes_Ideas_for_Veggie_Lovers','food_card_recipes_Family_Friendly_Meals', 'food_card_recipes_Endlich_Frühling_', 'food_card_recipes_Endlich_Fr_hling_', 'food_card_recipes_Iss__was_dir_schmeckt', 'food_card_recipes_Iss__was_dir_schmeckt_',
                      'food_card_recipes_Eintöpfe___Suppen', 'food_card_recipes_Bei_Partys_und_Festen', 'food_card_recipes_Snacks', 'food_card_recipes_Quick___easy', 'food_card_recipes_Seasonal', 'food_card_recipes_0_5_SmartPoints_', 'food_card_recipes_0_5_SmartPoints__recipes',
                      'food_card_recipes_Family_friendly','food_card_recipes_Go_veg_', ' food_card_recipes_Simple_snacks' ) and ${hits.type} = 'APPVIEW') then 'Recipe Tenure'

  when (${hits_appInfo.screenName} not in ('food_card_recipes_Starter_Meals','food_card_recipes_Meals_for_Protein_Lovers','food_card_recipes_Meals_for_Carb_Lovers',
                       'food_card_recipes_Ideas_for_Veggie_Lovers','food_card_recipes_Family_Friendly_Meals', 'food_card_recipes_Endlich_Frühling_', 'food_card_recipes_Endlich_Fr_hling_', 'food_card_recipes_Iss__was_dir_schmeckt', 'food_card_recipes_Iss__was_dir_schmeckt_',
                      'food_card_recipes_Eintöpfe___Suppen', 'food_card_recipes_Bei_Partys_und_Festen', 'food_card_recipes_Snacks', 'food_card_recipes_Quick___easy', 'food_card_recipes_Seasonal', 'food_card_recipes_0_5_SmartPoints_', 'food_card_recipes_0_5_SmartPoints__recipes',
                      'food_card_recipes_Family_friendly','food_card_recipes_Go_veg_', ' food_card_recipes_Simple_snacks'  ) and ${hits_appInfo.screenName} like 'food_card_recipes_%' and ${hits.type} = 'APPVIEW')  then 'Recipe Date'

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
              ) and ${hits_appInfo.screenName} like 'food_card_article_%' and ${hits.type} = 'APPVIEW') then 'Article Date'

               when (${hits_appInfo.screenName} in ('food_card_article_Don_t_Know_What_to_Eat_', 'food_card_article_Meal_planning_and_shopping_tips', 'food_card_article_What_is_Connect_', 'food_card_article_Should_I_tap_into_my_Weekly_SmartPoints_', 'food_card_article_The_importance_of_tracking_your_weight', 'food_card_article_What_s_your__why__',
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
              ) and ${hits.type} = 'APPVIEW') then 'Article Tenure'

              when (${hits_appInfo.screenName} in ('food_browse_recipes_Popular', 'food_browse_recipes_Low_SmartPoints_Mains', 'food_browse_recipes_Low_SmartPoints_Sides', 'food_browse_recipes_Zero_SmartPoints_Toppings___Dips', 'food_browse_recipes_No_Cook', 'food_browse_recipes_Quick___Easy', 'food_browse_recipes_Chicken_Every_Way',
              'food_browse_recipes_Cooking_for_One') and ${hits.type} = 'APPVIEW') then 'Default Collections - Discover Recipes'
              when (${hits_appInfo.screenName} like ('food_card_recipes_%') and ${hits.type} = 'APPVIEW') then 'All Recipes'
              when (${hits_appInfo.screenName} like ('food_card_article_%') and ${hits.type} = 'APPVIEW') then 'All Articles'
              when (${eventAction} = 'food_browse_recipebuilder' and ${hits.type} = 'EVENT') then 'Recipe Builder'
              when (${hits_appInfo.screenName} = 'MemberRecipes' and ${hits.type} = 'APPVIEW') then 'Member Recipes'
              when (${eventAction} = 'food_browse_seeall' and ${hits.type} = 'EVENT') then 'See All'
              when (${eventAction} = 'food_browse_favorites' and ${hits.type} = 'EVENT') then 'Favorites'
              when (${hits_appInfo.screenName} = 'Favorites' and ${hits.type} = 'APPVIEW') then 'Favorites (+)'
              when (${eventAction} = 'food_browse_featuredcollectionscroll' and ${hits.type} = 'EVENT') then 'Featured Collection Scroll'
               when (${eventAction} = 'food_browse_created' and ${hits.type} = 'EVENT') then 'Created'
              when (${hits_appInfo.screenName} = 'food_dashboard' and ${hits.type} = 'APPVIEW') then 'My Day'
              when (${eventAction} = 'zero_point_foods' and ${hits.type} = 'EVENT') then 'Zero Point Foods'
when (${hits_appInfo.screenName} = 'help_help_landing' and ${hits.type} = 'APPVIEW') then 'Coach (Bottom of My Day)'



              -- Continue with the rest of the cards
              else 'Other' end
              ;;
    suggestions: ["My Day","Search","Headspace", "Aaptiv", "Recipe Tenure","Discover Recipes","Connect", "Invite a Friend", "Restaurants", "Rollover Card" ,"Activity Dashboard", "Onboarding - Skip Tutorial","Onboarding - Start Tutorial", "All Recipes","All Articles", "Article Tenure", "Default Collections - Discover Recipes", "Other", "Article Date", "Recipe Date", "Created", "Featured Collection Scroll", "Favorites (+)", "Favorites", "See All",  "Member Recipes", "Recipe Builder",
      "Zero Point Foods", "Coach (Bottom of My Day)", "Journey (Bottom of My Day)"]
  }




dimension: my_day_cards {
  sql: case when  ${card_name} in ("My Day","Search","Headspace", "Aaptiv", "Recipe Tenure","Discover Recipes","Connect (Bottom of My Day)","Connect (See More)", "Invite a Friend", "Restaurants", "Rollover Card" ,"Activity Dashboard", "Onboarding - Skip Tutorial", "Onboarding - Start Tutorial", "Article Tenure", "Article Date", "Recipe Date",
  "Zero Point Foods", "Coach (Bottom of My Day)", "Journey (Bottom of My Day)") then ${card_name}
  else null end
   ;;
  type: string

}

  dimension: my_day_cards_yesno {
    sql:  ${card_name} in ("My Day","Search","Headspace", "Aaptiv", "Recipe Tenure","Discover Recipes","Connect (Bottom of My Day)","Connect (See More)", "Invite a Friend", "Restaurants", "Rollover Card" ,"Activity Dashboard", "Onboarding - Skip Tutorial", "Onboarding - Start Tutorial", "Article Tenure", "Article Date", "Recipe Date",
    "Zero Point Foods", "Coach (Bottom of My Day)", "Journey (Bottom of My Day)")

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



  dimension: onboarding_card_name {
    sql: case when (${hits_appInfo.screenName} = 'onb_welcomescreen' and ${hits.type} = 'APPVIEW') then 'Welcome Screen'
    when ((${hits_appInfo.screenName} = 'onb_profilescreen1'and ${hits.type} = 'APPVIEW') or (${eventAction} = 'onb_profile_step1' and ${hits.type} = 'EVENT')) then 'Personal Information 1'
    when ((${hits_appInfo.screenName} = 'onb_profilescreen2' and ${hits.type} = 'APPVIEW') or (${eventAction} = 'onb_profile_step2' and ${hits.type} = 'EVENT')) then 'Personal Information 2 (Activity)'
    when (${eventAction} = 'complete_profile' and ${hits.type} = 'EVENT') then 'Complete Onboarding Profile'
    when ((${hits_appInfo.screenName} = 'onb_tutorial_smartpoints' and ${hits.type} = 'APPVIEW') or (${eventAction} = 'onb_start_tutorial1' and ${hits.type} = 'EVENT')) then 'Tutorial Start'
    when ((${eventAction} = 'tutorial_skip' and ${hits.type} = 'EVENT') or (${eventAction} = 'onb_skip_tutorials' and ${hits.type} = 'EVENT')) then 'Skip Tutorial'
    when (${hits_appInfo.screenName} = 'onb_tutorial_smartpoints' and ${hits.type} = 'APPVIEW') then 'Tutorial 0 Pt Introduction'
    when ((${hits_appInfo.screenName} = 'onb_tfs_complete' and ${hits.type} = 'APPVIEW') or (${eventAction} = 'onb_tutorial203_complete' and ${hits.type} = 'EVENT') or (${eventAction} = 'onb_tutorial204_complete' and ${hits.type} = 'EVENT')) then 'Tutorial Finish'
    when ((${eventAction} = 'onb_my_day_checklist_tutorial204' and ${hits.type} = 'EVENT') or (${eventAction} = 'tracking_tutorial' and ${hits.type} = 'EVENT')) then 'Tracking Tutorial'
    when ((${eventAction} = 'onb_my_day_checklist_tutorial203' and ${hits.type} = 'EVENT') or (${eventAction} = 'dashboard_tutorial' and ${hits.type} = 'EVENT')) then 'Dashboard Tutorial'
    when ((${eventAction} = 'onb_my_day_checklist_setweightgoal' and ${hits.type} = 'EVENT') or (${eventAction} = 'weight_goal' and ${hits.type} = 'EVENT')) then 'Weight Goal Tutorial'
    when ((${eventAction} = 'onb_my_day_checklist_weighinday' and ${hits.type} = 'EVENT') or (${eventAction} = 'weight_tracking_day' and ${hits.type} = 'EVENT')) then 'Weight Tracking Day Tutorial'
    when ((${eventAction} = 'onb_my_day_checklist_check' and ${hits.type} = 'EVENT') or (${hits_appInfo.screenName} = 'onb_tips_success' and ${hits.type} = 'APPVIEW')) then 'Tips for Success'
    when (${eventAction} = 'onb_my_day_checklist_nextsteps_url_1 ' and ${hits.type} = 'EVENT') then 'How Freestyle Works Article'
    when (${eventAction} = 'onb_my_day_checklist_nextsteps_url_2 ' and ${hits.type} = 'EVENT') then 'Understanding SP Budget'
    when (${eventAction} = 'onb_my_day_checklist_nextsteps_url_3' and ${hits.type} = 'EVENT') then 'Zero Point Food'
    when (${eventAction} = 'onb_my_day_checklist_nextsteps_url_4' and ${hits.type} = 'EVENT') then 'Sample Meals'
    when (${eventAction} = 'onb_my_day_checklist_nextsteps_url_5' and ${hits.type} = 'EVENT') then 'WellnessWins'
    when (${eventAction} = 'onb_my_day_checklist_nextsteps_url_6 ' and ${hits.type} = 'EVENT') then 'Connect'
    when (${eventAction} = 'onb_my_day_checklist_nextsteps_url_7' and ${hits.type} = 'EVENT') then 'Mindset of Success'
    when (${eventAction} = 'onb_my_day_checklist_nextsteps_url_8' and ${hits.type} = 'EVENT') then 'How to Sync Fitness Device'


  -- Continue with the rest of the cards
              else 'Other' end
              ;;
    suggestions: ["Welcome Screen", "Personal Information 1", "Personal Information 2 (Activity)", "Tutorial Start", "Skip Tutorial", "Tutorial 0 Pt Introduction",
      "Tutorial Finish", "Tracking Tutorial", "Dashboard Tutorial", "Weight Goal Tutorial", "Weight Tracking Day Tutorial", "Tips for Success", "How Freestyle Works Article", "Understanding SP Budget",
      "Zero Point Food", "Sample Meals", "WellnessWins", "Connect", "Mindset of Success", "How to Sync Fitness Device"]
  }


  dimension: onboarding_type {
    label: "Onboarding Tutorial Type - Completed or Skipped"
    sql: case when (${onboarding_card_name} = 'Tutorial Start' and ${onboarding_card_name} =  'Tutorial Finish')  then 'Completed Tutorial'
            when ${onboarding_card_name} in ('Skip Tutorial') then 'Skipped Tutorial'
       else null end;;
    suggestions: ["Completed Tutorial","Skipped Tutorial" ]

}

  dimension: onboarding_type_finish_yesno {
    sql:  ${onboarding_card_name} in ('Tutorial Finish')
                     ;;
    type: yesno

}


  dimension: onboarding_type_start_yesno {
    sql:  ${onboarding_card_name} in ('Tutorial Start')
      ;;
    type: yesno

  }


  dimension: onboarding_type_skip_yesno {
    sql:  ${onboarding_card_name} in ('Skip Tutorial')
      ;;
    type: yesno

  }




  measure: completed_onb_session_count_start {
    type: count_distinct
    sql: ${ga_sessions.id};;
    filters: {
      field: onboarding_type_start_yesno
      value: "Yes"
    }
  }

  measure: completed_onb_session_count_finish {
    type: count_distinct
    sql: ${ga_sessions.id};;
    filters: {
      field: onboarding_type_finish_yesno
      value: "Yes"
    }
  }

  measure: completed_onb_session_count_skip {
    type: count_distinct
    sql: ${ga_sessions.id};;
    filters: {
      field: onboarding_type_skip_yesno
      value: "Yes"
    }
  }



  dimension: on_tipsforsuccess_cards {
    sql: case when  ${onboarding_card_name} in ("Tracking Tutorial", "Dashboard Tutorial", "Weight Goal Tutorial", "Weight Tracking Day Tutorial") then ${onboarding_card_name}
        else null end
         ;;
    type: string

  }

  dimension: on_tipsforsuccess_cards_yesno {
    sql:  ${onboarding_card_name} in ("Tracking Tutorial", "Dashboard Tutorial", "Weight Goal Tutorial", "Weight Tracking Day Tutorial")



                     ;;
    type: yesno

  }

  dimension: on_tips_cards {
    sql: case when  ${onboarding_card_name} in ("Tips for Success") then ${onboarding_card_name}
        else null end
         ;;
    type: string

  }

  dimension: on_tips_cards_yesno {
    sql:  ${onboarding_card_name} in ("Tips for Success")

                     ;;
    type: yesno

  }


  dimension: on_profile_creation_cards {
    sql: case when  ${onboarding_card_name} in ("Welcome Screen", "Personal Information 1", "Personal Information 2 (Activity)") then ${onboarding_card_name}
        else null end
         ;;
    type: string

  }

  dimension: on_profile_creation_cards_yesno {
    sql:  ${onboarding_card_name} in ("Welcome Screen", "Personal Information 1", "Personal Information 2 (Activity)")

               ;;
    type: yesno

  }

  dimension: on_articles_cards {
    sql: case when  ${onboarding_card_name} in ("How Freestyle Works Article", "Understanding SP Budget", "Zero Point Food", "Sample Meals", "WellnessWins", "Connect", "Mindset of Success",
    "How to Sync Fitness Device") then ${onboarding_card_name}
        else null end
         ;;
    type: string

  }

  dimension: on_articles_cards_yesno {
    sql:  ${onboarding_card_name} in ("How Freestyle Works Article", "Understanding SP Budget", "Zero Point Food", "Sample Meals", "WellnessWins", "Connect", "Mindset of Success",
    "How to Sync Fitness Device")

                     ;;
    type: yesno

  }





  dimension: activity {
    sql: case when (${hits_appInfo.screenName} = 'activity_dashboard' and ${hits.type} = 'APPVIEW') then 'Activity Dashboard'
            when (${hits_appInfo.screenName} = 'activity_search' and ${hits.type} = 'APPVIEW') then 'Activity Search'
            when (${hits_appInfo.screenName} = 'activity_details' and ${hits.type} = 'APPVIEW') then 'Activity Details'
            when (${eventAction} = 'track_activity' and ${hits.type} = 'EVENT') then 'Track Activity'
            when (${eventAction} = 'activity_favorited' and ${hits.type} = 'EVENT') then 'Activity Favorited'

            else 'Other' end
        ;;
    suggestions: ["Activity Dashboard", "Activity Search", "Activity Details", "Track Activity", "Activity Favorited"]
  }



  dimension: activity_name {
    sql: case when  ${activity} in ("Activity Dashboard", "Activity Search", "Activity Details", "Track Activity", "Activity Favorited") then ${activity}
        else null end
         ;;
    type: string

  }

  dimension: activity_name_yesno {
    sql:  ${activity} in ("Activity Dashboard", "Activity Search", "Activity Details", "Track Activity", "Activity Favorited")

                                 ;;
    type: yesno

  }


  dimension: activity_device {
    sql: case
            when (${eventAction} = 'sync_activity' and ${hits.type} = 'EVENT') then 'Sync Activity'
            when (${eventAction} = 'sync_device' and ${hits.type} = 'EVENT') then 'Sync Device'
            when (${eventAction} = 'sync_device_failed' and ${hits.type} = 'EVENT') then 'Sync Device Failed'




            else 'Other' end
        ;;
    suggestions: ["Sync Activity", "Sync Device", "Sync Device Failed"]
  }



  dimension: activity_device_name {
    sql: case when  ${activity_device} in ("Sync Activity", "Sync Device", "Sync Device Failed") then ${activity_device}
        else null end
         ;;
    type: string

  }

  dimension: activity_device_name_yesno {
    sql:  ${activity_device} in ("Sync Activity", "Sync Device", "Sync Device Failed")

                                       ;;
    type: yesno

  }







  dimension: activity_device_connect {
    sql: case
            when (${eventAction} = 'connect' and ${hits.type} = 'EVENT') then 'Connect Activity'
            when (${eventAction} = 'connect_success' and ${hits.type} = 'EVENT') then 'Connect Success'
            when (${eventAction} = 'connect_failed' and ${hits.type} = 'EVENT') then 'Connect Failed'



            else 'Other' end
        ;;
    suggestions: ["Connect Activity", "Connect Success", "Connect Failed"]
  }



  dimension: activity_device_connect_name {
    sql: case when  ${activity_device_connect} in ("Connect Activity", "Connect Success", "Connect Failed") then ${activity_device_connect}
        else null end
         ;;
    type: string

  }

  dimension: activity_device_connect_name_yesno {
    sql:  ${activity_device_connect} in ("Connect Activity", "Connect Success", "Connect Failed")

                                             ;;
    type: yesno

  }








  dimension: activity_allcards {
    sql: case
            when (${eventAction} = 'track_activity' and ${hits.type} = 'EVENT') then 'Track Activity'
            when (${eventAction} = 'activity_favorited' and ${hits.type} = 'EVENT') then 'Activity Favorited'
            when (${eventAction} = 'sync_activity' and ${hits.type} = 'EVENT') then 'Sync Activity'
            when (${eventAction} = 'sync_device' and ${hits.type} = 'EVENT') then 'Sync Device'
            when (${eventAction} = 'sync_device_failed' and ${hits.type} = 'EVENT') then 'Sync Device Failed'
            when (${eventAction} = 'connect' and ${hits.type} = 'EVENT') then 'Connect Activity'
            when (${eventAction} = 'connect_success' and ${hits.type} = 'EVENT') then 'Connect Success'
            when (${eventAction} = 'connect_failed' and ${hits.type} = 'EVENT') then 'Connect Failed'
            when (${hits_appInfo.screenName} = 'activity_dashboard' and ${hits.type} = 'APPVIEW') then 'Activity Dashboard'
            when (${hits_appInfo.screenName} = 'activity_search'  and ${hits.type} = 'APPVIEW') then 'Activity Search'
            when (${hits_appInfo.screenName} = 'activity_details' and ${hits.type} = 'APPVIEW') then 'Activity Details'





            else 'Other' end
        ;;
    suggestions: ["Activity Dashboard", "Activity Search", "Activity Details", "Track Activity", "Activity Favorited", "Sync Activity", "Sync Device", "Sync Device Failed", "Connect Activity", "Connect Success", "Connect Failed"]
  }



  dimension: activity_allcards_name {
    sql: case when  ${activity_allcards} in ("Activity Dashboard", "Activity Search", "Activity Details", "Track Activity", "Activity Favorited", "Sync Activity", "Sync Device", "Sync Device Failed", "Connect Activity", "Connect Success", "Connect Failed") then ${activity_allcards}
        else null end
         ;;
    type: string

  }

  dimension: activity_allcards_name_yesno {
    sql:  ${activity_allcards} in ("Activity Dashboard", "Activity Search", "Activity Details", "Track Activity", "Activity Favorited", "Sync Activity", "Sync Device", "Sync Device Failed", "Connect Activity", "Connect Success", "Connect Failed")

                                       ;;
    type: yesno

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

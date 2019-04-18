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
    sql: ${screenName} = 'connect_profile' ;;

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

  dimension: card_name {
    sql: case when ${eventAction} = 'food_card_mindset' then 'Headspace'
              when ${eventAction} = 'activity_card_aaptiv' then 'Aaptiv'

               when ${eventAction} = 'food_browse_Recipes' then 'Discover Recipes'
               when ${hits_appInfo.screenName} = 'connect_stream_trending' then 'Connect'
              when ${eventAction} = 'iaf_my_day_card' then 'Invite a Friend'
              when ${hits_appInfo.screenName} = 'food_browse_Restaurants' then 'Restaurants'
              when ${hits_appInfo.screenName} = 'food_rollovercard' then 'Rollover Card'

              when ${hits_appInfo.screenName} = 'activity_dashboard' then 'Activity Dashboard'
              when ${eventAction} = 'onb_skip_tutorials' then 'Onboarding - Skip Tutorial'
              when ${eventAction} = 'onb_start_tutorial1' then 'Onboarding - Start Tutorial'
              when ${hits_appInfo.screenName} like ('food_card_recipes_%') then 'All Recipes'
              when ${hits_appInfo.screenName} like ('food_card_article_%') then 'All Articles'
              when ${hits_appInfo.screenName} in ('food_card_recipes_Starter_Meals','food_card_recipes_Meals_for_Protein_Lovers','food_card_recipes_Meals_for_Carb_Lovers',
                       'food_card_recipes_Ideas_for_Veggie_Lovers','food_card_recipes_Family_Friendly_Meals', 'food_card_recipes_Endlich_Frühling_', 'food_card_recipes_Endlich_Fr_hling_', 'food_card_recipes_Iss__was_dir_schmeckt', 'food_card_recipes_Iss__was_dir_schmeckt_',
                      'food_card_recipes_Eintöpfe___Suppen', 'food_card_recipes_Bei_Partys_und_Festen', 'food_card_recipes_Snacks', 'food_card_recipes_Quick___easy', 'food_card_recipes_Seasonal', 'food_card_recipes_0_5_SmartPoints_', 'food_card_recipes_0_5_SmartPoints__recipes',
                      'food_card_recipes_Family_friendly' ) then 'Recipe Tenure'
  when (${hits_appInfo.screenName} not in ('food_card_recipes_Starter_Meals','food_card_recipes_Meals_for_Protein_Lovers','food_card_recipes_Meals_for_Carb_Lovers',
                       'food_card_recipes_Ideas_for_Veggie_Lovers','food_card_recipes_Family_Friendly_Meals', 'food_card_recipes_Endlich_Frühling_', 'food_card_recipes_Endlich_Fr_hling_', 'food_card_recipes_Iss__was_dir_schmeckt', 'food_card_recipes_Iss__was_dir_schmeckt_',
                      'food_card_recipes_Eintöpfe___Suppen', 'food_card_recipes_Bei_Partys_und_Festen', 'food_card_recipes_Snacks', 'food_card_recipes_Quick___easy', 'food_card_recipes_Seasonal', 'food_card_recipes_0_5_SmartPoints_', 'food_card_recipes_0_5_SmartPoints__recipes',
                      'food_card_recipes_Family_friendly' ) and ${hits_appInfo.screenName} like 'food_card_recipes_%')  then 'Recipe Date'

when ${hits_appInfo.screenName} not in ('food_card_article_Don_t_Know_What_to_Eat_', 'food_card_article_Meal_planning_and_shopping_tips', 'food_card_article_What_is_Connect_', 'food_card_article_Should_I_tap_into_my_Weekly_SmartPoints_', 'food_card_article_The_importance_of_tracking_your_weight', 'food_card_article_What_s_your__why__',
              'food_card_article_Tips_for_dining_out', 'food_card_article_Ideas_for_Smart_Snacking', 'food_card_article_How_do_I_estimate_portions_', 'food_card_article_Tips_for_syncing_your_fitness_device', 'food_card_article_Why_does_fruit_count_in_a_smoothie_', 'food_card_article_The_importance_of_practicing_awareness',
              'food_card_article_How_to_avoid_emotional_eating', 'food_card_article_The_importance_of_non_weight_goals', 'food_card_article_Keep_going_strong_with_WellnessWins_', 'food_card_article_Should_I_tap_into_my_weekly_SmartPoints_', 'food_card_article_Ideas_for_smart_snacking',
              'food_card_article_Tips_for_syncing_your_fitness_device_', 'food_card_article_The_importance_of_practicing_awareness_', 'food_card_article_Du_weißt_nicht__was_du_essen_sollst_', 'food_card_article_Du_wei_t_nicht__was_du_essen_sollst_', 'food_card_article_Du_weisst_nicht__was_du_essen_sollst_',
              'food_card_article_Dein_Einmaleins_im_Supermarkt', 'food_card_article_Muss_ich_meine_wöchentlichen_SmartPoints_nutzen_', 'food_card_article_Muss_ich_meine_w_chentlichen_SmartPoints_nutzen_', 'food_card_article_Wiegen_ist_wichtig__aber_nicht_alles', 'food_card_article_Wiegen_ist_wichtig__aber_nicht_alles_',
              'food_card_article_Alles_im__Gr_nen_Bereich_', 'food_card_article_Alles_im__Grünen_Bereich_', 'food_card_article_zero_Points__Lebensmitteln', 'food_card_article_Zero_Points_Lebensmittel', 'food_card_article_Einladungen_und_Restaurants', 'food_card_article_Warum_du_nicht_nur_zero_Points_Lebensmittel_essen_solltest',
              'food_card_article_Warum_du_nicht_nur_zero_Points__Lebensmittel_essen_solltest', 'food_card_article_Portionsgrößen_schätzen', 'food_card_article_Portionsgr__en_sch_tzen', 'food_card_article_Portionen_richtig_schätzen', 'food_card_article_Portionen_richtig_schätzen_', 'food_card_article_Portionen_richtig_sch_tzen',
              'food_card_article_Portionen_richtig_sch_tzen_', 'food_card_article_Portionsgrössen_schätzen', 'food_card_article_Essen_auf_Partys_und_Veranstaltungen', 'food_card_article_Im_Urlaub_und_auf_Reisen', 'food_card_article_Bewusst__und_nicht_aus_Langeweile_essen', 'food_card_article_Bewusst_und_nicht_aus_Langeweile_essen',
              'food_card_article_Snacks_für_unterwegs', 'food_card_article_Snacks_f_r_unterwegs', 'food_card_article_Snacks_für_Unterwegs'
              ) then 'Article Date'


               when ${hits_appInfo.screenName} in ('food_card_article_Don_t_Know_What_to_Eat_', 'food_card_article_Meal_planning_and_shopping_tips', 'food_card_article_What_is_Connect_', 'food_card_article_Should_I_tap_into_my_Weekly_SmartPoints_', 'food_card_article_The_importance_of_tracking_your_weight', 'food_card_article_What_s_your__why__',
              'food_card_article_Tips_for_dining_out', 'food_card_article_Ideas_for_Smart_Snacking', 'food_card_article_How_do_I_estimate_portions_', 'food_card_article_Tips_for_syncing_your_fitness_device', 'food_card_article_Why_does_fruit_count_in_a_smoothie_', 'food_card_article_The_importance_of_practicing_awareness',
              'food_card_article_How_to_avoid_emotional_eating', 'food_card_article_The_importance_of_non_weight_goals', 'food_card_article_Keep_going_strong_with_WellnessWins_', 'food_card_article_Should_I_tap_into_my_weekly_SmartPoints_', 'food_card_article_Ideas_for_smart_snacking',
              'food_card_article_Tips_for_syncing_your_fitness_device_', 'food_card_article_The_importance_of_practicing_awareness_', 'food_card_article_Du_weißt_nicht__was_du_essen_sollst_', 'food_card_article_Du_wei_t_nicht__was_du_essen_sollst_', 'food_card_article_Du_weisst_nicht__was_du_essen_sollst_',
              'food_card_article_Dein_Einmaleins_im_Supermarkt', 'food_card_article_Muss_ich_meine_wöchentlichen_SmartPoints_nutzen_', 'food_card_article_Muss_ich_meine_w_chentlichen_SmartPoints_nutzen_', 'food_card_article_Wiegen_ist_wichtig__aber_nicht_alles', 'food_card_article_Wiegen_ist_wichtig__aber_nicht_alles_',
              'food_card_article_Alles_im__Gr_nen_Bereich_', 'food_card_article_Alles_im__Grünen_Bereich_', 'food_card_article_zero_Points__Lebensmitteln', 'food_card_article_Zero_Points_Lebensmittel', 'food_card_article_Einladungen_und_Restaurants', 'food_card_article_Warum_du_nicht_nur_zero_Points_Lebensmittel_essen_solltest',
              'food_card_article_Warum_du_nicht_nur_zero_Points__Lebensmittel_essen_solltest', 'food_card_article_Portionsgrößen_schätzen', 'food_card_article_Portionsgr__en_sch_tzen', 'food_card_article_Portionen_richtig_schätzen', 'food_card_article_Portionen_richtig_schätzen_', 'food_card_article_Portionen_richtig_sch_tzen',
              'food_card_article_Portionen_richtig_sch_tzen_', 'food_card_article_Portionsgrössen_schätzen', 'food_card_article_Essen_auf_Partys_und_Veranstaltungen', 'food_card_article_Im_Urlaub_und_auf_Reisen', 'food_card_article_Bewusst__und_nicht_aus_Langeweile_essen', 'food_card_article_Bewusst_und_nicht_aus_Langeweile_essen',
              'food_card_article_Snacks_für_unterwegs', 'food_card_article_Snacks_f_r_unterwegs', 'food_card_article_Snacks_für_Unterwegs'
              ) then 'Article Tenure'

              when ${hits_appInfo.screenName} in ('food_browse_recipes_Popular', 'food_browse_recipes_Low_SmartPoints_Mains', 'food_browse_recipes_Low_SmartPoints_Sides', 'food_browse_recipes_Zero_SmartPoints_Toppings___Dips', 'food_browse_recipes_No_Cook', 'food_browse_recipes_Quick___Easy', 'food_browse_recipes_Chicken_Every_Way',
              'food_browse_recipes_Cooking_for_One') then 'Default Collections - Discover Recipes'


              -- Continue with the rest of the cards
              else 'Other' end
              ;;
    suggestions: ["Headspace", "Aaptiv", "Recipe Tenure","Discover Recipes","Connect", "Invite a Friend", "Restaurants", "Rollover Card" ,"Activity Dashboard", "Onboarding - Skip Tutorial","Onboarding - Start Tutorial", "All Recipes","All Articles", "Article Tenure", "Default Collections - Discover Recipes", "Other", "Article Date", "Recipe Date" ]
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


}

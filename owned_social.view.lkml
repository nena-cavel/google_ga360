view: owned_social {
  sql_table_name: rsheridan._looker_ownedSocial ;;

  dimension: ad_content {
    type: string
    sql: ${TABLE}.adContent ;;
  }
  dimension: date {
    type: date_time
    sql: CAST(${TABLE}.date AS timestamp) ;;
  }
  dimension: ambassador_present {
    type: string
    sql: ${TABLE}.ambassadorPresent ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}.assetType ;;
  }


  dimension: campaign {
    type: string
    sql: ${TABLE}.campaign ;;
  }

  dimension: campaign_type {
    type: string
    sql: ${TABLE}.campaignType ;;
  }

  dimension: channel_grouping {
    type: string
    sql: ${TABLE}.channelGrouping ;;
  }

  dimension: creator {
    type: string
    sql: ${TABLE}.creator ;;
  }

  dimension: keyword {
    type: string
    sql: ${TABLE}.keyword ;;
  }

  dimension: landingpage {
    type: string
    sql: ${TABLE}.landingpage ;;
  }

  dimension: medium {
    type: string
    sql: ${TABLE}.medium ;;
  }



  dimension: page_owner {
    type: string
    sql: ${TABLE}.pageOwner ;;
  }

  dimension: page_path_level2 {
    type: string
    sql: ${TABLE}.pagePathLevel2 ;;
  }



  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}.source ;;
  }

  dimension: time_period {
    type: string
    sql: ${TABLE}.timePeriod ;;
  }



  measure: count {
    type: count
    drill_fields: []
  }

  measure: new_visits {
    type: sum
    sql: ${TABLE}.newVisits ;;
  }
  measure: pageviews {
    type: sum
    sql: ${TABLE}.pageviews ;;
  }
measure: bounces {
  type: sum
  sql: ${TABLE}.bounces ;;
}
  measure: total_time {
    type: sum
    sql: ${TABLE}.totalTime ;;
  }
  measure: unique_users {
    type: sum
    sql: ${TABLE}.uniqueUsers ;;
  }
  measure: visits {
    type: sum
    sql: ${TABLE}.visits ;;
  }
  measure: sign_ups {
    type: sum
    sql: ${TABLE}.signUps ;;
  }
}

explore: owned_social{}

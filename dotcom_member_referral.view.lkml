view: dotcom_member_referral {
  # # You can specify the table name if it's different from the view name:
   sql_table_name: `wwi-datalake-1.wwi_events_pond.dotcom_Member_Referral` ;;

  dimension: headers_action{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.headers_action;;
  }
  dimension: headers_eventtimestamp_offset{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.headers_eventTimestamp_offset;;
  }
  dimension: headers_id{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.headers_id;;
  }
  dimension: headers_messagetimestamp_offset{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.headers_messageTimestamp_offset;;
  }
  dimension: headers_type{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.headers_type;;
  }
  dimension: payload_email_first_use{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.payload_email_first_use;;
  }
  dimension: payload_last_upd_date{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.payload_last_upd_date;;
  }
  dimension: payload_last_utc_timestamp_offset{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.payload_last_utc_timestamp_offset;;
  }
  dimension: payload_member_no{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.payload_member_no;;
  }
  dimension: payload_obsolete_flag{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.payload_obsolete_flag;;
  }
  dimension: payload_referred_member_no{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.payload_referred_member_no;;
  }
  dimension: payload_referred_uuid{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.payload_referred_uuid;;
  }
  dimension: payload_uuid{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.payload_uuid;;
  }
  dimension: partitions_month{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.partitions_month;;
  }
  dimension: partitions_day{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.partitions_day;;
  }
  dimension: partitions_hour{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.partitions_hour;;
  }
  dimension: partitions_year{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.partitions_year;;
  }
  dimension: payload_referred_first_name{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.payload_referred_first_name;;
  }
  dimension: payload_referred_last_name{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.payload_referred_last_name;;
  }
  dimension: payload_referred_email{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.payload_referred_email;;
  }
  dimension: payload_referral_id{
    description: "from dotcom_Member_referral"
    type:number
    sql: ${TABLE}.payload_referral_id;;
  }
  dimension: payload_referral_url_id{
    description: "from dotcom_Member_referral"
    type:number
    sql: ${TABLE}.payload_referral_url_id;;
  }
  dimension: payload_site_id{
    description: "from dotcom_Member_referral"
    type:number
    sql: ${TABLE}.payload_site_id;;
  }

  ###need to investigate a way to concat and do a true count of invites per member####
dimension: invites {
    type: string
    label: "unique invite per member"
    sql: CONCAT(CAST(${payload_last_upd_date} AS string),${payload_uuid}) ;;
    }

  measure: invitingMembers {
    type: count_distinct
    label: "Members sharing invites"
    sql: ${payload_uuid} ;;
  }

  ###need to investigate a way to concat and do a true count of invites per member####
  measure: invitesCount {
    type: count_distinct
    label: "Total invites shared"
    sql: ${invites} ;;
  }
  measure: successfulInvites {
    type: count_distinct
    label: "Successful invites (new members)"
    sql: ${payload_referred_uuid} ;;
  }
}

view: ga_example {
  # # You can specify the table name if it's different from the view name:
  sql_table_name: `wwi-datalake-1.wwi_ga_pond.ga_sessions` ;;
  dimension: visitnumber{
    description: "from GA"
    type:number
    sql: ${TABLE}.visitNumber;;
  }
  dimension: visitid{
    description: "from GA"
    type:number
    sql: ${TABLE}.visitId;;
  }
  dimension: totals.visits{
    description: "from GA"
    type:number
    sql: ${TABLE}.totals.visits;;
  }
  dimension: totals.hits{
    description: "from GA"
    type:number
    sql: ${TABLE}.totals.hits;;
  }
  dimension: totals.pageviews{
    description: "from GA"
    type:number
    sql: ${TABLE}.totals.pageviews;;
  }
  dimension: totals.timeonsite{
    description: "from GA"
    type:number
    sql: ${TABLE}.totals.timeOnSite;;
  }
  dimension: totals.bounces{
    description: "from GA"
    type:number
    sql: ${TABLE}.totals.bounces;;
  }
  dimension: totals.transactions{
    description: "from GA"
    type:number
    sql: ${TABLE}.totals.transactions;;
  }
  dimension: date{
    description: "from GA"
    type:string
    sql: ${TABLE}.date;;
  }
  dimension: trafficsource.referralpath{
    description: "from GA"
    type:string
    sql: ${TABLE}.trafficSource.referralPath;;
  }
  dimension: trafficsource.campaign{
    description: "from GA"
    type:string
    sql: ${TABLE}.trafficSource.campaign;;
  }
  dimension: trafficsource.source{
    description: "from GA"
    type:string
    sql: ${TABLE}.trafficSource.source;;
  }
  dimension: trafficsource.medium{
    description: "from GA"
    type:string
    sql: ${TABLE}.trafficSource.medium;;
  }
  dimension: trafficsource.keyword{
    description: "from GA"
    type:string
    sql: ${TABLE}.trafficSource.keyword;;
  }
  dimension: trafficsource.adcontent{
    description: "from GA"
    type:string
    sql: ${TABLE}.trafficSource.adContent;;
  }

  dimension: fullvisitorid{
    description: "from GA"
    type:string
    sql: ${TABLE}.fullVisitorId;;
  }
  dimension: channelgrouping{
    description: "from GA"
    type:string
    sql: ${TABLE}.channelGrouping;;
  }
  dimension: uuid_dimension {
    type: string
    sql: (SELECT value FROM UNNEST(${TABLE}.customDimensions) WHERE index=12) ;;
  }
  measure: clickThruUsers {
    type: count_distinct
    label: "Members clicking thru email link"
    sql: ${uuid_dimension} ;;
  }
  }


###as it stands, this explore does not include users who clickthed through the email but did not invite - need to switch join direction so left join is from google to dotcom
explore: ga_example {
  case_sensitive: no
  label: "Google Analytics and IAF"
  sql_always_where: ${ga_example.channelgrouping} LIKE "%Email%" AND ${trafficsource.adcontent} LIKE "%iaf%";;
  join: dotcom_member_referral {
    type: left_outer
    relationship: one_to_one
    sql_on: ${ga_example.uuid_dimension}=${dotcom_member_referral.payload_uuid};;
  }
}

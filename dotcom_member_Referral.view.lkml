view: dotcom_member_referral {
  # # You can specify the table name if it's different from the view name:
   sql_table_name: `wwi-datalake-1.wwi_events_pond.dotcom_Member_Referral` ;;

    #Define your dimensions and measures here, like this:
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
  dimension: payload_last_upd_date_offset{
    description: "from dotcom_Member_referral"
    type:string
    sql: ${TABLE}.payload_last_upd_date_offset;;
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

}

explore: dotcom_member {
  from: dotcom_member_referral
}

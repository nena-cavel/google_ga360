view: iaf_emails {

sql_table_name: `wwi-data-playground-3.rsheridan._looker_emailDrivenIAF_byProduct` ;;


  dimension: clickThruMember{
    description: "GA click thru members"
    type:string
    sql: ${TABLE}.value;;
  }
  dimension: invitingMember{
    description: "DC inviting members"
    type:string
    sql: ${TABLE}.payload_uuid;;
  }
  dimension: invitedMembers{
    description: "DC invited members who signed up"
    type:string
    sql: ${TABLE}.payload_referred_uuid;;
  }

dimension: campaign{
  description: "GA Campaign"
  type:string
  sql: ${TABLE}.campaign;;
}
  dimension: medium{
    description: "GA Medium"
    type:string
    sql: ${TABLE}.medium;;
  }
  dimension: source{
    description: "GA Source"
    type:string
    sql: ${TABLE}.source;;
  }
  dimension: adContent{
    description: "GA Ad Content"
    type:string
    sql: ${TABLE}.adContent;;
  }
  dimension: campaigndate{
    description: "GA Campaign Date"
    type:date
    sql: ${TABLE}.campaigndate;;
  }
  dimension: campaigndate2{
    label: "GA Email Deploy Date (Campaign)"
    type:date
    sql: ${TABLE}.campaigndate2;;
  }
  dimension: campaignCharType{
    description: "GA Campaign Character Type"
    type:string
    sql: ${TABLE}.campaigndate;;
  }
  dimension: dateType{
    description: "Whether IAF invite was shared before or after email sent"
    type:string
    sql: ${TABLE}.dateType;;
  }
  dimension: originalBirthDate{
    description: "DM Inviter birthdate"
    type:string
    sql: ${TABLE}.originalBirthDate;;
  }
  dimension: originalGender{
    description: "DM Inviter Gender"
    type:string
    sql: ${TABLE}.originalGender;;
  }
  dimension: invitedGender{
    description: "DM Invitee Gender"
    type:string
    sql: ${TABLE}.invitedGender;;
  }
  dimension: invitedBirthDate{
    description: "DM Invitee birthdate"
    type:string
    sql: ${TABLE}.invitedBirthDate;;
}
  dimension: invitedMemberStatus{
    description: "Were invited members lapsed or new?"
    type:string
    sql: ${TABLE}.invitedMemberStatus;;
  }

  dimension: invitedCategory{
    description: "DP Invitee category"
    type:string
    sql: ${TABLE}.invitedCategory;;
  }

  dimension: originalCategory{
    description: "DP inviting member category (at time of email campaign)"
    type:string
    sql: ${TABLE}.originalCategory;;
  }

####Metrics
measure: clickThruUsers {
  type: sum
  label: "Members clicking thru email links"
  sql: ${TABLE}.clickThruUsers ;;
}
  measure: invitingUsers {
    type: sum
    label: "Members sharing invites"
    sql: ${TABLE}.invitingUsers ;;
  }
  measure: totalInvites {
    type: sum
    label: "Total invites shared"
    sql: ${TABLE}.totalinvites ;;
  }
  measure: succesfulInvites {
    type: sum
    label: "Sign ups from invites"
    sql: ${TABLE}.successfulinvites ;;
  }
  measure: MemberInvitesDigital {
    type: sum
    label: "Digital member invites shared"
    sql: ${TABLE}.MemberInvitesDigital ;;
  }
  measure: MemberInvitesMonthlyPass {
    type: sum
    label: "Monthly pass member invites shared"
    sql: ${TABLE}.MemberInvitesMonthlyPass ;;
  }
  measure: NewDigital {
    type: sum
    label: "Sign ups from Digital members"
    sql: ${TABLE}.NewDigital ;;
  }
  measure: NewMonthlyPass {
    type: sum
    label: "Sign ups from Monthly Pass members"
    sql: ${TABLE}.NewMonthlyPass ;;
  }
}

explore: iaf_emails {}

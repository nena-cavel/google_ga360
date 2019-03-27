explore: ga_sessions_base {
#   persist_for: "1 hour"
  extension: required
  view_name: ga_sessions
  view_label: "Session"
  join: totals {
    view_label: "Session"
    sql:  LEFT JOIN UNNEST([${ga_sessions.totals}]) as totals ;;
    relationship: one_to_one
  }
  join: trafficSource {
    view_label: "Session: Traffic Source"
    sql: LEFT JOIN UNNEST([${ga_sessions.trafficSource}]) as trafficSource ;;
    relationship: one_to_one
  }
  # join: adwordsClickInfo {
  #   view_label: "Session: Traffic Source : Adwords"
  #   sql: LEFT JOIN UNNEST([${trafficSource.adwordsClickInfo}]) as  adwordsClickInfo;;
  #   relationship: one_to_one
  # }

  # join: DoubleClickClickInfo {
  #   view_label: "Session: Traffic Source : DoubleClick"
  #   sql: LEFT JOIN UNNEST([${trafficSource.DoubleClickClickInfo}]) as  DoubleClickClickInfo;;
  #   relationship: one_to_one
  # }
  join: device {
    view_label: "Session: Device"
    sql: LEFT JOIN UNNEST([${ga_sessions.device}]) as device ;;
    relationship: one_to_one
  }
  join: geoNetwork {
    view_label: "Session: Geo Network"
    sql: LEFT JOIN UNNEST([${ga_sessions.geoNetwork}]) as geoNetwork ;;
    relationship: one_to_one
  }
  join: hits {
    view_label: "Session: Hits"
    sql: LEFT JOIN UNNEST(${ga_sessions.hits}) as hits ;;
    relationship: one_to_many
  }
  join: hits_page {
    view_label: "Session: Hits: Page"
    sql: LEFT JOIN UNNEST([${hits.page}]) as hits_page ;;
    relationship: one_to_one
  }
  join: hits_transaction {
    view_label: "Session: Hits: Transaction"
    sql: LEFT JOIN UNNEST([${hits.transaction}]) as hits_transaction ;;
    relationship: one_to_one
  }
  join: hits_product {
    view_label: "Session: Hits: Product"
    sql: LEFT JOIN UNNEST(${hits.product}) as hits_product ;;
    relationship: one_to_many
  }

#  join: hits_product_customdimensions {
#    sql: LEFT JOIN UNNEST(${hits_product.customDimensions}) as hits_product_customdimensions ;;
#    relationship: one_to_one
#  }

  join: hits_latency {
    view_label: "Session: Hits: Latency Tracking"
    sql: LEFT JOIN UNNEST([${hits.latencyTracking}]) as hits_latency ;;
    relationship: one_to_one
  }
  join: hits_item {
    view_label: "Session: Hits: Item"
    sql: LEFT JOIN UNNEST([${hits.item}]) as hits_item ;;
    relationship: one_to_one
  }
  join: hits_social {
    view_label: "Session: Hits: Social"
    sql: LEFT JOIN UNNEST([${hits.social}]) as hits_social ;;
    relationship: one_to_one
  }
  join: hits_publisher {
    view_label: "Session: Hits: Publisher"
    sql: LEFT JOIN UNNEST([${hits.publisher}]) as hits_publisher ;;
    relationship: one_to_one
  }
  join: hits_appInfo {
    view_label: "Session: Hits: App Info"
    sql: LEFT JOIN UNNEST([${hits.appInfo}]) as hits_appInfo ;;
    relationship: one_to_one
  }

  join: hits_eventInfo{
    view_label: "Session: Hits: Events Info"
    sql: LEFT JOIN UNNEST([${hits.eventInfo}]) as hits_eventInfo ;;
    relationship: one_to_one
  }

  join: hits_contentGroup {
    view_label: "Session: Hits: ContentGroup Info"
    sql: LEFT JOIN UNNEST([${hits.contentGroup}]) as hits_contentGroup ;;
    relationship: one_to_one
  }

  # join: hits_sourcePropertyInfo {
  #   view_label: "Session: Hits: Property"
  #   sql: LEFT JOIN UNNEST([hits.sourcePropertyInfo]) as hits_sourcePropertyInfo ;;
  #   relationship: one_to_one
  #   required_joins: [hits]
  # }

  # join: hits_eCommerceAction {
  #   view_label: "Session: Hits: eCommerce"
  #   sql: LEFT JOIN UNNEST([hits.eCommerceAction]) as  hits_eCommerceAction;;
  #   relationship: one_to_one
  #   required_joins: [hits]
  # }

  join: hits_customDimensions {
    view_label: "Session: Hits: Custom Dimensions"
    sql: LEFT JOIN UNNEST(${hits.customDimensions}) as hits_customDimensions ;;
    relationship: one_to_many
  }
  join: hits_customVariables{
    view_label: "Session: Hits: Custom Variables"
    sql: LEFT JOIN UNNEST(${hits.customVariables}) as hits_customVariables ;;
    relationship: one_to_many
  }
  join: first_hit {
    from: hits
    sql: LEFT JOIN UNNEST(${ga_sessions.hits}) as first_hit ;;
    relationship: one_to_one
    sql_where: ${first_hit.hitNumber} = 1 ;;
    fields: [first_hit.page,first_hit.contentGroup]
  }
  join: first_page {
    view_label: "Session: First Page Visited"
    from: hits_page
    sql: LEFT JOIN UNNEST([${first_hit.page}]) as first_page ;;
    relationship: one_to_one
  }
  join: first_pagename {
    view_label: "Session: First Page Visited"
    from: hits_contentGroup
    sql: LEFT JOIN UNNEST([${first_hit.contentGroup}]) as first_pagename ;;
    relationship: one_to_one
  }
  join: customDimensions {
    view_label: "Custom Dimensions - Sessions"
    sql: LEFT JOIN UNNEST(${ga_sessions.customDimensions}) as customDimensions ;;
    relationship: one_to_one
  }
}

view: ga_sessions_base {
  extension: required
  dimension: partition_date {
    type: date_time
    sql: CAST(CONCAT(SUBSTR(${TABLE}.suffix,0,4),'-',SUBSTR(${TABLE}.suffix,5,2),'-',SUBSTR(${TABLE}.suffix,7,2)) AS TIMESTAMP) ;;
  }
  dimension: site_region {
    sql: (SELECT value FROM UNNEST(${TABLE}.customDimensions) WHERE index=53) ;;
  }

  dimension: market {
    suggestions: ["US","DE","NL","FR","BE","CA","CH","AU","SE","BR","GB"]
    sql: CASE WHEN REGEXP_CONTAINS(${site_region}, 'us|de|nl|fr|be|ca|ch|au|se|br') THEN UPPER(${site_region})
       WHEN ${site_region} = 'uk' THEN 'GB' ELSE NULL END ;;
  }

  dimension: signupVersion {
    sql: (SELECT value FROM UNNEST(${TABLE}.customDimensions) WHERE index = 54) ;;
  }

  dimension: pricingEngine {
    sql: (SELECT value FROM UNNEST(${TABLE}.customDimensions) WHERE index = 57) ;;
  }

  dimension: application_type {
    sql: (SELECT value FROM unnest(${TABLE}.customDimensions) WHERE index=1) ;;
  }
  dimension: id {
    primary_key: yes
    sql: CONCAT(CAST(${fullVisitorId} AS STRING), '|', COALESCE(CAST(${visitId} AS STRING),'')) ;;
  }
  dimension: funnelid {
    sql: CONCAT(CAST(${fullVisitorId} AS STRING), '|', COALESCE(CAST(${date} AS STRING),'')) ;;
  }
  dimension: visitorId {label: "Visitor ID"}

  dimension: visitnumber {
    label: "Visit Number"
    type: number
    description: "The session number for this user. If this is the first session, then this is set to 1."
  }

  dimension:  first_time_visitor {
    type: yesno
    sql: ${visitnumber} = 1 ;;
  }

  dimension: visitnumbertier {
    label: "Visit Number Tier"
    type: tier
    tiers: [1,2,5,10,15,20,50,100]
    style: integer
    sql: ${visitnumber} ;;
  }
  dimension: visitId {label: "Visit ID"}
  dimension: fullVisitorId {label: "Full Visitor ID"}

  dimension: visitStartSeconds {
    label: "Visit Start Seconds"
    type: date
    sql: TIMESTAMP_SECONDS(${TABLE}.visitStarttime) ;;
    hidden: yes
  }

  dimension: Member {
    type: yesno
    sql: (
        ${Prospect} IS FALSE

    );;
  }

  dimension: funnelProspect {
  type:  yesno
  sql: (
          ((${totals.transactions} is not null AND REGEXP_CONTAINS(${hits_eventInfo.eventAction},'signup') ) )
        OR
          ((${memberID} is NULL AND ${totals.transactions} IS NULL)
            AND
          (REGEXP_CONTAINS(${hits_contentGroup.contentGroup3},r'(^logi:logout|^logi:..:recovery|^logi:..:password|^cmx|^trac:|^coac:|^well:|^conn:|sign:..:login|sign:..:activation|subc:)') IS FALSE AND ${totals.transactions} IS NULL))
      )
         ;;
  }

  dimension: Prospect {
    type:  yesno
    sql:
        (${memberID} is NULL AND ${totals.transactions} IS NULL)
      AND
        (REGEXP_CONTAINS(${hits_contentGroup.contentGroup3},r'(^logi:logout|^logi:..:recovery|^logi:..:password|^cmx|^trac:|^coac:|^well:|^conn:|sign:..:login|sign:..:activation|subc:)') IS FALSE AND ${totals.transactions} IS NULL)
         ;;
  }

  dimension: iaf {
    type:  yesno
    sql:
      (${first_pagename.contentGroup3} = 'visi:us:invited')
    ;;
  }

  dimension: importantLandingPage {
    type: yesno
    sql:  REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:..:home$') OR
          REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'sign:..:plan') OR
          REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:..:(plans-|prijzen)') OR
          REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:..:.*meeting-finder$') OR
          REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:..:(about-WW|om-ww|over-ww|a-propos-de-ww|ueber-ww|sobre-ww|nous-sommes-ww)');;
  }

  dimension: ukSEOpages {
    type: yesno
    sql:
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-5-reasons-you-experience-weight-gain-during-your-period') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-12-easy-dinner-ideas-busy-week-nights') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-24-delicious-breakfasts-try') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-0-smartpoints-recipes') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-our-30-most-popular-recipes-voted-you') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):recipe-roasted-peppers-and-red-onions-5b89446d2654d2001c75dc9d') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-can-you-eat-too-many-eggs') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-egg-recipes-by-the-dozen') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-egg-recipes-tips') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-eggs-101-how-to-cook-them-perfectly') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-what-happens-when-you-dont-take-10000-steps-day') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-what-are-rollovers') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-overnight-oats-recipes') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-Indian-food-Indian-takeaway') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):ios-apple-health-faq-help-support') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):food-zero-points-foods') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):eating-out-weight-watchers') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-restaurant-survival-guide') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-simple-cake-recipes') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-chocolate-dessert-recipes') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-weight-watchers-vegan-recipes') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-what-can-vegans-eat-weight-watchers') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):recipe-easy-fried-rice-5b97b376bccf5c0020a89ae0') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-healthy-salad-dressings-dips-dunks') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-recipes-peanut-butter-powder') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-chocolate-survival-guide') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-8-foods-keep-you-full') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-6-healthy-soup-recipes') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-12-tinned-bean-recipes') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-guide-to-nuts-and-seeds') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-smartpoints-help-support') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-effects-of-late-night-eating') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-homemade-hummus-recipe') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-fruit-smoothies-juices-smartpoints') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):recipe-creamy-mash-1-5625c064d9d5bb0934572a70') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):recipe-stuffed-chicken-breasts-with-mushrooms-and-stilton-5850d476b1bd0e411614a71f') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-best-plain-fat-free-yogurt') OR
      REGEXP_CONTAINS(${first_pagename.contentGroup3}, 'visi:(gb|us):article-italian-restaurant-italian-food-guide');;
  }


  ## referencing partition_date for demo purposes only. Switch this dimension to reference visistStartSeconds
  dimension_group: visitStart {
    timeframes: [date,day_of_week,fiscal_quarter,week,month,year,month_name,month_num,week_of_year]
    label: "Visit Start"
    type: time
    sql: (TIMESTAMP(${visitStartSeconds})) ;;
    convert_tz: no
  }
  ## use visit or hit start time instead
  dimension: date {
    hidden: yes
  }
  dimension: socialEngagementType {label: "Social Engagement Type"}
  dimension: userid {label: "User ID"}

  measure: session_count {
    type: count
    drill_fields: [fullVisitorId, visitnumber, session_count, totals.transactions_count, totals.transactionRevenue_total]
  }
  measure: unique_visitors {
    type: count_distinct
    sql: ${fullVisitorId} ;;
    drill_fields: [fullVisitorId, visitnumber, session_count, totals.hits, totals.page_views, totals.timeonsite]
  }

  measure: average_sessions_ver_visitor {
    type: number
    sql: 1.0 * (${session_count}/NULLIF(${unique_visitors},0))  ;;
    value_format_name: decimal_2
    drill_fields: [fullVisitorId, visitnumber, session_count, totals.hits, totals.page_views, totals.timeonsite]
  }

  measure: total_visitors {
    type: count
    drill_fields: [fullVisitorId, visitnumber, session_count, totals.hits, totals.page_views, totals.timeonsite]
  }

  measure: first_time_visitors {
    label: "First Time Visitors"
    type: count
    filters: {
      field: visitnumber
      value: "1"
    }
  }

  measure: second_time_visitors {
    label: "Second Time Visitors"
    type: count
    filters: {
      field: visitnumber
      value: "2"
    }
  }


  measure: returning_visitors {
    label: "Returning Visitors"
    type: count
    filters: {
      field: visitnumber
      value: "<> 1"
    }
  }

  dimension: channelGrouping {label: "Channel Grouping"}

  # subrecords
  dimension: geoNetwork {hidden: yes}
  dimension: totals {hidden:yes}
  dimension: trafficSource {hidden:yes}
  dimension: device {hidden:yes}
  dimension: customDimensions {hidden:yes}
  dimension: memberID {
    type: string
    sql: (SELECT value FROM UNNEST(${TABLE}.customdimensions) WHERE index=12);;
  }

  dimension: hits {hidden:yes}
  dimension: hits_eventInfo {hidden:yes}

}


view: geoNetwork_base {
  extension: required
  dimension: continent {
    drill_fields: [subcontinent,country,region,city,metro,approximate_networkLocation,networkLocation]
  }
  dimension: subcontinent {
    drill_fields: [country,region,city,metro,approximate_networkLocation,networkLocation]

  }
  dimension: country {
    map_layer_name: countries
    drill_fields: [region,metro,city,approximate_networkLocation,networkLocation]
  }
  dimension: region {
    drill_fields: [metro,city,approximate_networkLocation,networkLocation]
  }
  dimension: metro {
    drill_fields: [city,approximate_networkLocation,networkLocation]
  }
  dimension: city {drill_fields: [metro,approximate_networkLocation,networkLocation]}
  dimension: cityid { label: "City ID"}
  dimension: networkDomain {label: "Network Domain"}
  dimension: latitude {
    type: number
    hidden: yes
    sql: CAST(${TABLE}.latitude as FLOAT64);;
  }
  dimension: longitude {
    type: number
    hidden: yes
    sql: CAST(${TABLE}.longitude as FLOAT64);;
  }
  dimension: networkLocation {label: "Network Location"}
  dimension: location {
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
  }
  dimension: approximate_networkLocation {
    type: location
    sql_latitude: ROUND(${latitude},1) ;;
    sql_longitude: ROUND(${longitude},1) ;;
    drill_fields: [networkLocation]
  }
}


view: totals_base {
  extension: required
  dimension: id {
    primary_key: yes
    hidden: yes
    sql: ${ga_sessions.id} ;;
  }

  measure: visits_total {
    type: sum
    sql: ${TABLE}.visits ;;
  }
  measure: hits_total {
    type: sum
    sql: ${TABLE}.hits ;;
    drill_fields: [hits.detail*]
  }
  measure: hits_average_per_session {
    type: number
    sql: 1.0 * ${hits_total} / NULLIF(${ga_sessions.session_count},0) ;;
    value_format_name: decimal_2
  }
  measure: pageviews_total {
    label: "Page Views"
    type: sum
    sql: ${TABLE}.pageviews ;;
  }
  measure: timeonsite_total {
    label: "Time On Site"
    type: sum
    sql: ${TABLE}.timeonsite ;;
  }
  dimension: timeonsite_tier {
    label: "Time On Site Tier"
    type: tier
    sql: ${TABLE}.timeonsite ;;
    tiers: [0,15,30,60,120,180,240,300,600]
    style: integer
  }
  measure: timeonsite_average_per_session {
    label: "Time On Site Average Per Session"
    type: number
    sql: 1.0 * ${timeonsite_total} / NULLIF(${ga_sessions.session_count},0) ;;
    value_format_name: decimal_2
  }

  measure: page_views_session {
    label: "PageViews Per Session"
    type: number
    sql: 1.0 * ${pageviews_total} / NULLIF(${ga_sessions.session_count},0) ;;
    value_format_name: decimal_2
  }

  measure: bounces_total {
    type: sum
    sql: ${TABLE}.bounces ;;
  }
  measure: bounce_rate {
    type:  number
    sql: 1.0 * ${bounces_total} / NULLIF(${ga_sessions.session_count},0) ;;
    value_format_name: percent_2
  }
  measure: transactions_count {
    type: sum_distinct
    sql_distinct_key: concat(${hits_item.transactionId},${hits_product.v2ProductName},${hits.id}) ;;
    sql: ${TABLE}.transactions ;;
  }
  dimension: transactions {
    sql: ${TABLE}.transactions ;;
  }
  measure: transactionRevenue_total {
    label: "Transaction Revenue Total"
    type: sum
    sql: (${TABLE}.transactionRevenue/1000000) ;;
    value_format_name: usd_0
    drill_fields: [transactions_count, transactionRevenue_total]
  }
  measure: newVisits_total {
    label: "New Visits Total"
    type: sum
    sql: ${TABLE}.newVisits ;;
  }
  measure: screenViews_total {
    label: "Screen Views Total"
    type: count
    sql_distinct_key: concat(${ga_sessions.id}, ${hits.id});;
  }
  measure: timeOnScreen_total{
    label: "Time On Screen Total"
    type: sum
    sql_distinct_key: concat(${hits.id},${hits_appInfo.screenName});;
    sql: ${TABLE}.timeOnScreen ;;
  }

  measure: average_timeOnScreen {
    label: "Average Time on Screen"
    type: number
    sql: 1.0 * (${timeOnScreen_total}/${uniqueScreenViews_total} );;
  }
  measure: uniqueScreenViews_total {
    label: "Unique Screen Views Total"
    type: count_distinct
  #  sql_distinct_key:${hits.id};;
    sql: ${TABLE}.uniqueScreenViews ;;
  }
  dimension: timeOnScreen_total_unique{
    label: "Time On Screen Total"
    type: number
    sql: ${TABLE}.timeOnScreen ;;
  }
}


view: trafficSource_base {
  extension: required

  dimension: addContent {}
#   dimension: adwords {}
  dimension: referralPath {label: "Referral Path"}
  dimension: campaign {}
  dimension: campaignCode {}
  dimension: source {}
  dimension: medium {}
  dimension: keyword {}
  dimension: adContent {label: "Ad Content"}
  measure: source_list {
    type: list
    list_field: source
  }
  measure: source_count {
    type: count_distinct
    sql: ${source} ;;
    drill_fields: [source, totals.hits, totals.pageviews]
  }
  measure: keyword_count {
    type: count_distinct
    sql: ${keyword} ;;
    drill_fields: [keyword, totals.hits, totals.pageviews]
  }
  # Subrecords
#   dimension: adwordsClickInfo {}
}

view: adwordsClickInfo_base {
  extension: required
  dimension: campaignId {label: "Campaign ID"}
  dimension: adGroupId {label: "Ad Group ID"}
  dimension: creativeId {label: "Creative ID"}
  dimension: criteriaId {label: "Criteria ID"}
  dimension: page {type: number}
  dimension: slot {}
  dimension: criteriaParameters {label: "Criteria Parameters"}
  dimension: gclId {}
  dimension: customerId {label: "Customer ID"}
  dimension: adNetworkType {label: "Ad Network Type"}
  dimension: targetingCriteria {label: "Targeting Criteria"}
  dimension: isVideoAd {
    label: "Is Video Ad"
    type: yesno
  }
}

view: device_base {
  extension: required

  dimension: browser {}
  dimension: browserVersion {label:"Browser Version"}
  dimension: operatingSystem {
    label: "Operating System"
    suggestions: ["iOS","Windows","Android","Macintosh","Linux","Chrome OS"]}
  dimension: operatingSystemVersion {label: "Operating System Version"}
  dimension: isMobile {label: "Is Mobile"
    type: yesno}
  dimension: flashVersion {label: "Flash Version"}
  dimension: javaEnabled {
    label: "Java Enabled"
    type: yesno
  }
  dimension: language {}
  dimension: screenColors {label: "Screen Colors"}
  dimension: screenResolution {label: "Screen Resolution"}
  dimension: mobileDeviceBranding {label: "Mobile Device Branding"}
  dimension: mobileDeviceInfo {label: "Mobile Device Info"}
  dimension: mobileDeviceMarketingName {label: "Mobile Device Marketing Name"}
  dimension: mobileDeviceModel {label: "Mobile Device Model"}
  dimension: mobileDeviceInputSelector {label: "Mobile Device Input Selector"}
  dimension: deviceCategory {
    label: "Device Category"
    suggestions: ["mobile","tablet","desktop"]
    }
}

view: hits_base {
  extension: required
  dimension: id {
    primary_key: yes
    sql: CONCAT(${ga_sessions.id},'|',FORMAT('%05d',${hitNumber})) ;;
  }
  dimension: hitNumber {
    type: number
  }
  dimension: type {}
  dimension: isexit { type:yesno}
  dimension: time {}
  dimension_group: hit {
    timeframes: [date,day_of_week,fiscal_quarter,week,month,year,month_name,month_num,week_of_year]
    type: time
    sql: TIMESTAMP_MILLIS(${ga_sessions.visitStartSeconds}*1000 + ${TABLE}.time) ;;
  }
  dimension: hour {}
  dimension: minute {}
  dimension: isSecure {
    label: "Is Secure"
    type: yesno
  }
  dimension: isiInteraction {
    label: "Is Interaction"
    type: yesno
  }
  dimension: referer {}

  measure: count {
    type: count
    drill_fields: [hits.detail*]
  }

  # subrecords
  dimension: page {hidden:yes}
  dimension: transaction {hidden:yes}
  dimension: item {hidden:yes}
  dimension: contentinfo {hidden:yes}
  dimension: social {hidden: yes}
  dimension: publisher {hidden: yes}
  dimension: appInfo {hidden: yes}
  dimension: contentInfo {hidden: yes}
  dimension: customDimensions {hidden: yes}
  dimension: customMetrics {hidden: yes}
  dimension: customVariables {hidden: yes}
  dimension: ecommerceAction {hidden: yes}
  dimension: eventInfo {hidden:yes}
  dimension: exceptionInfo {hidden: yes}
  dimension: experiment {hidden: yes}
  dimension: contentGroup {hidden: yes}
  dimension: latencyTracking {hidden: yes}
  dimension: product {hidden:yes}

  set: detail {
    fields: [ga_sessions.id, ga_sessions.visitnumber, ga_sessions.session_count, hits_page.pagePath, hits.pageTitle]
  }
}
view: hits_contentGroup_base {
  extension: required
  dimension: id {
    primary_key: yes
    sql: CONCAT(${ga_sessions.id},'|',FORMAT('%05d',${hits.hitNumber})) ;;
  }
  dimension: contentGroup1 {}
  dimension: contentGroup2 {}
  dimension: contentGroup3 {
    label: "Pagename"
  }
  dimension: contentGroup4 {}
  dimension: contentGroup5 {}
}
view: hits_product_base {
  extension: required
  dimension: productSKU {}
  dimension: v2ProductName {}
  dimension: Product {
    label: "Product Name"
    sql:
    Case WHEN ${v2ProductName} = 'Franchise Meetings' THEN ${v2ProductName}
     WHEN REGEXP_Contains(LOWER(${v2ProductName}), 'meetings') THEN 'Studio'
    WHEN regexp_contains(lower(${v2ProductName}), 'online') THEN 'Digital'
    WHEN regexp_contains(lower(${v2ProductName}), 'coaching') THEN 'Coaching' ELSE Null END ;;
  }
  dimension: customDimensions {hidden:yes}
  dimension: csp {
   sql: (SELECT value FROM UNNEST(${hits_product.customDimensions}) WHERE index=50) ;;

  }
}
#view: hits_product_customdimensions_base {
#  extension: required
#  dimension: index {type:number}
#  dimension: value {}
#  dimension: csp {
#    type: string
#    sql: case WHEN ${index} = 50 THEN ${value} ELSE NULL END;;
#  }
#}
view: hits_page_base {
  extension: required
  dimension: pagePath {
    label: "Page Path"
    link: {
      label: "Link"
      url: "{{ value }}"
    }
    link: {
      label: "Page Info Dashboard"
      url: "/dashboards/101?Page%20Path={{ value | encode_uri}}"
      icon_url: "http://www.looker.com/favicon.ico"
    }
  }
  dimension: hostName {label: "Host Name"}
  dimension: pageTitle {label: "Page Title"}
  dimension: searchKeyword {label: "Search Keyword"}
  dimension: searchCategory{label: "Search Category"}

}

view: hits_transaction_base {
  extension: required

  dimension: id {
    primary_key: yes
    sql: ${hits.id} ;;
  }
  dimension: transactionShipping {label: "Transaction Shipping"}
  dimension: affiliation {}
  dimension: curencyCode {label: "Curency Code"}
  dimension: localTransactionRevenue {label: "Local Transaction Revenue"}
  dimension: localTransactionTax {label: "Local Transaction Tax"}
  dimension: localTransactionShipping {label: "Local Transaction Shipping"}
}

view: hits_latency_base {
  extension: required
  # dimension:  id {
  #   primary_key: yes
  #   sql: ${hits.id} ;;
  # }
  # dimension: page_time_percentile {
  # type: tier
  #   sql: ${domInteractiveTime};;
  #   tiers: [1,2,5,10]
  # }

  # dimension: custom_tiering_page_time {
  #   type: string
  #   sql: CASE WHEN ${domInteractiveTime} < {% parameter load_time_1 %} THEN 'Low'
  #   WHEN ${domInteractiveTime} >= {% parameter load_time_1 %} AND  THEN 'Low' ;;
  # }

  parameter: load_time_1 {
     type: number
  }
   parameter: load_time_2 {
     type: number
   }
   parameter: load_time_3 {
    type: number
   }
   parameter: load_time_4 {
     type: number
   }



  dimension: domInteractiveTime {
    type: number
    sql: ${TABLE}.domInteractiveTime/1000.0 ;;
  }
  dimension: pageLoadTime {}
  dimension: pageDownloadTime {}
  }

view: hits_item_base {
  extension: required

  dimension: id {
    primary_key: yes
    sql: ${hits.id} ;;
  }
  dimension: transactionId {label: "Transaction ID"}
  dimension: productName {
    label: "Product Name"
    }

  dimension: productCategory {label: "Product Catetory"}
  dimension: productSku {label: "Product Sku"}

  dimension: itemQuantity {
    description: "Should only be used as a dimension"
    label: "Item Quantity"
    hidden: yes
    }
  dimension: itemRevenue {
    description: "Should only be used as a dimension"
    label: "Item Revenue"
    hidden: yes
    }
  dimension: curencyCode {label: "Curency Code"}
  dimension: localItemRevenue {
    label:"Local Item Revenue"
    description: "Should only be used as a dimension"
    }

  measure: product_count {
    type: count_distinct
    sql: ${productSku} ;;
    drill_fields: [productName, productCategory, productSku, total_item_revenue]
  }
}

view: hits_social_base {
  extension: required   ## THESE FIELDS WILL ONLY BE AVAILABLE IF VIEW "hits_social" IN GA CUSTOMIZE HAS THE "extends" parameter declared

  dimension: socialInteractionNetwork {label: "Social Interaction Network"}
  dimension: socialInteractionAction {label: "Social Interaction Action"}
  dimension: socialInteractions {label: "Social Interactions"}
  dimension: socialInteractionTarget {label: "Social Interaction Target"}
  dimension: socialNetwork {label: "Social Network"}
  dimension: uniqueSocialInteractions {
    label: "Unique Social Interactions"
    type: number
  }
  dimension: hasSocialSourceReferral {label: "Has Social Source Referral"}
  dimension: socialInteractionNetworkAction {label: "Social Interaction Network Action"}
}

view: hits_publisher_base {
  extension: required    ## THESE FIELDS WILL ONLY BE AVAILABLE IF VIEW "hits_publisher" IN GA CUSTOMIZE HAS THE "extends" parameter declared

  dimension: dfpClicks {}
  dimension: dfpImpressions {}
  dimension: dfpMatchedQueries {}
  dimension: dfpMeasurableImpressions {}
  dimension: dfpQueries {}
  dimension: dfpRevenueCpm {}
  dimension: dfpRevenueCpc {}
  dimension: dfpViewableImpressions {}
  dimension: dfpPagesViewed {}
  dimension: adsenseBackfillDfpClicks {}
  dimension: adsenseBackfillDfpImpressions {}
  dimension: adsenseBackfillDfpMatchedQueries {}
  dimension: adsenseBackfillDfpMeasurableImpressions {}
  dimension: adsenseBackfillDfpQueries {}
  dimension: adsenseBackfillDfpRevenueCpm {}
  dimension: adsenseBackfillDfpRevenueCpc {}
  dimension: adsenseBackfillDfpViewableImpressions {}
  dimension: adsenseBackfillDfpPagesViewed {}
  dimension: adxBackfillDfpClicks {}
  dimension: adxBackfillDfpImpressions {}
  dimension: adxBackfillDfpMatchedQueries {}
  dimension: adxBackfillDfpMeasurableImpressions {}
  dimension: adxBackfillDfpQueries {}
  dimension: adxBackfillDfpRevenueCpm {}
  dimension: adxBackfillDfpRevenueCpc {}
  dimension: adxBackfillDfpViewableImpressions {}
  dimension: adxBackfillDfpPagesViewed {}
  dimension: adxClicks {}
  dimension: adxImpressions {}
  dimension: adxMatchedQueries {}
  dimension: adxMeasurableImpressions {}
  dimension: adxQueries {}
  dimension: adxRevenue {}
  dimension: adxViewableImpressions {}
  dimension: adxPagesViewed {}
  dimension: adsViewed {}
  dimension: adsUnitsViewed {}
  dimension: adsUnitsMatched {}
  dimension: viewableAdsViewed {}
  dimension: measurableAdsViewed {}
  dimension: adsPagesViewed {}
  dimension: adsClicked {}
  dimension: adsRevenue {}
  dimension: dfpAdGroup {}
  dimension: dfpAdUnits {}
  dimension: dfpNetworkId {}
}

view: hits_appInfo_base {
  extension: required

  dimension: name {}
  dimension: version {}
  dimension: id {}
  dimension: installerId {}
  dimension: appInstallerId {}
  dimension: appName {}
  dimension: appVersion {}
  dimension: appId {}
  dimension: screenName {}
  dimension: gxp_screens {
    hidden: yes
    suggestions: ["gxp_welcome","gxp_overview","gxp_food","gxp_activity","gxp_connect","gxp_rewards"]
    sql: ${screenName}
    ;;
  }
  dimension: landingScreenName {}
  dimension: exitScreenName {}
  dimension: screenDepth {}
}

view: contentInfo_base {
  extension: required
  dimension: contentDescription {}
}

view: hits_customDimensions_base {
  extension: required
  dimension: index {type:number}
  dimension: siteRegionHit {
    type:string
    sql: CASE WHEN ${index} = 3 THEN UPPER(${value}) ELSE NULL END;;
    map_layer_name: countries
    }

  dimension: memberID {
    type: string
    sql:CASE WHEN ${index} = 12 THEN ${value} ELSE NULL END;;
  }

  dimension: productOwned {
    type: string
    sql: CASE WHEN ${index} = 10 THEN ${value} ELSE NULL END ;;
  }

  dimension: group_id {
    type: string
    sql: CASE WHEN ${index} = 85 THEN ${value} ELSE NULL END ;;
  }

  measure: groups_users {
    type: count_distinct
    sql: (CASE WHEN length(${group_id})>5 then ${memberID} end) ;;

  }

  dimension: value {}
 # dimension: application_type {
 #   type: string
 #   sql: CASE WHEN ${index} = 1 then LOWER(${value}) else null end ;;
 # }
}

view: hits_customMetrics_base {
  extension: required

  dimension: index {type:number}
  dimension: value {}
}

view: hits_customVariables_base {
  extension: required
  dimension: customVarName {}
  dimension: customVarValue {}
  dimension: index {type:number}
}

view: hits_eCommerceAction_base {
  extension: required
  dimension: action_type {}
  dimension: option {}
  dimension: step {}
}

view: hits_eventInfo_base {
  extension: required
  dimension: eventCategory {label: "Event Category"}

  dimension: eventAction {label: "Event Action"}
  dimension: eventLabel {label: "Event Label"}
  dimension: eventValue {label: "Event Category"}

}

# view: hits_sourcePropertyInfo {
# #   extension: required
#   dimension: sourcePropertyDisplayName {label: "Property Display Name"}
# }



view: customDimensions_base  {
  extension: required

 # dimension: application_type {
   # sql: (select value from UNNEST(${TABLE}.customDimensions) Where index=1) ;;
  #}



}

# datagroup: daily_cache {
#   sql_trigger: select extract(day FROM current_date) ;;
# }

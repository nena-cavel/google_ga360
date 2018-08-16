# If necessary, uncomment the line below to include explore_source.
# include: "google_analytics_block.model.lkml"
view: dau_mau_derived {
  derived_table: {
    explore_source: ga_sessions {
      column: fullVisitorId {}
      column: site_region {}
      column: unique_visitors {}
      column: visitStartSeconds {}
      column: operatingSystem { field: device.operatingSystem }
      filters: {
        field: ga_sessions.partition_date
        value: "12 months ago for 12 months"
      }
      filters: {
        field: hits_appInfo.screenName
        value: "food_% ,Food_%,Food%,%activity%,Search%,journey%,connect%,Track,connect_%, crowdsourcing%, profile_%, QuickAdd, recipe%, MealDetails"
      }
      filters: {
        field: device.operatingSystem
        value: "iOS,Android"
      }
      filters: {
        field: ga_sessions.site_region
        value: "us,de,fr,ca,br,se,be,nl,ch,au,nz"
      }
    }
  }
  dimension: unique_visitors {
    label: "Session Unique Visitors"
    type: number
  }
  dimension: site_region {
    label: "Session Site Region"
  }
  dimension: visitStartSeconds{
    label: "Session Visit Start Date"
  }
  dimension_group: visitStartmonth {
      timeframes: [month,year,month_name,month_num,day_of_month]
      label: "Visit Start Month"
      type: time
      sql: (TIMESTAMP(${visitStartSeconds})) ;;
    }

  dimension_group: dayofmonth {
  timeframes: [date]
  label: "date of visit start"
  type:  time
  sql:  (TIMESTAMP(${visitStartSeconds}))  ;;
  }

  dimension: operatingSystem {
    label: "Session: Device Operating System"
  }
  dimension: visitorID {
    label: "Visitor ID"
  }
  dimension: fullVisitorId {
    label: "fullVisitorId"
  }


  measure: avg_daily_unique_visitors {
    type: sum
    sql: ${unique_visitors} ;;
  }
  measure: total_monthly_unique_visitors {
    type:  count_distinct
    sql: ${fullVisitorId} ;;
  }
  measure: count_of_days {
  type: count_distinct
  sql: ${dayofmonth_date};;
  }


}

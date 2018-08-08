# If necessary, uncomment the line below to include explore_source.
# include: "google_analytics_block.model.lkml"

view: dau_mau_derived {
  derived_table: {
    explore_source: ga_sessions {
      column: unique_visitors {}
      column: site_region {}
      column: visitStartSeconds {}
      column: operatingSystem { field: device.operatingSystem }
      filters: {
        field: ga_sessions.partition_date
        value: "1 months ago for 1 months"
      }
      filters: {
        field: hits_appInfo.screenName
        value: "food_% ,Food_%,%activity%,Search%,journey%,connect%"
      }
      filters: {
        field: device.operatingSystem
        value: "ios,Android"
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
  dimension: operatingSystem {
    label: "Session: Device Operating System"
  }
  measure: avg_daily_unique_visitors {
    type: average
    sql: ${unique_visitors} ;;

  }


}

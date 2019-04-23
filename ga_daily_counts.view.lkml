view: ga_daily_counts {
  derived_table: {
    # This derived table summarizes distinct active users at the weekly grain
    datagroup_trigger: daily_sessions_cache
    explore_source: ga_sessions {
      column: site_region {}
      column: unique_visitors {}
      column: visitStart_month {}
      column: application_type {}
      ### Step 3: Nena's filtered measure template
      column: connect_users {}
      column: groups_users {}
      column: group_id_new {
          field: hits_eventInfo.group_id_new
      }
      column: connect_likers {}
      column: connect_commenters {}
      column: connect_posters {}
      #column: unique_visitors_uuid {}
      filters: {
        field: ga_sessions.partition_date
        #value: "12 months ago for 12 months"
        value: "16 months ago for 13 months"
      }
      filters: {
        field: hits_appInfo.screenName
        value: "food_% ,Food_%,Food%,%activity%,Search%,journey%,connect%,Track,connect_%, crowdsourcing%, profile_%, QuickAdd, recipe%, Recipe, MemberFoods, More, MealDetails"
      }
      filters: {
        field: ga_sessions.application_type
        value: "iOS,Android, ios"
      }
      filters: {
        field: ga_sessions.site_region
        value: "us,de,gb,fr,ca,br,se,be,nl,ch,au,nz"
      }
    }
  }

  dimension: primary_key {
    type: string
    hidden: yes
    primary_key: yes
    sql: concat(cast(${visitStartmonth_date} as string),${site_region},${application_type}) ;;
  }

  dimension: unique_visitors {
    label: "Session Unique Visitors"
    type: number
  }



dimension: group_id_new {
  type: string
}

  dimension: site_region {
    label: "Session Site Region"
  }

  dimension: market_name {
    type: string
    sql: (case when ${site_region}='us' then 'United States'
                WHEN ${site_region}='de' then 'Germany'
                WHEN ${site_region}='gb' then 'UK'
                WHEN ${site_region}= 'ca' then 'Canada'
                WHEN ${site_region}='fr' then 'France'
                WHEN ${site_region}='nl' then 'Netherlands'
                when ${site_region}='be' then 'Belgium'
                WHEN ${site_region}='ch' then 'Switzerland'
                when ${site_region}='au' then 'ANZ'
                WHEN ${site_region}='nz' then 'ANZ'
                WHEN ${site_region}='se' then 'Sweden'
                when ${site_region}='br' then 'Brazil'
    END) ;;
  }
  dimension: visitStartSeconds{
    label: "Session Visit Start Date"
  }
  dimension_group: visitStartmonth {
    timeframes: [month,year,month_name,week, month_num,date, day_of_month]
    label: "Visit Start Month"
    type: time
    sql: visitStart_month ;;
    convert_tz: no
  }

  dimension_group: dayofmonth {
    timeframes: [date]
    label: "date of visit start"
    type:  time
    sql:  ((${visitStartSeconds}))  ;;
  }

  dimension: application_type {
    label: "Application Type"
  }
  dimension: visitorID {
    label: "Visitor ID"
  }
  dimension: fullVisitorId {
    label: "fullVisitorId"
  }


  measure: avg_daily_unique_visitors {
    type: sum
    hidden: yes
    sql: ${unique_visitors} ;;
  }
  measure: total_monthly_unique_visitors {
    type:  sum
    sql: ${unique_visitors} ;;
  }
  measure: count_of_days {
    type: count_distinct
    sql: ${dayofmonth_date};;
  }
### Step 4: Nena's filtered measure template
  measure: connect_users {
    type: sum
  }
  measure: groups_users {
    type: sum
  }

  measure: connect_likers {
    type: sum
  }

  measure: connect_commenters {
    type: sum
  }
  measure: connect_posters {
    type: sum
  }


}

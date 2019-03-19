view: rewards_screen_views {
    derived_table: {
      sql_trigger_value: select extract(year from current_date()) ;;
      explore_source: ga_sessions {
        column: visitStart_date {}
        column: memberID {}
        column: screenName { field: hits_appInfo.screenName }
        column: market {}
        column: count { field: hits.count }
        column: id {}
        filters: {
          field: ga_sessions.partition_date
          value: "12 weeks ago for 12 weeks"
        }
        filters: {
          field: ga_sessions.visitStart_date
          value: "12 weeks ago for 12 weeks"
        }
        filters: {
          field: hits_appInfo.screenName
          value: "rewards%"
        }
      }
    }
    # dimension: visitStart_date {
    #   label: "Session Visit Start Date"
    #   type: date
    # }

    dimension_group: visitStart_date {
      type: time
      timeframes: [
        raw,
        date,
        week,
        month,
        quarter,
        year
      ]
      convert_tz: no
      datatype: date
      # sql: ${TABLE}.thedate ;;
    }

    dimension: memberID {
      label: "Session Memberid"
    }
    dimension: screenName {
      label: "Session: Hits: App Info Screenname"
    }
    dimension: market {
      label: "Session Market"
    }

    dimension: country {
      suggestions: ["US","UK","CA","FR","DE"]
      type:  string
      sql: case when ${TABLE}.market = 'US' then "US"
                when ${TABLE}.market = 'DE' then "DE"
                when ${TABLE}.market = 'CA' then "CA"
                when ${TABLE}.market = 'FR' then "FR"
                -- UPDATE THIS ONCE YOU UPDATE YOUR PULL OF REWARDS SCREEN VIEW DATA
                when ${TABLE}.market in ('null','GB') then "UK"
                else null end ;;
    }

    measure: unique_member_count {
      type: count_distinct
      sql: ${TABLE}.memberID ;;
    }

    dimension: prize_language {
      suggestions: ["English", "French", "German"]
      type:  string
      sql: if(regexp_contains(${TABLE}.screenName, '(.+)_[a-z][a-z]_[a-z][a-z]'),
                case when substr(${TABLE}.screenName, -5, 2) = 'en' then 'English'
                     when substr(${TABLE}.screenName, -5, 2) = 'fr' then 'French'
                     when substr(${TABLE}.screenName, -5, 2) = 'de' then 'German'
                     else null end,
                    null) ;;
    }

  dimension: prize_string {
    type:  string
    sql: if(regexp_contains(${TABLE}.screenName, '(.+)_[a-z][a-z]_[a-z][a-z]'),
            -- substr(${TABLE}.screenName, 9, length(${TABLE}.screenName)-14), null)
             REGEXP_REPLACE(
                      replace(replace(substr(${TABLE}.screenName, 9, length(${TABLE}.screenName)-14),"-"," "),".","")
                      , r"[^[:alnum:][:space:]]", ' '),
            null) ;;
  }

    measure: count {
      label: "Session: Hits Count"
      type: count
    }
    dimension: id {
      label: "Session ID"
    }
  }

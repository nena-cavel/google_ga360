view: rewards_event_category_update {
  derived_table: {
    sql_trigger_value: select timestamp_sub(current_timestamp(), interval 10 hour) ;; # TEMPORARILY ONLY WANT THIS TO FIRE ONCE
    create_process: {
      sql_step: insert into ${rewards_event_category_base.SQL_TABLE_NAME}

      (ga_sessions_visitstart_date_1,
      ga_sessions_id,
      ga_sessions_memberid_1,
      hits_eventinfo_eventlabel_1,
      hits_appinfo_screenname_1)

      with rewards_event_category_update as
      (SELECT
          CAST((TIMESTAMP((CAST(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_SECONDS(ga_sessions.visitStarttime) , 'America/New_York')) AS DATE))))  AS DATE) AS ga_sessions_visitstart_date_1,
          CONCAT(CAST(ga_sessions.fullVisitorId AS STRING), '|', COALESCE(CAST(ga_sessions.visitId AS STRING),''))  AS ga_sessions_id,
          (SELECT value FROM UNNEST(ga_sessions.customdimensions) WHERE index=12) AS ga_sessions_memberid_1,
          hits_eventInfo.eventLabel AS hits_eventinfo_eventlabel_1,
          hits_appInfo.screenName AS hits_appinfo_screenname_1
        FROM (SELECT * FROM `wwi-datalake-1.wwi_ga_pond.ga_sessions` WHERE SUBSTR(suffix,0,1) != 'i')  AS ga_sessions
        LEFT JOIN UNNEST(ga_sessions.hits) as hits
        LEFT JOIN UNNEST([hits.appInfo]) as hits_appInfo
        LEFT JOIN UNNEST([hits.eventInfo]) as hits_eventInfo

        WHERE ((((CAST(CONCAT(SUBSTR(ga_sessions.suffix,0,4),'-',SUBSTR(ga_sessions.suffix,5,2),'-',SUBSTR(ga_sessions.suffix,7,2)) AS TIMESTAMP) ) >=
              ((TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY), INTERVAL -3 DAY)), 'America/New_York')))
          AND (CAST(CONCAT(SUBSTR(ga_sessions.suffix,0,4),'-',SUBSTR(ga_sessions.suffix,5,2),'-',SUBSTR(ga_sessions.suffix,7,2)) AS TIMESTAMP) ) <
              ((TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY), INTERVAL -2 DAY), INTERVAL 2 DAY)), 'America/New_York'))))))
          AND (((((TIMESTAMP((CAST(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_SECONDS(ga_sessions.visitStarttime) , 'America/New_York')) AS DATE)))) ) >=
              ((TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY), INTERVAL -3 DAY)))
          AND ((TIMESTAMP((CAST(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', TIMESTAMP_SECONDS(ga_sessions.visitStarttime) , 'America/New_York')) AS DATE)))) ) <
              ((TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY), INTERVAL -2 DAY), INTERVAL 2 DAY))))))

              AND (hits_eventInfo.eventCategory = 'rewards')
        GROUP BY 1,2,3,4,5)

      select * from rewards_event_category_update recu

      where recu.ga_sessions_id not in (select ga_sessions_id from ${rewards_event_category_base.SQL_TABLE_NAME}) ;;

      sql_step: CREATE TABLE ${SQL_TABLE_NAME} as (SELECT 1 as foo) ;;
        }
      }

      dimension: visitStart_date {
        label: "Session Visit Start Date"
        type: date
      }
      dimension: id {
        label: "Session ID"
      }
      dimension: memberID {
        label: "Session Memberid"
      }
      dimension: eventLabel {
        label: "Session: Hits: Events Info Event Label"
      }
      dimension: screenName {
        label: "Session: Hits: App Info Screenname"
      }

  ##### HERE ARE THE SOURCE, VARS & FILTERS YOU WOULD USE TO REPRODUCE REWARDS EVENT CATEGORY
  # explore_source: ga_sessions {
  #   column: visitStart_date {}
  #   column: id {}
  #   column: memberID {}
  #   column: eventLabel { field: hits_eventInfo.eventLabel }
  #   column: screenName { field: hits_appInfo.screenName }
  #   filters: {
  #     field: ga_sessions.partition_date
  #     value: "7 days ago for 7 days"
  #   }
  #   filters: {
  #     field: hits_eventInfo.eventCategory
  #     value: "rewards"
  #   }
  #   filters: {
  #     field: ga_sessions.visitStart_date
  #     value: "7 days"

    }

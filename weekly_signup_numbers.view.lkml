view: weekly_signup_numbers {
  derived_table: {
    sql: SELECT
        CAST(CAST(enrollment_date.CurrentWeekStart  AS TIMESTAMP) AS DATE) AS enrollment_date_current_week_start_date,
        substr(member.ClassicLocale,4,Length(member.ClassicLocale))  AS member_market_1,
        COALESCE(SUM(membership.NumberOfSignUps ), 0) AS membership_number_of_sign_ups
      FROM `wwi-datalake-1.CIE_star_schema.FactMembership`  AS membership
      INNER JOIN `wwi-datalake-1.CIE_star_schema.DimDate`  AS enrollment_date ON membership.EnrollmentDateID =enrollment_date.DateID
      INNER JOIN `wwi-datalake-1.CIE_star_schema.DimProduct`  AS product ON membership.ProductID = product.ProductID
      INNER JOIN `wwi-datalake-1.CIE_star_schema.DimMember`  AS member ON membership.MemberID = member.MemberID

      WHERE ((((enrollment_date.CurrentWeekEnd ) >= ((DATE(TIMESTAMP_TRUNC(CAST(TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(CAST(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY) AS TIMESTAMP), DAY), INTERVAL (0 - CAST((EXTRACT(DAYOFWEEK FROM TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY)) - 1) AS INT64)) DAY), INTERVAL (-68 * 7) DAY) AS TIMESTAMP), DAY)))) AND (enrollment_date.CurrentWeekEnd ) < ((DATE(TIMESTAMP_TRUNC(CAST(TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(CAST(TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY) AS TIMESTAMP), DAY), INTERVAL (0 - CAST((EXTRACT(DAYOFWEEK FROM TIMESTAMP_TRUNC(TIMESTAMP(FORMAT_TIMESTAMP('%F %T', CURRENT_TIMESTAMP(), 'America/New_York')), DAY)) - 1) AS INT64)) DAY), INTERVAL (-68 * 7) DAY), INTERVAL (68 * 7) DAY) AS TIMESTAMP), DAY))))))) AND (product.Category <> 'e-Tools' OR product.Category IS NULL) AND (product.RoleGroupName <> 'Online iTunes' OR product.RoleGroupName IS NULL)
      GROUP BY 1,2
      ORDER BY 1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: enrollment_date_current_week_start_date1 {
    type: string
    sql: ${TABLE}.enrollment_date_current_week_start_date ;;
  }

  dimension: enrollment_date_current_week_start_date {
    type: string
    sql: ${enrollment_date_current_week_start_date1} ;;
  }

  dimension: member_market_1 {
    type: string
    sql: ${TABLE}.member_market_1 ;;
  }

  measure: membership_number_of_sign_ups {
    type: sum_distinct
    sql: ${TABLE}.membership_number_of_sign_ups ;;
    sql_distinct_key: concat(cast(${enrollment_date_current_week_start_date} as string),${member_market_1}) ;;
  }

  set: detail {
    fields: [enrollment_date_current_week_start_date, member_market_1, membership_number_of_sign_ups]
  }
}

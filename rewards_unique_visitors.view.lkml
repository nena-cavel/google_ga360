view: rewards_unique_visitors {
#     # If necessary, uncomment the line below to include explore_source.
# # include: "google_analytics_block.model.lkml"
#
#     derived_table: {
#       explore_source: ga_sessions {
#         column: unique_visitors {}
#         filters: {
#           field: ga_sessions.partition_date
#           value: "7 days ago for 7 days"
#         }
#         filters: {
#           field: hits_appInfo.appVersion
#           value: "7.%"
#         }
#         filters: {
#           field: device.browser
#           value: "GoogleAnalytics"
#         }
#       }
#     }
#
#     dimension: partition_date {
#       primary_key: yes
#     }
#     measure: unique_visitors {
#       label: "Session Unique Visitors"
#       type: max
#     }
#
}

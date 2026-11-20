connection: "snowflake-dwh"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/dashboards/*.dashboard.lookml"    # LookML dashboards

explore: american_family_care_search_looker_table {}
explore: american_family_care_ad_works_looker_table { label: "AFC Ad.Works" }

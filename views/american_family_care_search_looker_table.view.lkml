# =============================================================================
# AFC Search dashboard - metric layer, parameters and drills
#
# FULL VIEW. Replaces the wizard-generated file: paste this into
# views/american_family_care_search_looker_table.view.lkml (same name, same
# field names as the generated output), so no refinement or include is needed.
#
# Grain: Date x Account x Campaign x Ad group x Device x Conversion action x Source
#
# Two filters behave differently on purpose:
#   date_range          templated. Use on tiles with *_cur / *_prior / *_delta
#                       measures; other tiles take the dashboard date filter
#                       on date_date.
#   conversion_actions  templated. Moves conversion and revenue measures only.
#                       Filtering conversion_type directly would drop the
#                       'Static Metrics' rows that carry all spend and clicks.
# =============================================================================

view: american_family_care_search_looker_table {
  sql_table_name: "DBO"."AmericanFamilyCare_Search_Looker_table" ;;

  ######## PRIMARY KEY ########

  # No Row_Key column in the table: the key is generated here from the grain columns.
  dimension: row_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: MD5(CONCAT_WS('|',
           COALESCE(${TABLE}."Date"::VARCHAR, ''), COALESCE(${TABLE}."Account_ID", ''),
           COALESCE(${TABLE}."Campaign_ID", ''),   COALESCE(${TABLE}."AdGroup_ID", ''),
           COALESCE(${TABLE}."Device", ''),        COALESCE(${TABLE}."Conversion_Type", ''),
           COALESCE(${TABLE}."Conversion_ID", ''), COALESCE(${TABLE}."Source", ''))) ;;
  }

  ######## DIMENSIONS - DATE ########

  dimension_group: date {
    type: time
    convert_tz: no
    datatype: date
    sql: ${TABLE}."Date" ;;
    timeframes: [raw, date, week, month, quarter, year]
    drill_fields: [date_date]
  }

  dimension: day { type: string sql: ${TABLE}."Day" ;;
    group_label: "Date"
    label: "Day of the week"
    order_by_field: day_of_week_num
  }

  # Sort helpers for Day and Month names (Mon = 1 ... Sun = 7, Jan = 1 ... Dec = 12)
  dimension: day_of_week_num {
    hidden: yes
    type: number
    sql: DAYOFWEEKISO(${TABLE}."Date") ;;
  }

  dimension: month_num {
    hidden: yes
    type: number
    sql: MONTH(${TABLE}."Date") ;;
  }

  # Generated as type: string. Cast so date maths and sorting work.
  dimension: week_start {
    group_label: "Date"
    label: "Week start (Mon)"
    type: date
    convert_tz: no
    datatype: date
    sql: TRY_TO_DATE(${TABLE}."Week_Start"::VARCHAR) ;;
    drill_fields: [date_date]
  }

  dimension: week_end {
    group_label: "Date"
    label: "Week end (Sun)"
    type: date
    convert_tz: no
    datatype: date
    sql: TRY_TO_DATE(${TABLE}."Week_End"::VARCHAR) ;;
  }

  dimension: week_of_year {
    group_label: "Date"
    label: "Week number"
    type: number
    sql: TRY_TO_NUMBER(${TABLE}."Week_of_Year"::VARCHAR) ;;
    value_format_name: id
  }

  dimension: week_label {
    group_label: "Date"
    label: "Week"
    description: "W40, 28 Sep to 04 Oct."
    type: string
    sql: 'W' || ${week_of_year} || ', ' || TO_CHAR(TRY_TO_DATE(${TABLE}."Week_Start"::VARCHAR), 'DD Mon')
         || ' to ' || TO_CHAR(TRY_TO_DATE(${TABLE}."Week_End"::VARCHAR), 'DD Mon') ;;
    order_by_field: week_start
  }

  dimension: month { type: string sql: ${TABLE}."Month" ;;
    group_label: "Date"
    label: "Month name"
    description: "Month name as stored in the table. Budget is matched on it."
    order_by_field: month_num
  }

  dimension: year { type: number sql: ${TABLE}."Year" ;;
    group_label: "Date"
    value_format_name: id
  }

  dimension: is_weekend {
    group_label: "Date"
    label: "Is weekend"
    type: yesno
    sql: DAYOFWEEKISO(${TABLE}."Date") IN (6, 7) ;;
  }

  dimension: is_complete_week {
    group_label: "Date"
    label: "Is complete week"
    description: "The week's Sunday is on or before the latest day with performance data."
    type: yesno
    sql: TRY_TO_DATE(${TABLE}."Week_End"::VARCHAR) <= ${cmp_data_end} ;;
  }

  dimension: is_complete_month {
    group_label: "Date"
    label: "Is complete month"
    type: yesno
    sql: LAST_DAY(${TABLE}."Date") <= ${cmp_data_end} ;;
  }

  ######## DIMENSIONS - ACCOUNT & MAPPING ########

  dimension: client        { type: string sql: ${TABLE}."Client" ;; group_label: "Account" }
  dimension: client_id     { type: string sql: ${TABLE}."Client_ID" ;; group_label: "Account" label: "Client ID" }
  dimension: publisher     { type: string sql: ${TABLE}."Publisher" ;; group_label: "Account" }
  dimension: account_id    { type: string sql: ${TABLE}."Account_ID" ;; group_label: "Account" label: "Account ID" }
  dimension: engine        { type: string sql: ${TABLE}."Engine" ;; group_label: "Mapping" }

  dimension: account { type: string sql: ${TABLE}."Account" ;;
    group_label: "Account"
    description: "Google Ads account. Two roll-up accounts today, potentially one per clinic later."
    drill_fields: [campaign, condition, budget_group, device]
  }

  dimension: region { type: string sql: ${TABLE}."Region" ;;
    group_label: "Mapping"
    description: "NE or SE, from the campaign mapping sheet. Budget is matched on this field."
    drill_fields: [account, condition, budget_group, campaign]
  }

  dimension: region_name {
    group_label: "Mapping"
    label: "Region name"
    type: string
    sql: CASE ${region} WHEN 'NE' THEN 'Northeast' WHEN 'SE' THEN 'Southeast' ELSE ${region} END ;;
    drill_fields: [account, condition, budget_group, campaign]
  }

  dimension: account_group { type: string sql: ${TABLE}."Account Group" ;;
    group_label: "Mapping"
    label: "Account group"
    drill_fields: [region, account, campaign]
  }

  dimension: mapping_channel { type: string sql: ${TABLE}."Mapping_Channel" ;;
    group_label: "Mapping"
    label: "Mapping Channel"
    description: "Brand, NonBrand or PMax. AFC's own grouping from the mapping sheet."
    drill_fields: [condition, campaign]
  }

  dimension: condition { type: string sql: ${TABLE}."Condition" ;;
    group_label: "Mapping"
    drill_fields: [region, campaign]
  }

  dimension: budget_group { type: string sql: ${TABLE}."Budget Group" ;;
    group_label: "Mapping"
    label: "Budget group"
    drill_fields: [region, campaign]
  }

  dimension: is_mapped {
    group_label: "Mapping"
    label: "Is mapped"
    description: "No means the campaign name is missing from the mapping sheet."
    type: yesno
    sql: ${region} <> 'Unmapped' ;;
  }

  dimension: market {
    group_label: "Mapping"
    label: "Market (inferred)"
    description: "Proposed stand-in for DMA, read from the metro code or clinic town in the campaign name. Replace with a clinic-to-DMA lookup when available."
    type: string
    sql: CASE
           WHEN REGEXP_SUBSTR(${campaign}, 'goog-corp-[a-z]{2}-[a-z]{2}-([a-z]{3})-', 1, 1, 'e', 1) IN ('bos', 'wrc') THEN 'Boston'
           WHEN REGEXP_SUBSTR(${campaign}, 'goog-corp-[a-z]{2}-[a-z]{2}-([a-z]{3})-', 1, 1, 'e', 1) = 'spg' THEN 'Springfield-Holyoke'
           WHEN REGEXP_SUBSTR(${campaign}, 'goog-corp-[a-z]{2}-[a-z]{2}-([a-z]{3})-', 1, 1, 'e', 1) = 'ccc' THEN 'Providence-New Bedford'
           WHEN REGEXP_SUBSTR(${campaign}, 'goog-corp-[a-z]{2}-[a-z]{2}-([a-z]{3})-', 1, 1, 'e', 1) = 'hfd' THEN 'Hartford-New Haven'
           WHEN ${campaign} ILIKE ANY ('%danbury%') THEN 'New York'
           WHEN ${campaign} ILIKE ANY ('%dedham%', '%saugus%', '%malden%', '%worcester%', '%marlborough%') THEN 'Boston'
           WHEN ${campaign} ILIKE ANY ('%springfield%') THEN 'Springfield-Holyoke'
           WHEN ${campaign} ILIKE ANY ('%new_bedford%') THEN 'Providence-New Bedford'
           WHEN ${campaign} ILIKE ANY ('%hartford%', '%rocky_hill%', '%vernon%', '%southington%', '%new_britain%', '%torrington%') THEN 'Hartford-New Haven'
           WHEN ${campaign} ILIKE ANY ('%northeast%') THEN 'Multi-market'
           ELSE 'Unassigned'
         END ;;
    drill_fields: [campaign]
  }

  ######## DIMENSIONS - CAMPAIGN STRUCTURE ########

  dimension: channel { type: string sql: ${TABLE}."Channel" ;;
    group_label: "Campaign"
    label: "Channel"
    description: "Platform channel: Google's campaign type (Search, Performance Max, App)."
    drill_fields: [mapping_channel, campaign]
  }

  dimension: campaign { type: string sql: ${TABLE}."Campaign" ;;
    group_label: "Campaign"
    drill_fields: [ad_group, device, date_date]
  }

  dimension: campaign_id { type: string sql: ${TABLE}."Campaign_ID" ;; group_label: "Campaign" label: "Campaign ID" }

  dimension: ad_group { type: string sql: ${TABLE}."AdGroup" ;;
    group_label: "Campaign"
    label: "Ad group"
    description: "Always 'Performance Max' for PMax campaigns."
    drill_fields: [device, date_date]
  }

  dimension: ad_group_id { type: string sql: ${TABLE}."AdGroup_ID" ;; group_label: "Campaign" label: "Ad group ID" }

  dimension: device { type: string sql: ${TABLE}."Device" ;;
    group_label: "Campaign"
    drill_fields: [campaign, date_date]
  }

  ######## DIMENSIONS - CONVERSION ACTIONS ########

  dimension: conversion_type { type: string sql: ${TABLE}."Conversion_Type" ;;
    group_label: "Conversion"
    label: "Conversion action"
    description: "Google Ads conversion action. 'Static Metrics' rows carry spend and traffic, not conversions. Filter with conversion_actions, not this field."
  }

  dimension: conversion_id { type: string sql: ${TABLE}."Conversion_ID" ;; group_label: "Conversion" label: "Conversion action ID" }

  dimension: conversion_family {
    group_label: "Conversion"
    label: "Conversion action family"
    description: "Conversion actions grouped for reporting. Spend and traffic sit under 'Static metrics', so only use this with conversion measures."
    type: string
    sql: CASE
           WHEN ${conversion_type} = 'Static Metrics'             THEN 'Static metrics'
           WHEN ${conversion_type} ILIKE '%schedule_appointment%' THEN 'Schedule appointment'
           WHEN ${conversion_type} ILIKE '%direction%'            THEN 'Directions'
           WHEN ${conversion_type} ILIKE '%call%'                 THEN 'Calls'
           WHEN ${conversion_type} ILIKE '%leads (%'              THEN 'Clinic leads'
           WHEN ${conversion_type} ILIKE 'local actions%'         THEN 'Other local actions'
           ELSE 'Other'
         END ;;
    drill_fields: [conversion_type]
  }

  filter: conversion_actions {
    group_label: "Conversion"
    label: "Conversion actions"
    description: "Which action families count as Engine conversions. Empty = proposed definition: appointments, calls and clinic leads."
    type: string
    suggestions: ["Schedule appointment", "Calls", "Clinic leads", "Directions", "Other local actions", "Other"]
  }

  dimension: conversion_in_definition {
    group_label: "Conversion"
    label: "Counted as engine conversion"
    type: yesno
    sql: {% if conversion_actions._is_filtered %}
           {% condition conversion_actions %} ${conversion_family} {% endcondition %}
         {% else %}
           ${conversion_family} IN ('Schedule appointment', 'Calls', 'Clinic leads')
         {% endif %} ;;
  }

  ######## DIMENSIONS - TECHNICAL ########

  dimension: source { type: string sql: ${TABLE}."Source" ;;
    group_label: "Technical"
    description: "Which branch of the SQL produced the row. 'Budget' rows carry budget only."
  }

  dimension: is_budget_row {
    group_label: "Technical"
    label: "Is budget row"
    type: yesno
    sql: ${source} = 'Budget' ;;
  }

  dimension: is_performance_row {
    hidden: yes
    type: yesno
    sql: COALESCE(${source}, '') <> 'Budget' ;;
  }

  dimension: has_impression_share {
    hidden: yes
    type: yesno
    sql: ZEROIFNULL(${available_impressions}) > 0 ;;
  }

  dimension: has_click_share {
    hidden: yes
    type: yesno
    sql: ZEROIFNULL(${available_clicks}) > 0 ;;
  }

  ######## RAW NUMBERS (hidden, use the measures) ########

  dimension: impressions { type: number sql: ${TABLE}."Impressions" ;; hidden: yes }
  dimension: clicks { type: number sql: ${TABLE}."Clicks" ;; hidden: yes }
  dimension: cost { type: number sql: ${TABLE}."Cost" ;; hidden: yes }
  dimension: video_views { type: number sql: ${TABLE}."Video_Views" ;; hidden: yes }
  dimension: video_completions { type: number sql: ${TABLE}."Video_Completions" ;; hidden: yes }
  dimension: available_impressions { type: number sql: ${TABLE}."Available_Impressions" ;; hidden: yes }
  dimension: search_impressions_lost_to_rank { type: number sql: ${TABLE}."Search_Impressions_Lost_to_Rank" ;; hidden: yes }
  dimension: search_impressions_lost_to_budget { type: number sql: ${TABLE}."Search_Impressions_Lost_to_Budget" ;; hidden: yes }
  dimension: available_clicks { type: number sql: ${TABLE}."Available_Clicks" ;; hidden: yes }
  dimension: clickthrough_conversions { type: number sql: ${TABLE}."Click-through_Conversions" ;; hidden: yes }
  dimension: viewthrough_conversions { type: number sql: ${TABLE}."View-through_Conversions" ;; hidden: yes }
  dimension: total_conversions { type: number sql: ${TABLE}."Total_Conversions" ;; hidden: yes }
  dimension: revenue { type: number sql: ${TABLE}."Revenue" ;; hidden: yes }
  dimension: budget { type: number sql: ${TABLE}."Budget" ;; hidden: yes }
  measure: count { hidden: yes type: count }

  ######## PARAMETERS ########

  # One parameter can feed many tiles: each dashboard filter that targets it
  # sets it for the tiles it listens to, so tiles stay independent.

  filter: date_range {
    group_label: "Controls"
    label: "Date range (comparison tiles)"
    description: "Templated. Map the dashboard Date range filter to this field on tiles that use *_cur, *_prior or *_delta measures."
    type: date
  }

  parameter: comparison_mode {
    group_label: "Controls"
    label: "Compare"
    description: "What the *_cur window is compared with: the previous period of the same length, the same period last year, or nothing."
    type: unquoted
    default_value: "prev"
    allowed_value: { label: "Previous period (same length)"              value: "prev" }
    allowed_value: { label: "Same period last year"                      value: "py" }
    allowed_value: { label: "No comparison"                              value: "none" }
  }

  parameter: delta_format {
    group_label: "Controls"
    label: "Show delta as"
    type: unquoted
    default_value: "pct"
    allowed_value: { label: "% change"        value: "pct" }
    allowed_value: { label: "Absolute change" value: "abs" }
  }

  parameter: date_granularity {
    group_label: "Controls"
    label: "Granularity"
    type: unquoted
    default_value: "day"
    allowed_value: { label: "Day"   value: "day" }
    allowed_value: { label: "Week"  value: "week" }
    allowed_value: { label: "Month" value: "month" }
  }

  parameter: dimension_selector_1 {
    group_label: "Controls"
    label: "Dimension 1"
    description: "Rows / bars of breakdown charts."
    type: unquoted
    default_value: "condition"
    allowed_value: { label: "Region" value: "regionName" }
    allowed_value: { label: "Account" value: "account" }
    allowed_value: { label: "Account group" value: "accountGroup" }
    allowed_value: { label: "Channel" value: "channel" }
    allowed_value: { label: "Mapping Channel" value: "mappingChannel" }
    allowed_value: { label: "Condition" value: "condition" }
    allowed_value: { label: "Budget group" value: "budgetGroup" }
    allowed_value: { label: "Campaign" value: "campaign" }
    allowed_value: { label: "Ad group" value: "adGroup" }
    allowed_value: { label: "Device" value: "device" }
    allowed_value: { label: "Market (inferred)" value: "market" }
    allowed_value: { label: "Conversion action family" value: "conversionFamily" }
    allowed_value: { label: "Day of the week" value: "day" }
  }

  parameter: dimension_selector_2 {
    group_label: "Controls"
    label: "Dimension 2"
    description: "Series / colour of breakdown charts."
    type: unquoted
    default_value: "mappingChannel"
    allowed_value: { label: "Region" value: "regionName" }
    allowed_value: { label: "Account" value: "account" }
    allowed_value: { label: "Account group" value: "accountGroup" }
    allowed_value: { label: "Channel" value: "channel" }
    allowed_value: { label: "Mapping Channel" value: "mappingChannel" }
    allowed_value: { label: "Condition" value: "condition" }
    allowed_value: { label: "Budget group" value: "budgetGroup" }
    allowed_value: { label: "Campaign" value: "campaign" }
    allowed_value: { label: "Ad group" value: "adGroup" }
    allowed_value: { label: "Device" value: "device" }
    allowed_value: { label: "Market (inferred)" value: "market" }
    allowed_value: { label: "Conversion action family" value: "conversionFamily" }
    allowed_value: { label: "Day of the week" value: "day" }
  }

  parameter: metric_selector_1 {
    group_label: "Controls"
    label: "Metric 1 (bars)"
    type: unquoted
    default_value: "engineConversions"
    allowed_value: { label: "Spend" value: "totalCost" }
    allowed_value: { label: "Impressions" value: "totalImpressions" }
    allowed_value: { label: "Clicks" value: "totalClicks" }
    allowed_value: { label: "CTR" value: "ctr" }
    allowed_value: { label: "CPC" value: "cpc" }
    allowed_value: { label: "CPM" value: "cpm" }
    allowed_value: { label: "Engine conversions" value: "engineConversions" }
    allowed_value: { label: "All conversion actions" value: "allConversions" }
    allowed_value: { label: "Appointments" value: "appointments" }
    allowed_value: { label: "Cost per appointment" value: "costPerAppointment" }
    allowed_value: { label: "Calls" value: "calls" }
    allowed_value: { label: "Cost per call" value: "costPerCall" }
    allowed_value: { label: "Clinic leads" value: "clinicLeads" }
    allowed_value: { label: "Cost per lead" value: "costPerLead" }
    allowed_value: { label: "Click-through conversions" value: "totalClickthroughConversions" }
    allowed_value: { label: "View-through conversions" value: "totalViewthroughConversions" }
    allowed_value: { label: "CVR" value: "cvr" }
    allowed_value: { label: "CPA" value: "cpa" }
    allowed_value: { label: "Revenue" value: "totalRevenue" }
    allowed_value: { label: "Revenue (all actions)" value: "revenueAllActions" }
    allowed_value: { label: "ROAS" value: "roas" }
    allowed_value: { label: "Value per conversion" value: "valuePerConversion" }
    allowed_value: { label: "Video views" value: "totalVideoViews" }
    allowed_value: { label: "Video completions" value: "totalVideoCompletions" }
    allowed_value: { label: "VTR (view rate)" value: "vtr" }
    allowed_value: { label: "Video completion rate" value: "vcr" }
    allowed_value: { label: "CPV" value: "cpv" }
    allowed_value: { label: "Eligible impressions" value: "eligibleImpressions" }
    allowed_value: { label: "Search impression share" value: "impressionShare" }
    allowed_value: { label: "Lost IS (rank)" value: "lostIsRank" }
    allowed_value: { label: "Lost IS (budget)" value: "lostIsBudget" }
    allowed_value: { label: "Eligible clicks" value: "eligibleClicks" }
    allowed_value: { label: "Click share" value: "clickShare" }
  }

  parameter: metric_selector_2 {
    group_label: "Controls"
    label: "Metric 2 (line)"
    type: unquoted
    default_value: "cpa"
    allowed_value: { label: "Spend" value: "totalCost" }
    allowed_value: { label: "Impressions" value: "totalImpressions" }
    allowed_value: { label: "Clicks" value: "totalClicks" }
    allowed_value: { label: "CTR" value: "ctr" }
    allowed_value: { label: "CPC" value: "cpc" }
    allowed_value: { label: "CPM" value: "cpm" }
    allowed_value: { label: "Engine conversions" value: "engineConversions" }
    allowed_value: { label: "All conversion actions" value: "allConversions" }
    allowed_value: { label: "Appointments" value: "appointments" }
    allowed_value: { label: "Cost per appointment" value: "costPerAppointment" }
    allowed_value: { label: "Calls" value: "calls" }
    allowed_value: { label: "Cost per call" value: "costPerCall" }
    allowed_value: { label: "Clinic leads" value: "clinicLeads" }
    allowed_value: { label: "Cost per lead" value: "costPerLead" }
    allowed_value: { label: "Click-through conversions" value: "totalClickthroughConversions" }
    allowed_value: { label: "View-through conversions" value: "totalViewthroughConversions" }
    allowed_value: { label: "CVR" value: "cvr" }
    allowed_value: { label: "CPA" value: "cpa" }
    allowed_value: { label: "Revenue" value: "totalRevenue" }
    allowed_value: { label: "Revenue (all actions)" value: "revenueAllActions" }
    allowed_value: { label: "ROAS" value: "roas" }
    allowed_value: { label: "Value per conversion" value: "valuePerConversion" }
    allowed_value: { label: "Video views" value: "totalVideoViews" }
    allowed_value: { label: "Video completions" value: "totalVideoCompletions" }
    allowed_value: { label: "VTR (view rate)" value: "vtr" }
    allowed_value: { label: "Video completion rate" value: "vcr" }
    allowed_value: { label: "CPV" value: "cpv" }
    allowed_value: { label: "Eligible impressions" value: "eligibleImpressions" }
    allowed_value: { label: "Search impression share" value: "impressionShare" }
    allowed_value: { label: "Lost IS (rank)" value: "lostIsRank" }
    allowed_value: { label: "Lost IS (budget)" value: "lostIsBudget" }
    allowed_value: { label: "Eligible clicks" value: "eligibleClicks" }
    allowed_value: { label: "Click share" value: "clickShare" }
  }

  ######## DYNAMIC DIMENSIONS ########

  dimension: dynamic_date {
    group_label: "Controls"
    label: "Date (by granularity)"
    label_from_parameter: date_granularity
    type: string
    sql: {% if date_granularity._parameter_value == 'week' %} TO_CHAR(${week_start}, 'YYYY-MM-DD')
         {% elsif date_granularity._parameter_value == 'month' %} TO_CHAR(DATE_TRUNC('month', ${TABLE}."Date"), 'YYYY-MM')
         {% else %} TO_CHAR(${TABLE}."Date", 'YYYY-MM-DD')
         {% endif %} ;;
  }

  dimension: selected_dimension_1 {
    group_label: "Controls"
    label: "Dimension 1"
    label_from_parameter: dimension_selector_1
    type: string
    sql: {% if dimension_selector_1._parameter_value == 'regionName' %} ${region_name}
         {% elsif dimension_selector_1._parameter_value == 'account' %} ${account}
         {% elsif dimension_selector_1._parameter_value == 'accountGroup' %} ${account_group}
         {% elsif dimension_selector_1._parameter_value == 'channel' %} ${channel}
         {% elsif dimension_selector_1._parameter_value == 'mappingChannel' %} ${mapping_channel}
         {% elsif dimension_selector_1._parameter_value == 'condition' %} ${condition}
         {% elsif dimension_selector_1._parameter_value == 'budgetGroup' %} ${budget_group}
         {% elsif dimension_selector_1._parameter_value == 'campaign' %} ${campaign}
         {% elsif dimension_selector_1._parameter_value == 'adGroup' %} ${ad_group}
         {% elsif dimension_selector_1._parameter_value == 'device' %} ${device}
         {% elsif dimension_selector_1._parameter_value == 'market' %} ${market}
         {% elsif dimension_selector_1._parameter_value == 'conversionFamily' %} ${conversion_family}
         {% elsif dimension_selector_1._parameter_value == 'day' %} ${day}
         {% endif %} ;;
    drill_fields: [campaign, ad_group, device, date_date]
  }

  dimension: selected_dimension_2 {
    group_label: "Controls"
    label: "Dimension 2"
    label_from_parameter: dimension_selector_2
    type: string
    sql: {% if dimension_selector_2._parameter_value == 'regionName' %} ${region_name}
         {% elsif dimension_selector_2._parameter_value == 'account' %} ${account}
         {% elsif dimension_selector_2._parameter_value == 'accountGroup' %} ${account_group}
         {% elsif dimension_selector_2._parameter_value == 'channel' %} ${channel}
         {% elsif dimension_selector_2._parameter_value == 'mappingChannel' %} ${mapping_channel}
         {% elsif dimension_selector_2._parameter_value == 'condition' %} ${condition}
         {% elsif dimension_selector_2._parameter_value == 'budgetGroup' %} ${budget_group}
         {% elsif dimension_selector_2._parameter_value == 'campaign' %} ${campaign}
         {% elsif dimension_selector_2._parameter_value == 'adGroup' %} ${ad_group}
         {% elsif dimension_selector_2._parameter_value == 'device' %} ${device}
         {% elsif dimension_selector_2._parameter_value == 'market' %} ${market}
         {% elsif dimension_selector_2._parameter_value == 'conversionFamily' %} ${conversion_family}
         {% elsif dimension_selector_2._parameter_value == 'day' %} ${day}
         {% endif %} ;;
    drill_fields: [campaign, ad_group, device, date_date]
  }

  ######## MEASURES - SPEND & TRAFFIC ########


  measure: total_cost {
    group_label: "Spend & traffic"
    label: "Spend"
    description: "Media cost in dollars."
    type: sum
    sql: ZEROIFNULL(${cost}) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: total_impressions {
    group_label: "Spend & traffic"
    label: "Impressions"
    description: "Times an ad was shown."
    type: sum
    sql: ZEROIFNULL(${impressions}) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: total_clicks {
    group_label: "Spend & traffic"
    label: "Clicks"
    description: "Clicks on ads."
    type: sum
    sql: ZEROIFNULL(${clicks}) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: ctr {
    group_label: "Spend & traffic"
    label: "CTR"
    description: "Clicks / Impressions."
    type: number
    sql: ${total_clicks} / NULLIF(${total_impressions}, 0) ;;
    value_format: "0.00%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: cpc {
    group_label: "Spend & traffic"
    label: "CPC"
    description: "Spend / Clicks."
    type: number
    sql: ${total_cost} / NULLIF(${total_clicks}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: cpm {
    group_label: "Spend & traffic"
    label: "CPM"
    description: "Spend / Impressions x 1,000."
    type: number
    sql: ${total_cost} * 1000 / NULLIF(${total_impressions}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  ######## MEASURES - CONVERSIONS ########


  measure: engine_conversions {
    group_label: "Conversions"
    label: "Engine conversions"
    description: "Conversions from the actions in the current definition (Conversion actions filter; defaults to appointments, calls and clinic leads). Cost rows are never removed by this filter."
    type: sum
    sql: ZEROIFNULL(${total_conversions}) ;;
    filters: [conversion_in_definition: "yes"]
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: all_conversions {
    group_label: "Conversions"
    label: "All conversion actions"
    description: "Every Google Ads conversion action, blended. For reference only."
    type: sum
    sql: ZEROIFNULL(${total_conversions}) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: appointments {
    group_label: "Conversions"
    label: "Appointments"
    description: "GA4 schedule_appointment conversions. Fixed: not moved by the Conversion type filter."
    type: sum
    sql: ZEROIFNULL(${total_conversions}) ;;
    filters: [conversion_family: "Schedule appointment"]
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: cost_per_appointment {
    group_label: "Conversions"
    label: "Cost per appointment"
    description: "Spend / Appointments."
    type: number
    sql: ${total_cost} / NULLIF(${appointments}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: calls {
    group_label: "Conversions"
    label: "Calls"
    description: "Calls from ads, clicks to call and GA4 click call. Fixed: not moved by the Conversion type filter."
    type: sum
    sql: ZEROIFNULL(${total_conversions}) ;;
    filters: [conversion_family: "Calls"]
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: cost_per_call {
    group_label: "Conversions"
    label: "Cost per call"
    description: "Spend / Calls."
    type: number
    sql: ${total_cost} / NULLIF(${calls}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: clinic_leads {
    group_label: "Conversions"
    label: "Clinic leads"
    description: "Per-clinic Leads (ID) - Town actions. Fixed: not moved by the Conversion type filter."
    type: sum
    sql: ZEROIFNULL(${total_conversions}) ;;
    filters: [conversion_family: "Clinic leads"]
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: cost_per_lead {
    group_label: "Conversions"
    label: "Cost per lead"
    description: "Spend / Clinic leads."
    type: number
    sql: ${total_cost} / NULLIF(${clinic_leads}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: total_clickthrough_conversions {
    group_label: "Conversions"
    label: "Click-through conversions"
    description: "Conversions after a click. Currently hard-coded to 0 in the source SQL."
    type: sum
    sql: ZEROIFNULL(${clickthrough_conversions}) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: total_viewthrough_conversions {
    group_label: "Conversions"
    label: "View-through conversions"
    description: "Conversions after an impression only. Currently hard-coded to 0 in the source SQL."
    type: sum
    sql: ZEROIFNULL(${viewthrough_conversions}) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: cvr {
    group_label: "Conversions"
    label: "CVR"
    description: "Engine conversions / Clicks."
    type: number
    sql: ${engine_conversions} / NULLIF(${total_clicks}, 0) ;;
    value_format: "0.00%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: cpa {
    group_label: "Conversions"
    label: "CPA"
    description: "Spend / Engine conversions."
    type: number
    sql: ${total_cost} / NULLIF(${engine_conversions}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  ######## MEASURES - VALUE ########


  measure: total_revenue {
    group_label: "Value"
    label: "Revenue"
    description: "Google conversion value for the actions in the current definition."
    type: sum
    sql: ZEROIFNULL(${revenue}) ;;
    filters: [conversion_in_definition: "yes"]
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: revenue_all_actions {
    group_label: "Value"
    label: "Revenue (all actions)"
    description: "Google conversion value for every action."
    type: sum
    sql: ZEROIFNULL(${revenue}) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: roas {
    group_label: "Value"
    label: "ROAS"
    description: "Revenue / Spend."
    type: number
    sql: ${total_revenue} / NULLIF(${total_cost}, 0) ;;
    value_format: "0.00\"x\""
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: value_per_conversion {
    group_label: "Value"
    label: "Value per conversion"
    description: "Revenue / Engine conversions."
    type: number
    sql: ${total_revenue} / NULLIF(${engine_conversions}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  ######## MEASURES - VIDEO ########


  measure: total_video_views {
    group_label: "Video"
    label: "Video views"
    description: "Video views. 0 while AFC runs no video in this pipeline."
    type: sum
    sql: ZEROIFNULL(${video_views}) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: total_video_completions {
    group_label: "Video"
    label: "Video completions"
    description: "Video completions. 0 while AFC runs no video in this pipeline."
    type: sum
    sql: ZEROIFNULL(${video_completions}) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: vtr {
    group_label: "Video"
    label: "VTR (view rate)"
    description: "Video views / Impressions."
    type: number
    sql: NULLIF(${total_video_views}, 0) / NULLIF(${total_impressions}, 0) ;;
    value_format: "0.00%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: vcr {
    group_label: "Video"
    label: "Video completion rate"
    description: "Video completions / Video views."
    type: number
    sql: NULLIF(${total_video_completions}, 0) / NULLIF(${total_video_views}, 0) ;;
    value_format: "0.00%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: cpv {
    group_label: "Video"
    label: "CPV"
    description: "Spend / Video views."
    type: number
    sql: ${total_cost} / NULLIF(${total_video_views}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  ######## MEASURES - COMPETITION ########


  measure: eligible_impressions {
    group_label: "Competition"
    label: "Eligible impressions"
    description: "Impressions the campaigns were eligible for (impressions / impression share)."
    type: sum
    sql: ZEROIFNULL(${available_impressions}) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: impression_share {
    group_label: "Competition"
    label: "Search impression share"
    description: "Impressions / Eligible impressions, rows that report impression share only."
    type: number
    sql: ${is_impressions} / NULLIF(${eligible_impressions}, 0) ;;
    value_format: "0.0%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: lost_is_rank {
    group_label: "Competition"
    label: "Lost IS (rank)"
    description: "Impression-weighted share of eligible impressions lost to ad rank."
    type: number
    sql: ${lost_rank_weighted} / NULLIF(${is_impressions}, 0) ;;
    value_format: "0.0%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: lost_is_budget {
    group_label: "Competition"
    label: "Lost IS (budget)"
    description: "Impression-weighted share of eligible impressions lost to budget."
    type: number
    sql: ${lost_budget_weighted} / NULLIF(${is_impressions}, 0) ;;
    value_format: "0.0%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: eligible_clicks {
    group_label: "Competition"
    label: "Eligible clicks"
    description: "Clicks the campaigns were eligible for (clicks / click share)."
    type: sum
    sql: ZEROIFNULL(${available_clicks}) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: click_share {
    group_label: "Competition"
    label: "Click share"
    description: "Clicks / Eligible clicks, rows that report click share only."
    type: number
    sql: ${cs_clicks} / NULLIF(${eligible_clicks}, 0) ;;
    value_format: "0.0%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: lost_budget_weighted {
    hidden: yes
    group_label: "Competition"
    label: "lost_budget_weighted"
    type: sum
    sql: ZEROIFNULL(${search_impressions_lost_to_budget}) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
  }

  measure: cs_clicks {
    hidden: yes
    group_label: "Competition"
    label: "cs_clicks"
    type: sum
    sql: ZEROIFNULL(${clicks}) ;;
    filters: [has_click_share: "yes"]
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
  }

  measure: is_impressions {
    hidden: yes
    group_label: "Competition"
    label: "is_impressions"
    type: sum
    sql: ZEROIFNULL(${impressions}) ;;
    filters: [has_impression_share: "yes"]
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
  }

  measure: lost_rank_weighted {
    hidden: yes
    group_label: "Competition"
    label: "lost_rank_weighted"
    type: sum
    sql: ZEROIFNULL(${search_impressions_lost_to_rank}) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
  }

  ######## MEASURES - BUDGET & PACING ########

  # Budget is set per Region x Month. Pacing measures are meant for tiles
  # grouped by month (and region). Filters other than Region don't split budget.

  measure: total_budget {
    group_label: "Budget & pacing"
    label: "Budget"
    type: sum
    sql: ZEROIFNULL(${budget}) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$#,##0"
  }

  measure: budget_spent_pct {
    group_label: "Budget & pacing"
    label: "Budget spent"
    description: "Spend / Budget."
    type: number
    sql: ${total_cost} / NULLIF(${total_budget}, 0) ;;
    value_format: "0.0%"
  }

  measure: pacing_days_elapsed {
    group_label: "Budget & pacing"
    label: "Days elapsed"
    description: "Days from the 1st of the month to the latest day with performance data."
    type: number
    sql: DATEDIFF('day', DATE_TRUNC('month', MAX(CASE WHEN ${is_performance_row} THEN ${TABLE}."Date" END)),
                         MAX(CASE WHEN ${is_performance_row} THEN ${TABLE}."Date" END)) + 1 ;;
    value_format_name: decimal_0
  }

  measure: pacing_days_in_month {
    group_label: "Budget & pacing"
    label: "Days in month"
    type: number
    sql: DAY(LAST_DAY(MAX(${TABLE}."Date"))) ;;
    value_format_name: decimal_0
  }

  measure: pacing_month_elapsed_pct {
    group_label: "Budget & pacing"
    label: "Month elapsed"
    type: number
    sql: ZEROIFNULL(${pacing_days_elapsed}) / NULLIF(${pacing_days_in_month}, 0) ;;
    value_format: "0.0%"
  }

  measure: pacing_projected_spend {
    group_label: "Budget & pacing"
    label: "Projected month-end spend"
    description: "Spend / Days elapsed x Days in month."
    type: number
    sql: ${total_cost} / NULLIF(${pacing_days_elapsed}, 0) * ${pacing_days_in_month} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$#,##0"
  }

  measure: pacing_projected_vs_budget {
    group_label: "Budget & pacing"
    label: "Projected vs budget"
    type: number
    sql: ${pacing_projected_spend} / NULLIF(${total_budget}, 0) ;;
    value_format: "0.0%"
  }

  measure: pacing_daily_spend_needed {
    group_label: "Budget & pacing"
    label: "Daily spend needed"
    description: "Remaining budget / remaining days."
    type: number
    sql: (${total_budget} - ${total_cost}) / NULLIF(${pacing_days_in_month} - ZEROIFNULL(${pacing_days_elapsed}), 0) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$#,##0"
  }

  measure: pacing_status {
    group_label: "Budget & pacing"
    label: "Pacing status"
    type: string
    sql: CASE
           WHEN ZEROIFNULL(${total_budget}) = 0              THEN 'No budget'
           WHEN ${pacing_days_elapsed} IS NULL         THEN 'Not started'
           WHEN ${pacing_projected_vs_budget} > 1.05   THEN 'Over pace'
           WHEN ${pacing_projected_vs_budget} < 0.95   THEN 'Under pace'
           ELSE 'On pace'
         END ;;
    html: {% if value == 'On pace' %}<span style="color:#1E7B4F;font-weight:700">{{ value }}</span>
          {% elsif value == 'Over pace' %}<span style="color:#B42318;font-weight:700">{{ value }}</span>
          {% elsif value == 'Under pace' %}<span style="color:#7A5200;font-weight:700">{{ value }}</span>
          {% else %}<span style="color:#8A929C">{{ value }}</span>{% endif %} ;;
  }

  measure: days_with_data {
    group_label: "Budget & pacing"
    label: "Days with data"
    description: "Use on week and month rows to flag partial periods (e.g. 2 of 7 days)."
    type: count_distinct
    sql: CASE WHEN ${is_performance_row} THEN ${TABLE}."Date" END ;;
  }

  ######## COMPARISON ENGINE (hidden) ########

  # Window bounds are declared type: string so Snowflake keeps DATE types
  # (a type: date dimension gets wrapped in TO_CHAR when referenced).

  dimension: cmp_data_end {
    hidden: yes
    type: string
    sql: (SELECT MAX("Date") FROM "DBO"."AmericanFamilyCare_Search_Looker_table"
          WHERE COALESCE("Source", '') <> 'Budget' AND "Date" < CURRENT_DATE()
            AND ZEROIFNULL("Impressions") + ZEROIFNULL("Cost") > 0) ;;
  }

  dimension: cmp_anchor {
    hidden: yes
    type: string
    sql: {% if date_range._is_filtered %}
           COALESCE(LEAST(DATEADD('day', -1, ({% date_end date_range %})::DATE), ${cmp_data_end}), ${cmp_data_end})
         {% else %} ${cmp_data_end} {% endif %} ;;
  }

  dimension: cmp_range_start {
    hidden: yes
    type: string
    sql: {% if date_range._is_filtered %}
           COALESCE(({% date_start date_range %})::DATE, DATEADD('day', -29, ${cmp_anchor}))
         {% else %} DATEADD('day', -29, ${cmp_anchor}) {% endif %} ;;
  }

  dimension: cmp_cur_start {
    hidden: yes
    type: string
    sql: ${cmp_range_start} ;;
  }

  dimension: cmp_cur_end {
    hidden: yes
    type: string
    sql: ${cmp_anchor} ;;
  }

  dimension: cmp_prior_start {
    hidden: yes
    type: string
    sql: {% if comparison_mode._parameter_value == 'py' %} DATEADD('year', -1, ${cmp_cur_start})
         {% else %} DATEADD('day', -(DATEDIFF('day', ${cmp_cur_start}, ${cmp_cur_end}) + 1), ${cmp_cur_start})
         {% endif %} ;;
  }

  dimension: cmp_prior_end {
    hidden: yes
    type: string
    sql: {% if comparison_mode._parameter_value == 'py' %} DATEADD('year', -1, ${cmp_cur_end})
         {% else %} DATEADD('day', -1, ${cmp_cur_start})
         {% endif %} ;;
  }

  dimension: cmp_divisor {
    hidden: yes
    type: number
    sql: 1 ;;
  }

  dimension: in_cmp_current {
    hidden: yes
    type: yesno
    sql: ${TABLE}."Date" BETWEEN ${cmp_cur_start} AND ${cmp_cur_end} ;;
  }

  dimension: in_cmp_prior {
    hidden: yes
    type: yesno
    sql: {% if comparison_mode._parameter_value == 'none' %} FALSE
         {% else %} ${TABLE}."Date" BETWEEN ${cmp_prior_start} AND ${cmp_prior_end} {% endif %} ;;
  }

  dimension: in_cmp_scope {
    group_label: "Controls"
    label: "In comparison scope"
    description: "Add as a filter (Yes) on comparison tiles so the scan prunes to the two windows."
    type: yesno
    sql: ${in_cmp_current} OR ${in_cmp_prior} ;;
  }

  dimension: cmp_window {
    group_label: "Controls"
    label: "Window"
    description: "Current or Comparison. Pivot on it to show both windows side by side."
    type: string
    sql: CASE WHEN ${in_cmp_current} THEN 'Current' WHEN ${in_cmp_prior} THEN 'Comparison' END ;;
  }

  measure: cmp_window_caption {
    group_label: "Controls"
    label: "Comparison caption"
    description: "Text like '31 Aug to 29 Sep vs 1 Aug to 30 Aug', for a subtitle tile."
    type: string
    sql: MAX(TO_CHAR(${cmp_cur_start}, 'DD Mon') || ' to ' || TO_CHAR(${cmp_cur_end}, 'DD Mon YYYY')
         {% if comparison_mode._parameter_value != 'none' %}
         || ' vs ' || TO_CHAR(${cmp_prior_start}, 'DD Mon') || ' to ' || TO_CHAR(${cmp_prior_end}, 'DD Mon YYYY')
         {% endif %}) ;;
  }

  measure: cmp_divisor_value {
    hidden: yes
    type: max
    sql: ${cmp_divisor} ;;
  }
  measure: total_cost_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${cost}) ;; filters: [in_cmp_current: "yes"] }
  measure: total_cost_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${cost}) ;; filters: [in_cmp_prior: "yes"] }
  measure: total_impressions_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${impressions}) ;; filters: [in_cmp_current: "yes"] }
  measure: total_impressions_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${impressions}) ;; filters: [in_cmp_prior: "yes"] }
  measure: total_clicks_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${clicks}) ;; filters: [in_cmp_current: "yes"] }
  measure: total_clicks_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${clicks}) ;; filters: [in_cmp_prior: "yes"] }
  measure: engine_conversions_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${total_conversions}) ;; filters: [in_cmp_current: "yes", conversion_in_definition: "yes"] }
  measure: engine_conversions_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${total_conversions}) ;; filters: [in_cmp_prior: "yes", conversion_in_definition: "yes"] }
  measure: all_conversions_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${total_conversions}) ;; filters: [in_cmp_current: "yes"] }
  measure: all_conversions_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${total_conversions}) ;; filters: [in_cmp_prior: "yes"] }
  measure: appointments_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${total_conversions}) ;; filters: [in_cmp_current: "yes", conversion_family: "Schedule appointment"] }
  measure: appointments_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${total_conversions}) ;; filters: [in_cmp_prior: "yes", conversion_family: "Schedule appointment"] }
  measure: calls_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${total_conversions}) ;; filters: [in_cmp_current: "yes", conversion_family: "Calls"] }
  measure: calls_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${total_conversions}) ;; filters: [in_cmp_prior: "yes", conversion_family: "Calls"] }
  measure: clinic_leads_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${total_conversions}) ;; filters: [in_cmp_current: "yes", conversion_family: "Clinic leads"] }
  measure: clinic_leads_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${total_conversions}) ;; filters: [in_cmp_prior: "yes", conversion_family: "Clinic leads"] }
  measure: total_clickthrough_conversions_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${clickthrough_conversions}) ;; filters: [in_cmp_current: "yes"] }
  measure: total_clickthrough_conversions_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${clickthrough_conversions}) ;; filters: [in_cmp_prior: "yes"] }
  measure: total_viewthrough_conversions_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${viewthrough_conversions}) ;; filters: [in_cmp_current: "yes"] }
  measure: total_viewthrough_conversions_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${viewthrough_conversions}) ;; filters: [in_cmp_prior: "yes"] }
  measure: total_revenue_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${revenue}) ;; filters: [in_cmp_current: "yes", conversion_in_definition: "yes"] }
  measure: total_revenue_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${revenue}) ;; filters: [in_cmp_prior: "yes", conversion_in_definition: "yes"] }
  measure: revenue_all_actions_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${revenue}) ;; filters: [in_cmp_current: "yes"] }
  measure: revenue_all_actions_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${revenue}) ;; filters: [in_cmp_prior: "yes"] }
  measure: total_video_views_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${video_views}) ;; filters: [in_cmp_current: "yes"] }
  measure: total_video_views_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${video_views}) ;; filters: [in_cmp_prior: "yes"] }
  measure: total_video_completions_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${video_completions}) ;; filters: [in_cmp_current: "yes"] }
  measure: total_video_completions_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${video_completions}) ;; filters: [in_cmp_prior: "yes"] }
  measure: eligible_impressions_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${available_impressions}) ;; filters: [in_cmp_current: "yes"] }
  measure: eligible_impressions_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${available_impressions}) ;; filters: [in_cmp_prior: "yes"] }
  measure: is_impressions_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${impressions}) ;; filters: [in_cmp_current: "yes", has_impression_share: "yes"] }
  measure: is_impressions_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${impressions}) ;; filters: [in_cmp_prior: "yes", has_impression_share: "yes"] }
  measure: lost_rank_weighted_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${search_impressions_lost_to_rank}) ;; filters: [in_cmp_current: "yes"] }
  measure: lost_rank_weighted_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${search_impressions_lost_to_rank}) ;; filters: [in_cmp_prior: "yes"] }
  measure: lost_budget_weighted_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${search_impressions_lost_to_budget}) ;; filters: [in_cmp_current: "yes"] }
  measure: lost_budget_weighted_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${search_impressions_lost_to_budget}) ;; filters: [in_cmp_prior: "yes"] }
  measure: eligible_clicks_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${available_clicks}) ;; filters: [in_cmp_current: "yes"] }
  measure: eligible_clicks_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${available_clicks}) ;; filters: [in_cmp_prior: "yes"] }
  measure: cs_clicks_cur_sum   { hidden: yes type: sum sql: ZEROIFNULL(${clicks}) ;; filters: [in_cmp_current: "yes", has_click_share: "yes"] }
  measure: cs_clicks_prior_sum { hidden: yes type: sum sql: ZEROIFNULL(${clicks}) ;; filters: [in_cmp_prior: "yes", has_click_share: "yes"] }

  ######## MEASURES - PERIOD OVER PERIOD ########

  # Per metric:  <metric>_cur    value in the current window
  #              <metric>_prior  value in the comparison window (averaged for avg modes)
  #              <metric>_delta  change, as % or absolute (delta_format), coloured by
  #                              whether the move is good for AFC
  # Rates are always ratio of window totals.

  measure: total_cost_cur {
    group_label: "PoP - Spend & traffic"
    label: "Spend"
    type: number
    sql: ${total_cost_cur_sum} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: total_cost_prior {
    group_label: "PoP - Spend & traffic"
    label: "Spend (comparison)"
    type: number
    sql: ${total_cost_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$#,##0"
  }
  measure: total_cost_delta {
    group_label: "PoP - Spend & traffic"
    label: "Spend delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_cost_cur} - ${total_cost_prior} {% else %} (${total_cost_cur} - ${total_cost_prior}) / NULLIF(ABS(${total_cost_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'none' %}
      {% assign f = 'money' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: total_impressions_cur {
    group_label: "PoP - Spend & traffic"
    label: "Impressions"
    type: number
    sql: ${total_impressions_cur_sum} ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: total_impressions_prior {
    group_label: "PoP - Spend & traffic"
    label: "Impressions (comparison)"
    type: number
    sql: ${total_impressions_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
  }
  measure: total_impressions_delta {
    group_label: "PoP - Spend & traffic"
    label: "Impressions delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_impressions_cur} - ${total_impressions_prior} {% else %} (${total_impressions_cur} - ${total_impressions_prior}) / NULLIF(ABS(${total_impressions_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: total_clicks_cur {
    group_label: "PoP - Spend & traffic"
    label: "Clicks"
    type: number
    sql: ${total_clicks_cur_sum} ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: total_clicks_prior {
    group_label: "PoP - Spend & traffic"
    label: "Clicks (comparison)"
    type: number
    sql: ${total_clicks_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
  }
  measure: total_clicks_delta {
    group_label: "PoP - Spend & traffic"
    label: "Clicks delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_clicks_cur} - ${total_clicks_prior} {% else %} (${total_clicks_cur} - ${total_clicks_prior}) / NULLIF(ABS(${total_clicks_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: ctr_cur {
    group_label: "PoP - Spend & traffic"
    label: "CTR"
    type: number
    sql: ${total_clicks_cur_sum} / NULLIF(${total_impressions_cur_sum}, 0) ;;
    value_format: "0.00%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: ctr_prior {
    group_label: "PoP - Spend & traffic"
    label: "CTR (comparison)"
    type: number
    sql: ${total_clicks_prior_sum} / NULLIF(${total_impressions_prior_sum}, 0) ;;
    value_format: "0.00%"
  }
  measure: ctr_delta {
    group_label: "PoP - Spend & traffic"
    label: "CTR delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${ctr_cur} - ${ctr_prior} {% else %} (${ctr_cur} - ${ctr_prior}) / NULLIF(ABS(${ctr_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cpc_cur {
    group_label: "PoP - Spend & traffic"
    label: "CPC"
    type: number
    sql: ${total_cost_cur_sum} / NULLIF(${total_clicks_cur_sum}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: cpc_prior {
    group_label: "PoP - Spend & traffic"
    label: "CPC (comparison)"
    type: number
    sql: ${total_cost_prior_sum} / NULLIF(${total_clicks_prior_sum}, 0) ;;
    value_format: "$#,##0.00"
  }
  measure: cpc_delta {
    group_label: "PoP - Spend & traffic"
    label: "CPC delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cpc_cur} - ${cpc_prior} {% else %} (${cpc_cur} - ${cpc_prior}) / NULLIF(ABS(${cpc_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cpm_cur {
    group_label: "PoP - Spend & traffic"
    label: "CPM"
    type: number
    sql: ${total_cost_cur_sum} * 1000 / NULLIF(${total_impressions_cur_sum}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: cpm_prior {
    group_label: "PoP - Spend & traffic"
    label: "CPM (comparison)"
    type: number
    sql: ${total_cost_prior_sum} * 1000 / NULLIF(${total_impressions_prior_sum}, 0) ;;
    value_format: "$#,##0.00"
  }
  measure: cpm_delta {
    group_label: "PoP - Spend & traffic"
    label: "CPM delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cpm_cur} - ${cpm_prior} {% else %} (${cpm_cur} - ${cpm_prior}) / NULLIF(ABS(${cpm_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: engine_conversions_cur {
    group_label: "PoP - Conversions"
    label: "Engine conversions"
    type: number
    sql: ${engine_conversions_cur_sum} ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: engine_conversions_prior {
    group_label: "PoP - Conversions"
    label: "Engine conversions (comparison)"
    type: number
    sql: ${engine_conversions_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
  }
  measure: engine_conversions_delta {
    group_label: "PoP - Conversions"
    label: "Engine conversions delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${engine_conversions_cur} - ${engine_conversions_prior} {% else %} (${engine_conversions_cur} - ${engine_conversions_prior}) / NULLIF(ABS(${engine_conversions_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: all_conversions_cur {
    group_label: "PoP - Conversions"
    label: "All conversion actions"
    type: number
    sql: ${all_conversions_cur_sum} ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: all_conversions_prior {
    group_label: "PoP - Conversions"
    label: "All conversion actions (comparison)"
    type: number
    sql: ${all_conversions_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
  }
  measure: all_conversions_delta {
    group_label: "PoP - Conversions"
    label: "All conversion actions delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${all_conversions_cur} - ${all_conversions_prior} {% else %} (${all_conversions_cur} - ${all_conversions_prior}) / NULLIF(ABS(${all_conversions_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: appointments_cur {
    group_label: "PoP - Conversions"
    label: "Appointments"
    type: number
    sql: ${appointments_cur_sum} ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: appointments_prior {
    group_label: "PoP - Conversions"
    label: "Appointments (comparison)"
    type: number
    sql: ${appointments_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
  }
  measure: appointments_delta {
    group_label: "PoP - Conversions"
    label: "Appointments delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${appointments_cur} - ${appointments_prior} {% else %} (${appointments_cur} - ${appointments_prior}) / NULLIF(ABS(${appointments_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cost_per_appointment_cur {
    group_label: "PoP - Conversions"
    label: "Cost per appointment"
    type: number
    sql: ${total_cost_cur_sum} / NULLIF(${appointments_cur_sum}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: cost_per_appointment_prior {
    group_label: "PoP - Conversions"
    label: "Cost per appointment (comparison)"
    type: number
    sql: ${total_cost_prior_sum} / NULLIF(${appointments_prior_sum}, 0) ;;
    value_format: "$#,##0.00"
  }
  measure: cost_per_appointment_delta {
    group_label: "PoP - Conversions"
    label: "Cost per appointment delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cost_per_appointment_cur} - ${cost_per_appointment_prior} {% else %} (${cost_per_appointment_cur} - ${cost_per_appointment_prior}) / NULLIF(ABS(${cost_per_appointment_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: calls_cur {
    group_label: "PoP - Conversions"
    label: "Calls"
    type: number
    sql: ${calls_cur_sum} ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: calls_prior {
    group_label: "PoP - Conversions"
    label: "Calls (comparison)"
    type: number
    sql: ${calls_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
  }
  measure: calls_delta {
    group_label: "PoP - Conversions"
    label: "Calls delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${calls_cur} - ${calls_prior} {% else %} (${calls_cur} - ${calls_prior}) / NULLIF(ABS(${calls_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cost_per_call_cur {
    group_label: "PoP - Conversions"
    label: "Cost per call"
    type: number
    sql: ${total_cost_cur_sum} / NULLIF(${calls_cur_sum}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: cost_per_call_prior {
    group_label: "PoP - Conversions"
    label: "Cost per call (comparison)"
    type: number
    sql: ${total_cost_prior_sum} / NULLIF(${calls_prior_sum}, 0) ;;
    value_format: "$#,##0.00"
  }
  measure: cost_per_call_delta {
    group_label: "PoP - Conversions"
    label: "Cost per call delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cost_per_call_cur} - ${cost_per_call_prior} {% else %} (${cost_per_call_cur} - ${cost_per_call_prior}) / NULLIF(ABS(${cost_per_call_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: clinic_leads_cur {
    group_label: "PoP - Conversions"
    label: "Clinic leads"
    type: number
    sql: ${clinic_leads_cur_sum} ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: clinic_leads_prior {
    group_label: "PoP - Conversions"
    label: "Clinic leads (comparison)"
    type: number
    sql: ${clinic_leads_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
  }
  measure: clinic_leads_delta {
    group_label: "PoP - Conversions"
    label: "Clinic leads delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${clinic_leads_cur} - ${clinic_leads_prior} {% else %} (${clinic_leads_cur} - ${clinic_leads_prior}) / NULLIF(ABS(${clinic_leads_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cost_per_lead_cur {
    group_label: "PoP - Conversions"
    label: "Cost per lead"
    type: number
    sql: ${total_cost_cur_sum} / NULLIF(${clinic_leads_cur_sum}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: cost_per_lead_prior {
    group_label: "PoP - Conversions"
    label: "Cost per lead (comparison)"
    type: number
    sql: ${total_cost_prior_sum} / NULLIF(${clinic_leads_prior_sum}, 0) ;;
    value_format: "$#,##0.00"
  }
  measure: cost_per_lead_delta {
    group_label: "PoP - Conversions"
    label: "Cost per lead delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cost_per_lead_cur} - ${cost_per_lead_prior} {% else %} (${cost_per_lead_cur} - ${cost_per_lead_prior}) / NULLIF(ABS(${cost_per_lead_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: total_clickthrough_conversions_cur {
    group_label: "PoP - Conversions"
    label: "Click-through conversions"
    type: number
    sql: ${total_clickthrough_conversions_cur_sum} ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: total_clickthrough_conversions_prior {
    group_label: "PoP - Conversions"
    label: "Click-through conversions (comparison)"
    type: number
    sql: ${total_clickthrough_conversions_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
  }
  measure: total_clickthrough_conversions_delta {
    group_label: "PoP - Conversions"
    label: "Click-through conversions delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_clickthrough_conversions_cur} - ${total_clickthrough_conversions_prior} {% else %} (${total_clickthrough_conversions_cur} - ${total_clickthrough_conversions_prior}) / NULLIF(ABS(${total_clickthrough_conversions_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: total_viewthrough_conversions_cur {
    group_label: "PoP - Conversions"
    label: "View-through conversions"
    type: number
    sql: ${total_viewthrough_conversions_cur_sum} ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: total_viewthrough_conversions_prior {
    group_label: "PoP - Conversions"
    label: "View-through conversions (comparison)"
    type: number
    sql: ${total_viewthrough_conversions_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
  }
  measure: total_viewthrough_conversions_delta {
    group_label: "PoP - Conversions"
    label: "View-through conversions delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_viewthrough_conversions_cur} - ${total_viewthrough_conversions_prior} {% else %} (${total_viewthrough_conversions_cur} - ${total_viewthrough_conversions_prior}) / NULLIF(ABS(${total_viewthrough_conversions_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cvr_cur {
    group_label: "PoP - Conversions"
    label: "CVR"
    type: number
    sql: ${engine_conversions_cur_sum} / NULLIF(${total_clicks_cur_sum}, 0) ;;
    value_format: "0.00%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: cvr_prior {
    group_label: "PoP - Conversions"
    label: "CVR (comparison)"
    type: number
    sql: ${engine_conversions_prior_sum} / NULLIF(${total_clicks_prior_sum}, 0) ;;
    value_format: "0.00%"
  }
  measure: cvr_delta {
    group_label: "PoP - Conversions"
    label: "CVR delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cvr_cur} - ${cvr_prior} {% else %} (${cvr_cur} - ${cvr_prior}) / NULLIF(ABS(${cvr_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cpa_cur {
    group_label: "PoP - Conversions"
    label: "CPA"
    type: number
    sql: ${total_cost_cur_sum} / NULLIF(${engine_conversions_cur_sum}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: cpa_prior {
    group_label: "PoP - Conversions"
    label: "CPA (comparison)"
    type: number
    sql: ${total_cost_prior_sum} / NULLIF(${engine_conversions_prior_sum}, 0) ;;
    value_format: "$#,##0.00"
  }
  measure: cpa_delta {
    group_label: "PoP - Conversions"
    label: "CPA delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cpa_cur} - ${cpa_prior} {% else %} (${cpa_cur} - ${cpa_prior}) / NULLIF(ABS(${cpa_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: total_revenue_cur {
    group_label: "PoP - Value"
    label: "Revenue"
    type: number
    sql: ${total_revenue_cur_sum} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: total_revenue_prior {
    group_label: "PoP - Value"
    label: "Revenue (comparison)"
    type: number
    sql: ${total_revenue_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$#,##0"
  }
  measure: total_revenue_delta {
    group_label: "PoP - Value"
    label: "Revenue delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_revenue_cur} - ${total_revenue_prior} {% else %} (${total_revenue_cur} - ${total_revenue_prior}) / NULLIF(ABS(${total_revenue_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'money' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: revenue_all_actions_cur {
    group_label: "PoP - Value"
    label: "Revenue (all actions)"
    type: number
    sql: ${revenue_all_actions_cur_sum} ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: revenue_all_actions_prior {
    group_label: "PoP - Value"
    label: "Revenue (all actions) (comparison)"
    type: number
    sql: ${revenue_all_actions_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.0,\"K\";$#,##0"
  }
  measure: revenue_all_actions_delta {
    group_label: "PoP - Value"
    label: "Revenue (all actions) delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${revenue_all_actions_cur} - ${revenue_all_actions_prior} {% else %} (${revenue_all_actions_cur} - ${revenue_all_actions_prior}) / NULLIF(ABS(${revenue_all_actions_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'money' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: roas_cur {
    group_label: "PoP - Value"
    label: "ROAS"
    type: number
    sql: ${total_revenue_cur_sum} / NULLIF(${total_cost_cur_sum}, 0) ;;
    value_format: "0.00\"x\""
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: roas_prior {
    group_label: "PoP - Value"
    label: "ROAS (comparison)"
    type: number
    sql: ${total_revenue_prior_sum} / NULLIF(${total_cost_prior_sum}, 0) ;;
    value_format: "0.00\"x\""
  }
  measure: roas_delta {
    group_label: "PoP - Value"
    label: "ROAS delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${roas_cur} - ${roas_prior} {% else %} (${roas_cur} - ${roas_prior}) / NULLIF(ABS(${roas_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'x' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: value_per_conversion_cur {
    group_label: "PoP - Value"
    label: "Value per conversion"
    type: number
    sql: ${total_revenue_cur_sum} / NULLIF(${engine_conversions_cur_sum}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: value_per_conversion_prior {
    group_label: "PoP - Value"
    label: "Value per conversion (comparison)"
    type: number
    sql: ${total_revenue_prior_sum} / NULLIF(${engine_conversions_prior_sum}, 0) ;;
    value_format: "$#,##0.00"
  }
  measure: value_per_conversion_delta {
    group_label: "PoP - Value"
    label: "Value per conversion delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${value_per_conversion_cur} - ${value_per_conversion_prior} {% else %} (${value_per_conversion_cur} - ${value_per_conversion_prior}) / NULLIF(ABS(${value_per_conversion_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: total_video_views_cur {
    group_label: "PoP - Video"
    label: "Video views"
    type: number
    sql: ${total_video_views_cur_sum} ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: total_video_views_prior {
    group_label: "PoP - Video"
    label: "Video views (comparison)"
    type: number
    sql: ${total_video_views_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
  }
  measure: total_video_views_delta {
    group_label: "PoP - Video"
    label: "Video views delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_video_views_cur} - ${total_video_views_prior} {% else %} (${total_video_views_cur} - ${total_video_views_prior}) / NULLIF(ABS(${total_video_views_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: total_video_completions_cur {
    group_label: "PoP - Video"
    label: "Video completions"
    type: number
    sql: ${total_video_completions_cur_sum} ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: total_video_completions_prior {
    group_label: "PoP - Video"
    label: "Video completions (comparison)"
    type: number
    sql: ${total_video_completions_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
  }
  measure: total_video_completions_delta {
    group_label: "PoP - Video"
    label: "Video completions delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_video_completions_cur} - ${total_video_completions_prior} {% else %} (${total_video_completions_cur} - ${total_video_completions_prior}) / NULLIF(ABS(${total_video_completions_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: vtr_cur {
    group_label: "PoP - Video"
    label: "VTR (view rate)"
    type: number
    sql: NULLIF(${total_video_views_cur_sum}, 0) / NULLIF(${total_impressions_cur_sum}, 0) ;;
    value_format: "0.00%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: vtr_prior {
    group_label: "PoP - Video"
    label: "VTR (view rate) (comparison)"
    type: number
    sql: NULLIF(${total_video_views_prior_sum}, 0) / NULLIF(${total_impressions_prior_sum}, 0) ;;
    value_format: "0.00%"
  }
  measure: vtr_delta {
    group_label: "PoP - Video"
    label: "VTR (view rate) delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${vtr_cur} - ${vtr_prior} {% else %} (${vtr_cur} - ${vtr_prior}) / NULLIF(ABS(${vtr_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: vcr_cur {
    group_label: "PoP - Video"
    label: "Video completion rate"
    type: number
    sql: NULLIF(${total_video_completions_cur_sum}, 0) / NULLIF(${total_video_views_cur_sum}, 0) ;;
    value_format: "0.00%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: vcr_prior {
    group_label: "PoP - Video"
    label: "Video completion rate (comparison)"
    type: number
    sql: NULLIF(${total_video_completions_prior_sum}, 0) / NULLIF(${total_video_views_prior_sum}, 0) ;;
    value_format: "0.00%"
  }
  measure: vcr_delta {
    group_label: "PoP - Video"
    label: "Video completion rate delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${vcr_cur} - ${vcr_prior} {% else %} (${vcr_cur} - ${vcr_prior}) / NULLIF(ABS(${vcr_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cpv_cur {
    group_label: "PoP - Video"
    label: "CPV"
    type: number
    sql: ${total_cost_cur_sum} / NULLIF(${total_video_views_cur_sum}, 0) ;;
    value_format: "$#,##0.00"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: cpv_prior {
    group_label: "PoP - Video"
    label: "CPV (comparison)"
    type: number
    sql: ${total_cost_prior_sum} / NULLIF(${total_video_views_prior_sum}, 0) ;;
    value_format: "$#,##0.00"
  }
  measure: cpv_delta {
    group_label: "PoP - Video"
    label: "CPV delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cpv_cur} - ${cpv_prior} {% else %} (${cpv_cur} - ${cpv_prior}) / NULLIF(ABS(${cpv_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: eligible_impressions_cur {
    group_label: "PoP - Competition"
    label: "Eligible impressions"
    type: number
    sql: ${eligible_impressions_cur_sum} ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: eligible_impressions_prior {
    group_label: "PoP - Competition"
    label: "Eligible impressions (comparison)"
    type: number
    sql: ${eligible_impressions_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
  }
  measure: eligible_impressions_delta {
    group_label: "PoP - Competition"
    label: "Eligible impressions delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${eligible_impressions_cur} - ${eligible_impressions_prior} {% else %} (${eligible_impressions_cur} - ${eligible_impressions_prior}) / NULLIF(ABS(${eligible_impressions_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: impression_share_cur {
    group_label: "PoP - Competition"
    label: "Search impression share"
    type: number
    sql: ${is_impressions_cur_sum} / NULLIF(${eligible_impressions_cur_sum}, 0) ;;
    value_format: "0.0%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: impression_share_prior {
    group_label: "PoP - Competition"
    label: "Search impression share (comparison)"
    type: number
    sql: ${is_impressions_prior_sum} / NULLIF(${eligible_impressions_prior_sum}, 0) ;;
    value_format: "0.0%"
  }
  measure: impression_share_delta {
    group_label: "PoP - Competition"
    label: "Search impression share delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${impression_share_cur} - ${impression_share_prior} {% else %} (${impression_share_cur} - ${impression_share_prior}) / NULLIF(ABS(${impression_share_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: lost_is_rank_cur {
    group_label: "PoP - Competition"
    label: "Lost IS (rank)"
    type: number
    sql: ${lost_rank_weighted_cur_sum} / NULLIF(${is_impressions_cur_sum}, 0) ;;
    value_format: "0.0%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: lost_is_rank_prior {
    group_label: "PoP - Competition"
    label: "Lost IS (rank) (comparison)"
    type: number
    sql: ${lost_rank_weighted_prior_sum} / NULLIF(${is_impressions_prior_sum}, 0) ;;
    value_format: "0.0%"
  }
  measure: lost_is_rank_delta {
    group_label: "PoP - Competition"
    label: "Lost IS (rank) delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${lost_is_rank_cur} - ${lost_is_rank_prior} {% else %} (${lost_is_rank_cur} - ${lost_is_rank_prior}) / NULLIF(ABS(${lost_is_rank_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: lost_is_budget_cur {
    group_label: "PoP - Competition"
    label: "Lost IS (budget)"
    type: number
    sql: ${lost_budget_weighted_cur_sum} / NULLIF(${is_impressions_cur_sum}, 0) ;;
    value_format: "0.0%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: lost_is_budget_prior {
    group_label: "PoP - Competition"
    label: "Lost IS (budget) (comparison)"
    type: number
    sql: ${lost_budget_weighted_prior_sum} / NULLIF(${is_impressions_prior_sum}, 0) ;;
    value_format: "0.0%"
  }
  measure: lost_is_budget_delta {
    group_label: "PoP - Competition"
    label: "Lost IS (budget) delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${lost_is_budget_cur} - ${lost_is_budget_prior} {% else %} (${lost_is_budget_cur} - ${lost_is_budget_prior}) / NULLIF(ABS(${lost_is_budget_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: eligible_clicks_cur {
    group_label: "PoP - Competition"
    label: "Eligible clicks"
    type: number
    sql: ${eligible_clicks_cur_sum} ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: eligible_clicks_prior {
    group_label: "PoP - Competition"
    label: "Eligible clicks (comparison)"
    type: number
    sql: ${eligible_clicks_prior_sum} / NULLIF(${cmp_divisor_value}, 0) ;;
    value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.0,\"K\";#,##0"
  }
  measure: eligible_clicks_delta {
    group_label: "PoP - Competition"
    label: "Eligible clicks delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${eligible_clicks_cur} - ${eligible_clicks_prior} {% else %} (${eligible_clicks_cur} - ${eligible_clicks_prior}) / NULLIF(ABS(${eligible_clicks_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: click_share_cur {
    group_label: "PoP - Competition"
    label: "Click share"
    type: number
    sql: ${cs_clicks_cur_sum} / NULLIF(${eligible_clicks_cur_sum}, 0) ;;
    value_format: "0.0%"
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }
  measure: click_share_prior {
    group_label: "PoP - Competition"
    label: "Click share (comparison)"
    type: number
    sql: ${cs_clicks_prior_sum} / NULLIF(${eligible_clicks_prior_sum}, 0) ;;
    value_format: "0.0%"
  }
  measure: click_share_delta {
    group_label: "PoP - Competition"
    label: "Click share delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${click_share_cur} - ${click_share_prior} {% else %} (${click_share_cur} - ${click_share_prior}) / NULLIF(ABS(${click_share_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  ######## MEASURES - % CHANGE VS COMPARISON PERIOD (KPI scorecards) ########

  # <metric>_pop: plain % change of the current window vs the comparison window,
  # formatted with an arrow. Used as the comparison value of single-value tiles
  # (comparison_type: value), so the scorecard reads e.g. '▲ 12.3% vs PP'.

  measure: total_cost_pop {
    group_label: "PoP - Spend & traffic"
    label: "Spend % change"
    type: number
    sql: (${total_cost_cur} - ${total_cost_prior}) / NULLIF(ABS(${total_cost_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: total_impressions_pop {
    group_label: "PoP - Spend & traffic"
    label: "Impressions % change"
    type: number
    sql: (${total_impressions_cur} - ${total_impressions_prior}) / NULLIF(ABS(${total_impressions_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: total_clicks_pop {
    group_label: "PoP - Spend & traffic"
    label: "Clicks % change"
    type: number
    sql: (${total_clicks_cur} - ${total_clicks_prior}) / NULLIF(ABS(${total_clicks_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: ctr_pop {
    group_label: "PoP - Spend & traffic"
    label: "CTR % change"
    type: number
    sql: (${ctr_cur} - ${ctr_prior}) / NULLIF(ABS(${ctr_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: cpc_pop {
    group_label: "PoP - Spend & traffic"
    label: "CPC % change"
    type: number
    sql: (${cpc_cur} - ${cpc_prior}) / NULLIF(ABS(${cpc_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: cpm_pop {
    group_label: "PoP - Spend & traffic"
    label: "CPM % change"
    type: number
    sql: (${cpm_cur} - ${cpm_prior}) / NULLIF(ABS(${cpm_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: engine_conversions_pop {
    group_label: "PoP - Conversions"
    label: "Engine conversions % change"
    type: number
    sql: (${engine_conversions_cur} - ${engine_conversions_prior}) / NULLIF(ABS(${engine_conversions_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: all_conversions_pop {
    group_label: "PoP - Conversions"
    label: "All conversion actions % change"
    type: number
    sql: (${all_conversions_cur} - ${all_conversions_prior}) / NULLIF(ABS(${all_conversions_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: appointments_pop {
    group_label: "PoP - Conversions"
    label: "Appointments % change"
    type: number
    sql: (${appointments_cur} - ${appointments_prior}) / NULLIF(ABS(${appointments_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: cost_per_appointment_pop {
    group_label: "PoP - Conversions"
    label: "Cost per appointment % change"
    type: number
    sql: (${cost_per_appointment_cur} - ${cost_per_appointment_prior}) / NULLIF(ABS(${cost_per_appointment_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: calls_pop {
    group_label: "PoP - Conversions"
    label: "Calls % change"
    type: number
    sql: (${calls_cur} - ${calls_prior}) / NULLIF(ABS(${calls_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: cost_per_call_pop {
    group_label: "PoP - Conversions"
    label: "Cost per call % change"
    type: number
    sql: (${cost_per_call_cur} - ${cost_per_call_prior}) / NULLIF(ABS(${cost_per_call_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: clinic_leads_pop {
    group_label: "PoP - Conversions"
    label: "Clinic leads % change"
    type: number
    sql: (${clinic_leads_cur} - ${clinic_leads_prior}) / NULLIF(ABS(${clinic_leads_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: cost_per_lead_pop {
    group_label: "PoP - Conversions"
    label: "Cost per lead % change"
    type: number
    sql: (${cost_per_lead_cur} - ${cost_per_lead_prior}) / NULLIF(ABS(${cost_per_lead_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: total_clickthrough_conversions_pop {
    group_label: "PoP - Conversions"
    label: "Click-through conversions % change"
    type: number
    sql: (${total_clickthrough_conversions_cur} - ${total_clickthrough_conversions_prior}) / NULLIF(ABS(${total_clickthrough_conversions_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: total_viewthrough_conversions_pop {
    group_label: "PoP - Conversions"
    label: "View-through conversions % change"
    type: number
    sql: (${total_viewthrough_conversions_cur} - ${total_viewthrough_conversions_prior}) / NULLIF(ABS(${total_viewthrough_conversions_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: cvr_pop {
    group_label: "PoP - Conversions"
    label: "CVR % change"
    type: number
    sql: (${cvr_cur} - ${cvr_prior}) / NULLIF(ABS(${cvr_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: cpa_pop {
    group_label: "PoP - Conversions"
    label: "CPA % change"
    type: number
    sql: (${cpa_cur} - ${cpa_prior}) / NULLIF(ABS(${cpa_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: total_revenue_pop {
    group_label: "PoP - Value"
    label: "Revenue % change"
    type: number
    sql: (${total_revenue_cur} - ${total_revenue_prior}) / NULLIF(ABS(${total_revenue_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: revenue_all_actions_pop {
    group_label: "PoP - Value"
    label: "Revenue (all actions) % change"
    type: number
    sql: (${revenue_all_actions_cur} - ${revenue_all_actions_prior}) / NULLIF(ABS(${revenue_all_actions_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: roas_pop {
    group_label: "PoP - Value"
    label: "ROAS % change"
    type: number
    sql: (${roas_cur} - ${roas_prior}) / NULLIF(ABS(${roas_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: value_per_conversion_pop {
    group_label: "PoP - Value"
    label: "Value per conversion % change"
    type: number
    sql: (${value_per_conversion_cur} - ${value_per_conversion_prior}) / NULLIF(ABS(${value_per_conversion_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: total_video_views_pop {
    group_label: "PoP - Video"
    label: "Video views % change"
    type: number
    sql: (${total_video_views_cur} - ${total_video_views_prior}) / NULLIF(ABS(${total_video_views_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: total_video_completions_pop {
    group_label: "PoP - Video"
    label: "Video completions % change"
    type: number
    sql: (${total_video_completions_cur} - ${total_video_completions_prior}) / NULLIF(ABS(${total_video_completions_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: vtr_pop {
    group_label: "PoP - Video"
    label: "VTR (view rate) % change"
    type: number
    sql: (${vtr_cur} - ${vtr_prior}) / NULLIF(ABS(${vtr_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: vcr_pop {
    group_label: "PoP - Video"
    label: "Video completion rate % change"
    type: number
    sql: (${vcr_cur} - ${vcr_prior}) / NULLIF(ABS(${vcr_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: cpv_pop {
    group_label: "PoP - Video"
    label: "CPV % change"
    type: number
    sql: (${cpv_cur} - ${cpv_prior}) / NULLIF(ABS(${cpv_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: eligible_impressions_pop {
    group_label: "PoP - Competition"
    label: "Eligible impressions % change"
    type: number
    sql: (${eligible_impressions_cur} - ${eligible_impressions_prior}) / NULLIF(ABS(${eligible_impressions_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: impression_share_pop {
    group_label: "PoP - Competition"
    label: "Search impression share % change"
    type: number
    sql: (${impression_share_cur} - ${impression_share_prior}) / NULLIF(ABS(${impression_share_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: lost_is_rank_pop {
    group_label: "PoP - Competition"
    label: "Lost IS (rank) % change"
    type: number
    sql: (${lost_is_rank_cur} - ${lost_is_rank_prior}) / NULLIF(ABS(${lost_is_rank_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: lost_is_budget_pop {
    group_label: "PoP - Competition"
    label: "Lost IS (budget) % change"
    type: number
    sql: (${lost_is_budget_cur} - ${lost_is_budget_prior}) / NULLIF(ABS(${lost_is_budget_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: eligible_clicks_pop {
    group_label: "PoP - Competition"
    label: "Eligible clicks % change"
    type: number
    sql: (${eligible_clicks_cur} - ${eligible_clicks_prior}) / NULLIF(ABS(${eligible_clicks_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  measure: click_share_pop {
    group_label: "PoP - Competition"
    label: "Click share % change"
    type: number
    sql: (${click_share_cur} - ${click_share_prior}) / NULLIF(ABS(${click_share_prior}), 0) ;;
    value_format: "\"▲ \"0.0%;\"▼ \"0.0%;0.0%"
  }

  ######## MEASURES - ROW OVER ROW (DoD / WoW / MoM tables) ########

  # <metric>_change: this row vs the row before it, ordered by date. Works for
  # any time grain on the rows (day, week label, month) because it orders by the
  # earliest date in each row. % or absolute follows the delta_format parameter.
  # Totals rows show nothing (there is no previous row).

  measure: total_cost_change {
    group_label: "Row over row - Spend & traffic"
    label: "Δ Spend"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_cost} - LAG(${total_cost}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${total_cost} - LAG(${total_cost}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${total_cost}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'none' %}
      {% assign f = 'money' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: total_impressions_change {
    group_label: "Row over row - Spend & traffic"
    label: "Δ Impressions"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_impressions} - LAG(${total_impressions}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${total_impressions} - LAG(${total_impressions}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${total_impressions}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: total_clicks_change {
    group_label: "Row over row - Spend & traffic"
    label: "Δ Clicks"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_clicks} - LAG(${total_clicks}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${total_clicks} - LAG(${total_clicks}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${total_clicks}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: ctr_change {
    group_label: "Row over row - Spend & traffic"
    label: "Δ CTR"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${ctr} - LAG(${ctr}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${ctr} - LAG(${ctr}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${ctr}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cpc_change {
    group_label: "Row over row - Spend & traffic"
    label: "Δ CPC"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cpc} - LAG(${cpc}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${cpc} - LAG(${cpc}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${cpc}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cpm_change {
    group_label: "Row over row - Spend & traffic"
    label: "Δ CPM"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cpm} - LAG(${cpm}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${cpm} - LAG(${cpm}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${cpm}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: engine_conversions_change {
    group_label: "Row over row - Conversions"
    label: "Δ Engine conversions"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${engine_conversions} - LAG(${engine_conversions}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${engine_conversions} - LAG(${engine_conversions}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${engine_conversions}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: all_conversions_change {
    group_label: "Row over row - Conversions"
    label: "Δ All conversion actions"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${all_conversions} - LAG(${all_conversions}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${all_conversions} - LAG(${all_conversions}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${all_conversions}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: appointments_change {
    group_label: "Row over row - Conversions"
    label: "Δ Appointments"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${appointments} - LAG(${appointments}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${appointments} - LAG(${appointments}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${appointments}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cost_per_appointment_change {
    group_label: "Row over row - Conversions"
    label: "Δ Cost per appointment"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cost_per_appointment} - LAG(${cost_per_appointment}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${cost_per_appointment} - LAG(${cost_per_appointment}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${cost_per_appointment}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: calls_change {
    group_label: "Row over row - Conversions"
    label: "Δ Calls"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${calls} - LAG(${calls}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${calls} - LAG(${calls}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${calls}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cost_per_call_change {
    group_label: "Row over row - Conversions"
    label: "Δ Cost per call"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cost_per_call} - LAG(${cost_per_call}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${cost_per_call} - LAG(${cost_per_call}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${cost_per_call}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: clinic_leads_change {
    group_label: "Row over row - Conversions"
    label: "Δ Clinic leads"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${clinic_leads} - LAG(${clinic_leads}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${clinic_leads} - LAG(${clinic_leads}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${clinic_leads}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cost_per_lead_change {
    group_label: "Row over row - Conversions"
    label: "Δ Cost per lead"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cost_per_lead} - LAG(${cost_per_lead}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${cost_per_lead} - LAG(${cost_per_lead}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${cost_per_lead}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: total_clickthrough_conversions_change {
    group_label: "Row over row - Conversions"
    label: "Δ Click-through conversions"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_clickthrough_conversions} - LAG(${total_clickthrough_conversions}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${total_clickthrough_conversions} - LAG(${total_clickthrough_conversions}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${total_clickthrough_conversions}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: total_viewthrough_conversions_change {
    group_label: "Row over row - Conversions"
    label: "Δ View-through conversions"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_viewthrough_conversions} - LAG(${total_viewthrough_conversions}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${total_viewthrough_conversions} - LAG(${total_viewthrough_conversions}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${total_viewthrough_conversions}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cvr_change {
    group_label: "Row over row - Conversions"
    label: "Δ CVR"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cvr} - LAG(${cvr}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${cvr} - LAG(${cvr}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${cvr}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cpa_change {
    group_label: "Row over row - Conversions"
    label: "Δ CPA"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cpa} - LAG(${cpa}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${cpa} - LAG(${cpa}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${cpa}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: total_revenue_change {
    group_label: "Row over row - Value"
    label: "Δ Revenue"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_revenue} - LAG(${total_revenue}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${total_revenue} - LAG(${total_revenue}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${total_revenue}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'money' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: revenue_all_actions_change {
    group_label: "Row over row - Value"
    label: "Δ Revenue (all actions)"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${revenue_all_actions} - LAG(${revenue_all_actions}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${revenue_all_actions} - LAG(${revenue_all_actions}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${revenue_all_actions}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'money' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: roas_change {
    group_label: "Row over row - Value"
    label: "Δ ROAS"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${roas} - LAG(${roas}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${roas} - LAG(${roas}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${roas}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'x' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: value_per_conversion_change {
    group_label: "Row over row - Value"
    label: "Δ Value per conversion"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${value_per_conversion} - LAG(${value_per_conversion}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${value_per_conversion} - LAG(${value_per_conversion}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${value_per_conversion}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: total_video_views_change {
    group_label: "Row over row - Video"
    label: "Δ Video views"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_video_views} - LAG(${total_video_views}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${total_video_views} - LAG(${total_video_views}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${total_video_views}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: total_video_completions_change {
    group_label: "Row over row - Video"
    label: "Δ Video completions"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${total_video_completions} - LAG(${total_video_completions}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${total_video_completions} - LAG(${total_video_completions}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${total_video_completions}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: vtr_change {
    group_label: "Row over row - Video"
    label: "Δ VTR (view rate)"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${vtr} - LAG(${vtr}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${vtr} - LAG(${vtr}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${vtr}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: vcr_change {
    group_label: "Row over row - Video"
    label: "Δ Video completion rate"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${vcr} - LAG(${vcr}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${vcr} - LAG(${vcr}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${vcr}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: cpv_change {
    group_label: "Row over row - Video"
    label: "Δ CPV"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${cpv} - LAG(${cpv}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${cpv} - LAG(${cpv}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${cpv}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'money2' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: eligible_impressions_change {
    group_label: "Row over row - Competition"
    label: "Δ Eligible impressions"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${eligible_impressions} - LAG(${eligible_impressions}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${eligible_impressions} - LAG(${eligible_impressions}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${eligible_impressions}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: impression_share_change {
    group_label: "Row over row - Competition"
    label: "Δ Search impression share"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${impression_share} - LAG(${impression_share}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${impression_share} - LAG(${impression_share}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${impression_share}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: lost_is_rank_change {
    group_label: "Row over row - Competition"
    label: "Δ Lost IS (rank)"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${lost_is_rank} - LAG(${lost_is_rank}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${lost_is_rank} - LAG(${lost_is_rank}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${lost_is_rank}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: lost_is_budget_change {
    group_label: "Row over row - Competition"
    label: "Δ Lost IS (budget)"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${lost_is_budget} - LAG(${lost_is_budget}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${lost_is_budget} - LAG(${lost_is_budget}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${lost_is_budget}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'down' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: eligible_clicks_change {
    group_label: "Row over row - Competition"
    label: "Δ Eligible clicks"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${eligible_clicks} - LAG(${eligible_clicks}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${eligible_clicks} - LAG(${eligible_clicks}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${eligible_clicks}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'count' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: click_share_change {
    group_label: "Row over row - Competition"
    label: "Δ Click share"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${click_share} - LAG(${click_share}) OVER (ORDER BY MIN(${TABLE}."Date")) {% else %} (${click_share} - LAG(${click_share}) OVER (ORDER BY MIN(${TABLE}."Date"))) / NULLIF(ABS(LAG(${click_share}) OVER (ORDER BY MIN(${TABLE}."Date"))), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% assign pol = 'up' %}
      {% assign f = 'pct' %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  ######## MEASURES - SELECTED METRIC (driven by metric_selector_1 / _2) ########


  measure: selected_metric_1 {
    group_label: "Controls"
    label: "Metric 1"
    label_from_parameter: metric_selector_1
    type: number
    sql: {% if metric_selector_1._parameter_value == 'totalCost' %} ${total_cost}
         {% elsif metric_selector_1._parameter_value == 'totalImpressions' %} ${total_impressions}
         {% elsif metric_selector_1._parameter_value == 'totalClicks' %} ${total_clicks}
         {% elsif metric_selector_1._parameter_value == 'ctr' %} ${ctr}
         {% elsif metric_selector_1._parameter_value == 'cpc' %} ${cpc}
         {% elsif metric_selector_1._parameter_value == 'cpm' %} ${cpm}
         {% elsif metric_selector_1._parameter_value == 'engineConversions' %} ${engine_conversions}
         {% elsif metric_selector_1._parameter_value == 'allConversions' %} ${all_conversions}
         {% elsif metric_selector_1._parameter_value == 'appointments' %} ${appointments}
         {% elsif metric_selector_1._parameter_value == 'costPerAppointment' %} ${cost_per_appointment}
         {% elsif metric_selector_1._parameter_value == 'calls' %} ${calls}
         {% elsif metric_selector_1._parameter_value == 'costPerCall' %} ${cost_per_call}
         {% elsif metric_selector_1._parameter_value == 'clinicLeads' %} ${clinic_leads}
         {% elsif metric_selector_1._parameter_value == 'costPerLead' %} ${cost_per_lead}
         {% elsif metric_selector_1._parameter_value == 'totalClickthroughConversions' %} ${total_clickthrough_conversions}
         {% elsif metric_selector_1._parameter_value == 'totalViewthroughConversions' %} ${total_viewthrough_conversions}
         {% elsif metric_selector_1._parameter_value == 'cvr' %} ${cvr}
         {% elsif metric_selector_1._parameter_value == 'cpa' %} ${cpa}
         {% elsif metric_selector_1._parameter_value == 'totalRevenue' %} ${total_revenue}
         {% elsif metric_selector_1._parameter_value == 'revenueAllActions' %} ${revenue_all_actions}
         {% elsif metric_selector_1._parameter_value == 'roas' %} ${roas}
         {% elsif metric_selector_1._parameter_value == 'valuePerConversion' %} ${value_per_conversion}
         {% elsif metric_selector_1._parameter_value == 'totalVideoViews' %} ${total_video_views}
         {% elsif metric_selector_1._parameter_value == 'totalVideoCompletions' %} ${total_video_completions}
         {% elsif metric_selector_1._parameter_value == 'vtr' %} ${vtr}
         {% elsif metric_selector_1._parameter_value == 'vcr' %} ${vcr}
         {% elsif metric_selector_1._parameter_value == 'cpv' %} ${cpv}
         {% elsif metric_selector_1._parameter_value == 'eligibleImpressions' %} ${eligible_impressions}
         {% elsif metric_selector_1._parameter_value == 'impressionShare' %} ${impression_share}
         {% elsif metric_selector_1._parameter_value == 'lostIsRank' %} ${lost_is_rank}
         {% elsif metric_selector_1._parameter_value == 'lostIsBudget' %} ${lost_is_budget}
         {% elsif metric_selector_1._parameter_value == 'eligibleClicks' %} ${eligible_clicks}
         {% elsif metric_selector_1._parameter_value == 'clickShare' %} ${click_share}
         {% endif %} ;;
    html:
      {% if value == null %}&#8212;
      {% elsif metric_selector_1._parameter_value == 'totalCost' or metric_selector_1._parameter_value == 'totalRevenue' or metric_selector_1._parameter_value == 'revenueAllActions' %}{% if value >= 1000000 or value <= -1000000 %}&#36;{{ value | divided_by: 1000000.0 | round: 2 }}M{% elsif value >= 1000 or value <= -1000 %}&#36;{{ value | divided_by: 1000.0 | round: 1 }}K{% else %}&#36;{{ value | round: 0 }}{% endif %}
      {% elsif metric_selector_1._parameter_value == 'cpc' or metric_selector_1._parameter_value == 'cpm' or metric_selector_1._parameter_value == 'costPerAppointment' or metric_selector_1._parameter_value == 'costPerCall' or metric_selector_1._parameter_value == 'costPerLead' or metric_selector_1._parameter_value == 'cpa' or metric_selector_1._parameter_value == 'valuePerConversion' or metric_selector_1._parameter_value == 'cpv' %}&#36;{{ value | round: 2 }}
      {% elsif metric_selector_1._parameter_value == 'ctr' or metric_selector_1._parameter_value == 'cvr' or metric_selector_1._parameter_value == 'vtr' or metric_selector_1._parameter_value == 'vcr' %}{{ value | times: 100 | round: 2 }}%
      {% elsif metric_selector_1._parameter_value == 'impressionShare' or metric_selector_1._parameter_value == 'lostIsRank' or metric_selector_1._parameter_value == 'lostIsBudget' or metric_selector_1._parameter_value == 'clickShare' %}{{ value | times: 100 | round: 1 }}%
      {% elsif metric_selector_1._parameter_value == 'roas' %}{{ value | round: 2 }}x
      {% else %}{% if value >= 1000000 or value <= -1000000 %}{{ value | divided_by: 1000000.0 | round: 2 }}M{% elsif value >= 10000 or value <= -10000 %}{{ value | divided_by: 1000.0 | round: 1 }}K{% else %}{{ value | round: 0 }}{% endif %}{% endif %} ;;
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: selected_metric_1_cur {
    group_label: "Controls"
    label: "Metric 1 (current window)"
    label_from_parameter: metric_selector_1
    type: number
    sql: {% if metric_selector_1._parameter_value == 'totalCost' %} ${total_cost_cur}
         {% elsif metric_selector_1._parameter_value == 'totalImpressions' %} ${total_impressions_cur}
         {% elsif metric_selector_1._parameter_value == 'totalClicks' %} ${total_clicks_cur}
         {% elsif metric_selector_1._parameter_value == 'ctr' %} ${ctr_cur}
         {% elsif metric_selector_1._parameter_value == 'cpc' %} ${cpc_cur}
         {% elsif metric_selector_1._parameter_value == 'cpm' %} ${cpm_cur}
         {% elsif metric_selector_1._parameter_value == 'engineConversions' %} ${engine_conversions_cur}
         {% elsif metric_selector_1._parameter_value == 'allConversions' %} ${all_conversions_cur}
         {% elsif metric_selector_1._parameter_value == 'appointments' %} ${appointments_cur}
         {% elsif metric_selector_1._parameter_value == 'costPerAppointment' %} ${cost_per_appointment_cur}
         {% elsif metric_selector_1._parameter_value == 'calls' %} ${calls_cur}
         {% elsif metric_selector_1._parameter_value == 'costPerCall' %} ${cost_per_call_cur}
         {% elsif metric_selector_1._parameter_value == 'clinicLeads' %} ${clinic_leads_cur}
         {% elsif metric_selector_1._parameter_value == 'costPerLead' %} ${cost_per_lead_cur}
         {% elsif metric_selector_1._parameter_value == 'totalClickthroughConversions' %} ${total_clickthrough_conversions_cur}
         {% elsif metric_selector_1._parameter_value == 'totalViewthroughConversions' %} ${total_viewthrough_conversions_cur}
         {% elsif metric_selector_1._parameter_value == 'cvr' %} ${cvr_cur}
         {% elsif metric_selector_1._parameter_value == 'cpa' %} ${cpa_cur}
         {% elsif metric_selector_1._parameter_value == 'totalRevenue' %} ${total_revenue_cur}
         {% elsif metric_selector_1._parameter_value == 'revenueAllActions' %} ${revenue_all_actions_cur}
         {% elsif metric_selector_1._parameter_value == 'roas' %} ${roas_cur}
         {% elsif metric_selector_1._parameter_value == 'valuePerConversion' %} ${value_per_conversion_cur}
         {% elsif metric_selector_1._parameter_value == 'totalVideoViews' %} ${total_video_views_cur}
         {% elsif metric_selector_1._parameter_value == 'totalVideoCompletions' %} ${total_video_completions_cur}
         {% elsif metric_selector_1._parameter_value == 'vtr' %} ${vtr_cur}
         {% elsif metric_selector_1._parameter_value == 'vcr' %} ${vcr_cur}
         {% elsif metric_selector_1._parameter_value == 'cpv' %} ${cpv_cur}
         {% elsif metric_selector_1._parameter_value == 'eligibleImpressions' %} ${eligible_impressions_cur}
         {% elsif metric_selector_1._parameter_value == 'impressionShare' %} ${impression_share_cur}
         {% elsif metric_selector_1._parameter_value == 'lostIsRank' %} ${lost_is_rank_cur}
         {% elsif metric_selector_1._parameter_value == 'lostIsBudget' %} ${lost_is_budget_cur}
         {% elsif metric_selector_1._parameter_value == 'eligibleClicks' %} ${eligible_clicks_cur}
         {% elsif metric_selector_1._parameter_value == 'clickShare' %} ${click_share_cur}
         {% endif %} ;;
    html:
      {% if value == null %}&#8212;
      {% elsif metric_selector_1._parameter_value == 'totalCost' or metric_selector_1._parameter_value == 'totalRevenue' or metric_selector_1._parameter_value == 'revenueAllActions' %}{% if value >= 1000000 or value <= -1000000 %}&#36;{{ value | divided_by: 1000000.0 | round: 2 }}M{% elsif value >= 1000 or value <= -1000 %}&#36;{{ value | divided_by: 1000.0 | round: 1 }}K{% else %}&#36;{{ value | round: 0 }}{% endif %}
      {% elsif metric_selector_1._parameter_value == 'cpc' or metric_selector_1._parameter_value == 'cpm' or metric_selector_1._parameter_value == 'costPerAppointment' or metric_selector_1._parameter_value == 'costPerCall' or metric_selector_1._parameter_value == 'costPerLead' or metric_selector_1._parameter_value == 'cpa' or metric_selector_1._parameter_value == 'valuePerConversion' or metric_selector_1._parameter_value == 'cpv' %}&#36;{{ value | round: 2 }}
      {% elsif metric_selector_1._parameter_value == 'ctr' or metric_selector_1._parameter_value == 'cvr' or metric_selector_1._parameter_value == 'vtr' or metric_selector_1._parameter_value == 'vcr' %}{{ value | times: 100 | round: 2 }}%
      {% elsif metric_selector_1._parameter_value == 'impressionShare' or metric_selector_1._parameter_value == 'lostIsRank' or metric_selector_1._parameter_value == 'lostIsBudget' or metric_selector_1._parameter_value == 'clickShare' %}{{ value | times: 100 | round: 1 }}%
      {% elsif metric_selector_1._parameter_value == 'roas' %}{{ value | round: 2 }}x
      {% else %}{% if value >= 1000000 or value <= -1000000 %}{{ value | divided_by: 1000000.0 | round: 2 }}M{% elsif value >= 10000 or value <= -10000 %}{{ value | divided_by: 1000.0 | round: 1 }}K{% else %}{{ value | round: 0 }}{% endif %}{% endif %} ;;
    drill_fields: [drill_campaign*]
  }

  measure: selected_metric_1_prior {
    group_label: "Controls"
    label: "Metric 1 (comparison)"
    type: number
    sql: {% if metric_selector_1._parameter_value == 'totalCost' %} ${total_cost_prior}
         {% elsif metric_selector_1._parameter_value == 'totalImpressions' %} ${total_impressions_prior}
         {% elsif metric_selector_1._parameter_value == 'totalClicks' %} ${total_clicks_prior}
         {% elsif metric_selector_1._parameter_value == 'ctr' %} ${ctr_prior}
         {% elsif metric_selector_1._parameter_value == 'cpc' %} ${cpc_prior}
         {% elsif metric_selector_1._parameter_value == 'cpm' %} ${cpm_prior}
         {% elsif metric_selector_1._parameter_value == 'engineConversions' %} ${engine_conversions_prior}
         {% elsif metric_selector_1._parameter_value == 'allConversions' %} ${all_conversions_prior}
         {% elsif metric_selector_1._parameter_value == 'appointments' %} ${appointments_prior}
         {% elsif metric_selector_1._parameter_value == 'costPerAppointment' %} ${cost_per_appointment_prior}
         {% elsif metric_selector_1._parameter_value == 'calls' %} ${calls_prior}
         {% elsif metric_selector_1._parameter_value == 'costPerCall' %} ${cost_per_call_prior}
         {% elsif metric_selector_1._parameter_value == 'clinicLeads' %} ${clinic_leads_prior}
         {% elsif metric_selector_1._parameter_value == 'costPerLead' %} ${cost_per_lead_prior}
         {% elsif metric_selector_1._parameter_value == 'totalClickthroughConversions' %} ${total_clickthrough_conversions_prior}
         {% elsif metric_selector_1._parameter_value == 'totalViewthroughConversions' %} ${total_viewthrough_conversions_prior}
         {% elsif metric_selector_1._parameter_value == 'cvr' %} ${cvr_prior}
         {% elsif metric_selector_1._parameter_value == 'cpa' %} ${cpa_prior}
         {% elsif metric_selector_1._parameter_value == 'totalRevenue' %} ${total_revenue_prior}
         {% elsif metric_selector_1._parameter_value == 'revenueAllActions' %} ${revenue_all_actions_prior}
         {% elsif metric_selector_1._parameter_value == 'roas' %} ${roas_prior}
         {% elsif metric_selector_1._parameter_value == 'valuePerConversion' %} ${value_per_conversion_prior}
         {% elsif metric_selector_1._parameter_value == 'totalVideoViews' %} ${total_video_views_prior}
         {% elsif metric_selector_1._parameter_value == 'totalVideoCompletions' %} ${total_video_completions_prior}
         {% elsif metric_selector_1._parameter_value == 'vtr' %} ${vtr_prior}
         {% elsif metric_selector_1._parameter_value == 'vcr' %} ${vcr_prior}
         {% elsif metric_selector_1._parameter_value == 'cpv' %} ${cpv_prior}
         {% elsif metric_selector_1._parameter_value == 'eligibleImpressions' %} ${eligible_impressions_prior}
         {% elsif metric_selector_1._parameter_value == 'impressionShare' %} ${impression_share_prior}
         {% elsif metric_selector_1._parameter_value == 'lostIsRank' %} ${lost_is_rank_prior}
         {% elsif metric_selector_1._parameter_value == 'lostIsBudget' %} ${lost_is_budget_prior}
         {% elsif metric_selector_1._parameter_value == 'eligibleClicks' %} ${eligible_clicks_prior}
         {% elsif metric_selector_1._parameter_value == 'clickShare' %} ${click_share_prior}
         {% endif %} ;;
    html:
      {% if value == null %}&#8212;
      {% elsif metric_selector_1._parameter_value == 'totalCost' or metric_selector_1._parameter_value == 'totalRevenue' or metric_selector_1._parameter_value == 'revenueAllActions' %}{% if value >= 1000000 or value <= -1000000 %}&#36;{{ value | divided_by: 1000000.0 | round: 2 }}M{% elsif value >= 1000 or value <= -1000 %}&#36;{{ value | divided_by: 1000.0 | round: 1 }}K{% else %}&#36;{{ value | round: 0 }}{% endif %}
      {% elsif metric_selector_1._parameter_value == 'cpc' or metric_selector_1._parameter_value == 'cpm' or metric_selector_1._parameter_value == 'costPerAppointment' or metric_selector_1._parameter_value == 'costPerCall' or metric_selector_1._parameter_value == 'costPerLead' or metric_selector_1._parameter_value == 'cpa' or metric_selector_1._parameter_value == 'valuePerConversion' or metric_selector_1._parameter_value == 'cpv' %}&#36;{{ value | round: 2 }}
      {% elsif metric_selector_1._parameter_value == 'ctr' or metric_selector_1._parameter_value == 'cvr' or metric_selector_1._parameter_value == 'vtr' or metric_selector_1._parameter_value == 'vcr' %}{{ value | times: 100 | round: 2 }}%
      {% elsif metric_selector_1._parameter_value == 'impressionShare' or metric_selector_1._parameter_value == 'lostIsRank' or metric_selector_1._parameter_value == 'lostIsBudget' or metric_selector_1._parameter_value == 'clickShare' %}{{ value | times: 100 | round: 1 }}%
      {% elsif metric_selector_1._parameter_value == 'roas' %}{{ value | round: 2 }}x
      {% else %}{% if value >= 1000000 or value <= -1000000 %}{{ value | divided_by: 1000000.0 | round: 2 }}M{% elsif value >= 10000 or value <= -10000 %}{{ value | divided_by: 1000.0 | round: 1 }}K{% else %}{{ value | round: 0 }}{% endif %}{% endif %} ;;
    drill_fields: [drill_campaign*]
  }

  measure: selected_metric_1_delta {
    group_label: "Controls"
    label: "Metric 1 delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${selected_metric_1_cur} - ${selected_metric_1_prior} {% else %} (${selected_metric_1_cur} - ${selected_metric_1_prior}) / NULLIF(ABS(${selected_metric_1_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% if metric_selector_1._parameter_value == 'cpc' or metric_selector_1._parameter_value == 'cpm' or metric_selector_1._parameter_value == 'costPerAppointment' or metric_selector_1._parameter_value == 'costPerCall' or metric_selector_1._parameter_value == 'costPerLead' or metric_selector_1._parameter_value == 'cpa' or metric_selector_1._parameter_value == 'cpv' or metric_selector_1._parameter_value == 'lostIsRank' or metric_selector_1._parameter_value == 'lostIsBudget' %}{% assign pol = 'down' %}{% elsif metric_selector_1._parameter_value == 'totalCost' %}{% assign pol = 'none' %}{% else %}{% assign pol = 'up' %}{% endif %}
      {% if metric_selector_1._parameter_value == 'ctr' or metric_selector_1._parameter_value == 'cvr' or metric_selector_1._parameter_value == 'vtr' or metric_selector_1._parameter_value == 'vcr' or metric_selector_1._parameter_value == 'impressionShare' or metric_selector_1._parameter_value == 'lostIsRank' or metric_selector_1._parameter_value == 'lostIsBudget' or metric_selector_1._parameter_value == 'clickShare' %}{% assign f = 'pct' %}{% elsif metric_selector_1._parameter_value == 'totalCost' or metric_selector_1._parameter_value == 'totalRevenue' or metric_selector_1._parameter_value == 'revenueAllActions' %}{% assign f = 'money' %}{% elsif metric_selector_1._parameter_value == 'cpc' or metric_selector_1._parameter_value == 'cpm' or metric_selector_1._parameter_value == 'costPerAppointment' or metric_selector_1._parameter_value == 'costPerCall' or metric_selector_1._parameter_value == 'costPerLead' or metric_selector_1._parameter_value == 'cpa' or metric_selector_1._parameter_value == 'valuePerConversion' or metric_selector_1._parameter_value == 'cpv' %}{% assign f = 'money2' %}{% elsif metric_selector_1._parameter_value == 'roas' %}{% assign f = 'x' %}{% else %}{% assign f = 'count' %}{% endif %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  measure: selected_metric_2 {
    group_label: "Controls"
    label: "Metric 2"
    label_from_parameter: metric_selector_2
    type: number
    sql: {% if metric_selector_2._parameter_value == 'totalCost' %} ${total_cost}
         {% elsif metric_selector_2._parameter_value == 'totalImpressions' %} ${total_impressions}
         {% elsif metric_selector_2._parameter_value == 'totalClicks' %} ${total_clicks}
         {% elsif metric_selector_2._parameter_value == 'ctr' %} ${ctr}
         {% elsif metric_selector_2._parameter_value == 'cpc' %} ${cpc}
         {% elsif metric_selector_2._parameter_value == 'cpm' %} ${cpm}
         {% elsif metric_selector_2._parameter_value == 'engineConversions' %} ${engine_conversions}
         {% elsif metric_selector_2._parameter_value == 'allConversions' %} ${all_conversions}
         {% elsif metric_selector_2._parameter_value == 'appointments' %} ${appointments}
         {% elsif metric_selector_2._parameter_value == 'costPerAppointment' %} ${cost_per_appointment}
         {% elsif metric_selector_2._parameter_value == 'calls' %} ${calls}
         {% elsif metric_selector_2._parameter_value == 'costPerCall' %} ${cost_per_call}
         {% elsif metric_selector_2._parameter_value == 'clinicLeads' %} ${clinic_leads}
         {% elsif metric_selector_2._parameter_value == 'costPerLead' %} ${cost_per_lead}
         {% elsif metric_selector_2._parameter_value == 'totalClickthroughConversions' %} ${total_clickthrough_conversions}
         {% elsif metric_selector_2._parameter_value == 'totalViewthroughConversions' %} ${total_viewthrough_conversions}
         {% elsif metric_selector_2._parameter_value == 'cvr' %} ${cvr}
         {% elsif metric_selector_2._parameter_value == 'cpa' %} ${cpa}
         {% elsif metric_selector_2._parameter_value == 'totalRevenue' %} ${total_revenue}
         {% elsif metric_selector_2._parameter_value == 'revenueAllActions' %} ${revenue_all_actions}
         {% elsif metric_selector_2._parameter_value == 'roas' %} ${roas}
         {% elsif metric_selector_2._parameter_value == 'valuePerConversion' %} ${value_per_conversion}
         {% elsif metric_selector_2._parameter_value == 'totalVideoViews' %} ${total_video_views}
         {% elsif metric_selector_2._parameter_value == 'totalVideoCompletions' %} ${total_video_completions}
         {% elsif metric_selector_2._parameter_value == 'vtr' %} ${vtr}
         {% elsif metric_selector_2._parameter_value == 'vcr' %} ${vcr}
         {% elsif metric_selector_2._parameter_value == 'cpv' %} ${cpv}
         {% elsif metric_selector_2._parameter_value == 'eligibleImpressions' %} ${eligible_impressions}
         {% elsif metric_selector_2._parameter_value == 'impressionShare' %} ${impression_share}
         {% elsif metric_selector_2._parameter_value == 'lostIsRank' %} ${lost_is_rank}
         {% elsif metric_selector_2._parameter_value == 'lostIsBudget' %} ${lost_is_budget}
         {% elsif metric_selector_2._parameter_value == 'eligibleClicks' %} ${eligible_clicks}
         {% elsif metric_selector_2._parameter_value == 'clickShare' %} ${click_share}
         {% endif %} ;;
    html:
      {% if value == null %}&#8212;
      {% elsif metric_selector_2._parameter_value == 'totalCost' or metric_selector_2._parameter_value == 'totalRevenue' or metric_selector_2._parameter_value == 'revenueAllActions' %}{% if value >= 1000000 or value <= -1000000 %}&#36;{{ value | divided_by: 1000000.0 | round: 2 }}M{% elsif value >= 1000 or value <= -1000 %}&#36;{{ value | divided_by: 1000.0 | round: 1 }}K{% else %}&#36;{{ value | round: 0 }}{% endif %}
      {% elsif metric_selector_2._parameter_value == 'cpc' or metric_selector_2._parameter_value == 'cpm' or metric_selector_2._parameter_value == 'costPerAppointment' or metric_selector_2._parameter_value == 'costPerCall' or metric_selector_2._parameter_value == 'costPerLead' or metric_selector_2._parameter_value == 'cpa' or metric_selector_2._parameter_value == 'valuePerConversion' or metric_selector_2._parameter_value == 'cpv' %}&#36;{{ value | round: 2 }}
      {% elsif metric_selector_2._parameter_value == 'ctr' or metric_selector_2._parameter_value == 'cvr' or metric_selector_2._parameter_value == 'vtr' or metric_selector_2._parameter_value == 'vcr' %}{{ value | times: 100 | round: 2 }}%
      {% elsif metric_selector_2._parameter_value == 'impressionShare' or metric_selector_2._parameter_value == 'lostIsRank' or metric_selector_2._parameter_value == 'lostIsBudget' or metric_selector_2._parameter_value == 'clickShare' %}{{ value | times: 100 | round: 1 }}%
      {% elsif metric_selector_2._parameter_value == 'roas' %}{{ value | round: 2 }}x
      {% else %}{% if value >= 1000000 or value <= -1000000 %}{{ value | divided_by: 1000000.0 | round: 2 }}M{% elsif value >= 10000 or value <= -10000 %}{{ value | divided_by: 1000.0 | round: 1 }}K{% else %}{{ value | round: 0 }}{% endif %}{% endif %} ;;
    drill_fields: [drill_campaign*]
    link: { label: "By Region" url: "@{AFC_DRILL_BY_REGION}" }
    link: { label: "By Account" url: "@{AFC_DRILL_BY_ACCOUNT}" }
    link: { label: "By Condition" url: "@{AFC_DRILL_BY_CONDITION}" }
    link: { label: "By Budget group" url: "@{AFC_DRILL_BY_BUDGET_GROUP}" }
    link: { label: "By Mapping channel" url: "@{AFC_DRILL_BY_MAPPING_CHANNEL}" }
    link: { label: "By Channel" url: "@{AFC_DRILL_BY_CHANNEL}" }
    link: { label: "By Campaign" url: "@{AFC_DRILL_BY_CAMPAIGN}" }
    link: { label: "By Ad group" url: "@{AFC_DRILL_BY_AD_GROUP}" }
    link: { label: "By Device" url: "@{AFC_DRILL_BY_DEVICE}" }
    link: { label: "By Market (inferred)" url: "@{AFC_DRILL_BY_MARKET}" }
    link: { label: "By Day" url: "@{AFC_DRILL_BY_DAY}" }
    link: { label: "By Week" url: "@{AFC_DRILL_BY_WEEK}" }
    link: { label: "By Month" url: "@{AFC_DRILL_BY_MONTH}" }
  }

  measure: selected_metric_2_cur {
    group_label: "Controls"
    label: "Metric 2 (current window)"
    label_from_parameter: metric_selector_2
    type: number
    sql: {% if metric_selector_2._parameter_value == 'totalCost' %} ${total_cost_cur}
         {% elsif metric_selector_2._parameter_value == 'totalImpressions' %} ${total_impressions_cur}
         {% elsif metric_selector_2._parameter_value == 'totalClicks' %} ${total_clicks_cur}
         {% elsif metric_selector_2._parameter_value == 'ctr' %} ${ctr_cur}
         {% elsif metric_selector_2._parameter_value == 'cpc' %} ${cpc_cur}
         {% elsif metric_selector_2._parameter_value == 'cpm' %} ${cpm_cur}
         {% elsif metric_selector_2._parameter_value == 'engineConversions' %} ${engine_conversions_cur}
         {% elsif metric_selector_2._parameter_value == 'allConversions' %} ${all_conversions_cur}
         {% elsif metric_selector_2._parameter_value == 'appointments' %} ${appointments_cur}
         {% elsif metric_selector_2._parameter_value == 'costPerAppointment' %} ${cost_per_appointment_cur}
         {% elsif metric_selector_2._parameter_value == 'calls' %} ${calls_cur}
         {% elsif metric_selector_2._parameter_value == 'costPerCall' %} ${cost_per_call_cur}
         {% elsif metric_selector_2._parameter_value == 'clinicLeads' %} ${clinic_leads_cur}
         {% elsif metric_selector_2._parameter_value == 'costPerLead' %} ${cost_per_lead_cur}
         {% elsif metric_selector_2._parameter_value == 'totalClickthroughConversions' %} ${total_clickthrough_conversions_cur}
         {% elsif metric_selector_2._parameter_value == 'totalViewthroughConversions' %} ${total_viewthrough_conversions_cur}
         {% elsif metric_selector_2._parameter_value == 'cvr' %} ${cvr_cur}
         {% elsif metric_selector_2._parameter_value == 'cpa' %} ${cpa_cur}
         {% elsif metric_selector_2._parameter_value == 'totalRevenue' %} ${total_revenue_cur}
         {% elsif metric_selector_2._parameter_value == 'revenueAllActions' %} ${revenue_all_actions_cur}
         {% elsif metric_selector_2._parameter_value == 'roas' %} ${roas_cur}
         {% elsif metric_selector_2._parameter_value == 'valuePerConversion' %} ${value_per_conversion_cur}
         {% elsif metric_selector_2._parameter_value == 'totalVideoViews' %} ${total_video_views_cur}
         {% elsif metric_selector_2._parameter_value == 'totalVideoCompletions' %} ${total_video_completions_cur}
         {% elsif metric_selector_2._parameter_value == 'vtr' %} ${vtr_cur}
         {% elsif metric_selector_2._parameter_value == 'vcr' %} ${vcr_cur}
         {% elsif metric_selector_2._parameter_value == 'cpv' %} ${cpv_cur}
         {% elsif metric_selector_2._parameter_value == 'eligibleImpressions' %} ${eligible_impressions_cur}
         {% elsif metric_selector_2._parameter_value == 'impressionShare' %} ${impression_share_cur}
         {% elsif metric_selector_2._parameter_value == 'lostIsRank' %} ${lost_is_rank_cur}
         {% elsif metric_selector_2._parameter_value == 'lostIsBudget' %} ${lost_is_budget_cur}
         {% elsif metric_selector_2._parameter_value == 'eligibleClicks' %} ${eligible_clicks_cur}
         {% elsif metric_selector_2._parameter_value == 'clickShare' %} ${click_share_cur}
         {% endif %} ;;
    html:
      {% if value == null %}&#8212;
      {% elsif metric_selector_2._parameter_value == 'totalCost' or metric_selector_2._parameter_value == 'totalRevenue' or metric_selector_2._parameter_value == 'revenueAllActions' %}{% if value >= 1000000 or value <= -1000000 %}&#36;{{ value | divided_by: 1000000.0 | round: 2 }}M{% elsif value >= 1000 or value <= -1000 %}&#36;{{ value | divided_by: 1000.0 | round: 1 }}K{% else %}&#36;{{ value | round: 0 }}{% endif %}
      {% elsif metric_selector_2._parameter_value == 'cpc' or metric_selector_2._parameter_value == 'cpm' or metric_selector_2._parameter_value == 'costPerAppointment' or metric_selector_2._parameter_value == 'costPerCall' or metric_selector_2._parameter_value == 'costPerLead' or metric_selector_2._parameter_value == 'cpa' or metric_selector_2._parameter_value == 'valuePerConversion' or metric_selector_2._parameter_value == 'cpv' %}&#36;{{ value | round: 2 }}
      {% elsif metric_selector_2._parameter_value == 'ctr' or metric_selector_2._parameter_value == 'cvr' or metric_selector_2._parameter_value == 'vtr' or metric_selector_2._parameter_value == 'vcr' %}{{ value | times: 100 | round: 2 }}%
      {% elsif metric_selector_2._parameter_value == 'impressionShare' or metric_selector_2._parameter_value == 'lostIsRank' or metric_selector_2._parameter_value == 'lostIsBudget' or metric_selector_2._parameter_value == 'clickShare' %}{{ value | times: 100 | round: 1 }}%
      {% elsif metric_selector_2._parameter_value == 'roas' %}{{ value | round: 2 }}x
      {% else %}{% if value >= 1000000 or value <= -1000000 %}{{ value | divided_by: 1000000.0 | round: 2 }}M{% elsif value >= 10000 or value <= -10000 %}{{ value | divided_by: 1000.0 | round: 1 }}K{% else %}{{ value | round: 0 }}{% endif %}{% endif %} ;;
    drill_fields: [drill_campaign*]
  }

  measure: selected_metric_2_prior {
    group_label: "Controls"
    label: "Metric 2 (comparison)"
    type: number
    sql: {% if metric_selector_2._parameter_value == 'totalCost' %} ${total_cost_prior}
         {% elsif metric_selector_2._parameter_value == 'totalImpressions' %} ${total_impressions_prior}
         {% elsif metric_selector_2._parameter_value == 'totalClicks' %} ${total_clicks_prior}
         {% elsif metric_selector_2._parameter_value == 'ctr' %} ${ctr_prior}
         {% elsif metric_selector_2._parameter_value == 'cpc' %} ${cpc_prior}
         {% elsif metric_selector_2._parameter_value == 'cpm' %} ${cpm_prior}
         {% elsif metric_selector_2._parameter_value == 'engineConversions' %} ${engine_conversions_prior}
         {% elsif metric_selector_2._parameter_value == 'allConversions' %} ${all_conversions_prior}
         {% elsif metric_selector_2._parameter_value == 'appointments' %} ${appointments_prior}
         {% elsif metric_selector_2._parameter_value == 'costPerAppointment' %} ${cost_per_appointment_prior}
         {% elsif metric_selector_2._parameter_value == 'calls' %} ${calls_prior}
         {% elsif metric_selector_2._parameter_value == 'costPerCall' %} ${cost_per_call_prior}
         {% elsif metric_selector_2._parameter_value == 'clinicLeads' %} ${clinic_leads_prior}
         {% elsif metric_selector_2._parameter_value == 'costPerLead' %} ${cost_per_lead_prior}
         {% elsif metric_selector_2._parameter_value == 'totalClickthroughConversions' %} ${total_clickthrough_conversions_prior}
         {% elsif metric_selector_2._parameter_value == 'totalViewthroughConversions' %} ${total_viewthrough_conversions_prior}
         {% elsif metric_selector_2._parameter_value == 'cvr' %} ${cvr_prior}
         {% elsif metric_selector_2._parameter_value == 'cpa' %} ${cpa_prior}
         {% elsif metric_selector_2._parameter_value == 'totalRevenue' %} ${total_revenue_prior}
         {% elsif metric_selector_2._parameter_value == 'revenueAllActions' %} ${revenue_all_actions_prior}
         {% elsif metric_selector_2._parameter_value == 'roas' %} ${roas_prior}
         {% elsif metric_selector_2._parameter_value == 'valuePerConversion' %} ${value_per_conversion_prior}
         {% elsif metric_selector_2._parameter_value == 'totalVideoViews' %} ${total_video_views_prior}
         {% elsif metric_selector_2._parameter_value == 'totalVideoCompletions' %} ${total_video_completions_prior}
         {% elsif metric_selector_2._parameter_value == 'vtr' %} ${vtr_prior}
         {% elsif metric_selector_2._parameter_value == 'vcr' %} ${vcr_prior}
         {% elsif metric_selector_2._parameter_value == 'cpv' %} ${cpv_prior}
         {% elsif metric_selector_2._parameter_value == 'eligibleImpressions' %} ${eligible_impressions_prior}
         {% elsif metric_selector_2._parameter_value == 'impressionShare' %} ${impression_share_prior}
         {% elsif metric_selector_2._parameter_value == 'lostIsRank' %} ${lost_is_rank_prior}
         {% elsif metric_selector_2._parameter_value == 'lostIsBudget' %} ${lost_is_budget_prior}
         {% elsif metric_selector_2._parameter_value == 'eligibleClicks' %} ${eligible_clicks_prior}
         {% elsif metric_selector_2._parameter_value == 'clickShare' %} ${click_share_prior}
         {% endif %} ;;
    html:
      {% if value == null %}&#8212;
      {% elsif metric_selector_2._parameter_value == 'totalCost' or metric_selector_2._parameter_value == 'totalRevenue' or metric_selector_2._parameter_value == 'revenueAllActions' %}{% if value >= 1000000 or value <= -1000000 %}&#36;{{ value | divided_by: 1000000.0 | round: 2 }}M{% elsif value >= 1000 or value <= -1000 %}&#36;{{ value | divided_by: 1000.0 | round: 1 }}K{% else %}&#36;{{ value | round: 0 }}{% endif %}
      {% elsif metric_selector_2._parameter_value == 'cpc' or metric_selector_2._parameter_value == 'cpm' or metric_selector_2._parameter_value == 'costPerAppointment' or metric_selector_2._parameter_value == 'costPerCall' or metric_selector_2._parameter_value == 'costPerLead' or metric_selector_2._parameter_value == 'cpa' or metric_selector_2._parameter_value == 'valuePerConversion' or metric_selector_2._parameter_value == 'cpv' %}&#36;{{ value | round: 2 }}
      {% elsif metric_selector_2._parameter_value == 'ctr' or metric_selector_2._parameter_value == 'cvr' or metric_selector_2._parameter_value == 'vtr' or metric_selector_2._parameter_value == 'vcr' %}{{ value | times: 100 | round: 2 }}%
      {% elsif metric_selector_2._parameter_value == 'impressionShare' or metric_selector_2._parameter_value == 'lostIsRank' or metric_selector_2._parameter_value == 'lostIsBudget' or metric_selector_2._parameter_value == 'clickShare' %}{{ value | times: 100 | round: 1 }}%
      {% elsif metric_selector_2._parameter_value == 'roas' %}{{ value | round: 2 }}x
      {% else %}{% if value >= 1000000 or value <= -1000000 %}{{ value | divided_by: 1000000.0 | round: 2 }}M{% elsif value >= 10000 or value <= -10000 %}{{ value | divided_by: 1000.0 | round: 1 }}K{% else %}{{ value | round: 0 }}{% endif %}{% endif %} ;;
    drill_fields: [drill_campaign*]
  }

  measure: selected_metric_2_delta {
    group_label: "Controls"
    label: "Metric 2 delta"
    type: number
    sql: {% if delta_format._parameter_value == 'abs' %} ${selected_metric_2_cur} - ${selected_metric_2_prior} {% else %} (${selected_metric_2_cur} - ${selected_metric_2_prior}) / NULLIF(ABS(${selected_metric_2_prior}), 0) {% endif %} ;;
    html:
      {% if value == null %}<span style="color:#8A929C">&#8212;</span>{% else %}
      {% if metric_selector_2._parameter_value == 'cpc' or metric_selector_2._parameter_value == 'cpm' or metric_selector_2._parameter_value == 'costPerAppointment' or metric_selector_2._parameter_value == 'costPerCall' or metric_selector_2._parameter_value == 'costPerLead' or metric_selector_2._parameter_value == 'cpa' or metric_selector_2._parameter_value == 'cpv' or metric_selector_2._parameter_value == 'lostIsRank' or metric_selector_2._parameter_value == 'lostIsBudget' %}{% assign pol = 'down' %}{% elsif metric_selector_2._parameter_value == 'totalCost' %}{% assign pol = 'none' %}{% else %}{% assign pol = 'up' %}{% endif %}
      {% if metric_selector_2._parameter_value == 'ctr' or metric_selector_2._parameter_value == 'cvr' or metric_selector_2._parameter_value == 'vtr' or metric_selector_2._parameter_value == 'vcr' or metric_selector_2._parameter_value == 'impressionShare' or metric_selector_2._parameter_value == 'lostIsRank' or metric_selector_2._parameter_value == 'lostIsBudget' or metric_selector_2._parameter_value == 'clickShare' %}{% assign f = 'pct' %}{% elsif metric_selector_2._parameter_value == 'totalCost' or metric_selector_2._parameter_value == 'totalRevenue' or metric_selector_2._parameter_value == 'revenueAllActions' %}{% assign f = 'money' %}{% elsif metric_selector_2._parameter_value == 'cpc' or metric_selector_2._parameter_value == 'cpm' or metric_selector_2._parameter_value == 'costPerAppointment' or metric_selector_2._parameter_value == 'costPerCall' or metric_selector_2._parameter_value == 'costPerLead' or metric_selector_2._parameter_value == 'cpa' or metric_selector_2._parameter_value == 'valuePerConversion' or metric_selector_2._parameter_value == 'cpv' %}{% assign f = 'money2' %}{% elsif metric_selector_2._parameter_value == 'roas' %}{% assign f = 'x' %}{% else %}{% assign f = 'count' %}{% endif %}
      {% if value == 0 or pol == 'none' %}{% assign c = '#5E6671' %}{% elsif value > 0 and pol == 'up' %}{% assign c = '#1E7B4F' %}{% elsif value < 0 and pol == 'down' %}{% assign c = '#1E7B4F' %}{% else %}{% assign c = '#B42318' %}{% endif %}
      <span style="color:{{ c }};font-weight:600">{% if value > 0 %}&#9650;{% elsif value < 0 %}&#9660;{% endif %}
      {% if delta_format._parameter_value == 'abs' %}{% if f == 'pct' %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 2 }} pts{% elsif f == 'money' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 0 }}{% else %}{{ value | round: 0 }}{% endif %}{% elsif f == 'money2' %}{% if value < 0 %}-{% else %}+{% endif %}&#36;{% if value < 0 %}{{ value | times: -1 | round: 2 }}{% else %}{{ value | round: 2 }}{% endif %}{% elsif f == 'x' %}{% if value > 0 %}+{% endif %}{{ value | round: 2 }}x{% else %}{% if value > 0 %}+{% endif %}{{ value | round: 0 }}{% endif %}{% else %}{% if value > 0 %}+{% endif %}{{ value | times: 100 | round: 1 }}%{% endif %}</span>{% endif %} ;;
  }

  ######## DRILL SETS ########

  set: drill_metrics {
    fields: [total_cost, total_impressions, total_clicks, ctr, cpc, engine_conversions, cvr, cpa, total_revenue, roas]
  }

  set: drill_campaign {
    fields: [region, account, mapping_channel, condition, budget_group, campaign, drill_metrics*]
  }

  set: drill_competition {
    fields: [account, campaign, eligible_impressions, total_impressions, impression_share, lost_is_rank, lost_is_budget, click_share]
  }
}

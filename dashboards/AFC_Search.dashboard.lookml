# =============================================================================
# AFC Search dashboard - LookML
#
# Structure follows the Search Template dashboard: native tabs, a side menu of
# button tiles in every tab, a banner, inline filters placed right above the
# tile they drive, and one dashboard filter per control feeding the shared
# view parameters (metric_selector_*, dimension_selector_*, comparison_mode,
# delta_format, date_granularity).
#
# Model afc_search (afc_search.model), explore american_family_care_search_looker_table.
# Logo and Dictionary links point to the AFC logo, the Auto-Pacing sheet
# (mapping and budget tabs live there) and the data dictionary document.
#
# Comparison tiles (KPIs, delta tiles, cmp tables) take 'Date Range' on the
# templated date_range field; every other tile takes it on date_date.
# =============================================================================

- dashboard: afc_search
  title: "AFC Search Dashboard"
  description: "American Family Care search performance and budget pacing. Replaces the Auto-Pacing sheet."
  layout: newspaper
  preferred_viewer: dashboards-next
  crossfilter_enabled: false
  refresh: 1 hour
  filters_location_top: true

  tabs:
  - name: Executive
    label: "Executive overview"
  - name: Conversion
    label: "Conversion"
  - name: Traffic
    label: "Traffic"
  - name: Competition
    label: "Competition"
  - name: Operations
    label: "Operations"
  - name: Dictionary
    label: "Data dictionary"

  # ===========================================================================
  # Filters (global ones sit in the filter bar; the rest are placed inline)
  # ===========================================================================
  filters:

  - name: Date Range
    title: "Date range"
    type: field_filter
    default_value: "30 days ago for 30 days"
    allow_multiple_values: false
    required: false
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.date_date

  - name: Region
    title: "Region"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.region
    ui_config:
      type: dropdown_menu
      display: inline

  - name: Account
    title: "Account"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.account_rollup
    ui_config:
      type: dropdown_menu
      display: inline

  - name: Condition
    title: "Condition"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: [Region, Account]
    field: american_family_care_search_looker_table.condition
    ui_config:
      type: dropdown_menu
      display: inline

  - name: Budget Group
    title: "Budget group"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: [Region, Account]
    field: american_family_care_search_looker_table.budget_group
    ui_config:
      type: dropdown_menu
      display: inline

  - name: Mapping Channel
    title: "Keyword type"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.mapping_channel
    ui_config:
      type: dropdown_menu
      display: inline

  - name: Channel
    title: "Campaign type"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.channel
    ui_config:
      type: dropdown_menu
      display: inline


  - name: Conversion Type
    title: "Conversion type"
    type: field_filter
    default_value: "Appointment clicks,Calls,Clinic leads"
    allow_multiple_values: true
    required: false
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.conversion_actions
    ui_config:
      type: dropdown_menu
      display: inline

  - name: KPI Comparison
    title: "Compare period with"
    type: field_filter
    default_value: "prev"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.comparison_mode
    ui_config:
      type: dropdown_menu
      display: inline

  - name: DoD Delta Format
    title: "Show delta as"
    type: field_filter
    default_value: "pct"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.delta_format
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: WoW Delta Format
    title: "Show delta as"
    type: field_filter
    default_value: "pct"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.delta_format
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: MoM Delta Format
    title: "Show delta as"
    type: field_filter
    default_value: "pct"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.delta_format
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Granularity
    title: "Granularity"
    type: field_filter
    default_value: "day"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.date_granularity
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Traffic Granularity
    title: "Granularity"
    type: field_filter
    default_value: "day"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.date_granularity
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Comp Granularity
    title: "Granularity"
    type: field_filter
    default_value: "day"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.date_granularity
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Ops Granularity
    title: "Granularity"
    type: field_filter
    default_value: "day"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.date_granularity
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Bars
    title: "Trend bars"
    type: field_filter
    default_value: "engineConversions"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.metric_selector_1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Line
    title: "Trend line"
    type: field_filter
    default_value: "cpa"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.metric_selector_2
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Stack Metric
    title: "Metric"
    type: field_filter
    default_value: "totalImpressions"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.metric_selector_1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Stack Rows
    title: "Rows dimension"
    type: field_filter
    default_value: "mappingChannel"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.dimension_selector_1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Stack Color
    title: "Color dimension"
    type: field_filter
    default_value: "campaign"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.dimension_selector_2
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Breakdown Rows
    title: "Breakdown rows"
    type: field_filter
    default_value: "condition"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.dimension_selector_1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Breakdown Metric
    title: "Breakdown metric"
    type: field_filter
    default_value: "engineConversions"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.metric_selector_1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Over Time By
    title: "Over time by"
    type: field_filter
    default_value: "mappingChannel"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.dimension_selector_2
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Over Time Metric
    title: "Over time metric"
    type: field_filter
    default_value: "engineConversions"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.metric_selector_2
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Table By
    title: "Conversions table by"
    type: field_filter
    default_value: "condition"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.dimension_selector_1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Traffic Bars
    title: "Trend bars"
    type: field_filter
    default_value: "totalClicks"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.metric_selector_1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Traffic Line
    title: "Trend line"
    type: field_filter
    default_value: "ctr"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.metric_selector_2
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Traffic Breakdown Rows
    title: "Breakdown rows"
    type: field_filter
    default_value: "mappingChannel"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.dimension_selector_1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Traffic Breakdown Metric
    title: "Breakdown metric"
    type: field_filter
    default_value: "totalClicks"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.metric_selector_1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Top Campaigns By
    title: "Top campaigns by"
    type: field_filter
    default_value: "totalClicks"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.metric_selector_2
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Ops Campaign
    title: "Campaign"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: [Region, Account]
    field: american_family_care_search_looker_table.campaign
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Budget Month
    title: "Budget month"
    type: field_filter
    default_value: "this month"
    allow_multiple_values: false
    required: false
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.date_month

  - name: Spend Breakdown By
    title: "Spend breakdown by"
    type: field_filter
    default_value: "budgetGroup"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.dimension_selector_1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Search Metric
    title: "Search metric"
    type: field_filter
    default_value: "totalClicks"
    allow_multiple_values: false
    required: true
    model: afc_search
    explore: american_family_care_search_looker_table
    listens_to_filters: []
    field: american_family_care_search_looker_table.metric_selector_1
    ui_config:
      type: dropdown_menu
      display: overflow

  # ===========================================================================
  # Elements
  # ===========================================================================
  elements:

  # ------------------------------------------------------------ TAB: Executive

  - name: nav_exec_logo
    type: text
    title_text: ""
    tab_name: Executive
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:100%;background:white;"><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSupnctT7R2nepOPV75YiJnMRQoW1shpvpmHDgc6iDXK5pw9iJhv-NuReI&s=10" style="height:110px;width:auto;display:block;" /></div>'
    row: 0
    col: 0
    width: 4
    height: 3

  - name: nav_exec_1
    type: button
    tab_name: Executive
    rich_content_json: '{"text": "Executive overview","description": "Executive overview","href": "","targetTabName": "Executive","newTab": false,"alignment": "left","size": "medium","style": "FILLED","color": "#E31837"}'
    row: 3
    col: 0
    width: 4
    height: 1

  - name: nav_exec_2
    type: button
    tab_name: Executive
    rich_content_json: '{"text": "Conversion","description": "Conversion","href": "","targetTabName": "Conversion","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 4
    col: 0
    width: 4
    height: 1

  - name: nav_exec_3
    type: button
    tab_name: Executive
    rich_content_json: '{"text": "Traffic","description": "Traffic","href": "","targetTabName": "Traffic","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 5
    col: 0
    width: 4
    height: 1

  - name: nav_exec_4
    type: button
    tab_name: Executive
    rich_content_json: '{"text": "Competition","description": "Competition","href": "","targetTabName": "Competition","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 6
    col: 0
    width: 4
    height: 1

  - name: nav_exec_5
    type: button
    tab_name: Executive
    rich_content_json: '{"text": "Operations","description": "Operations","href": "","targetTabName": "Operations","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 7
    col: 0
    width: 4
    height: 1

  - name: nav_exec_6
    type: button
    tab_name: Executive
    rich_content_json: '{"text": "Data dictionary","description": "Data dictionary","href": "","targetTabName": "Dictionary","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 8
    col: 0
    width: 4
    height: 1

  - name: exec_band_core
    type: text
    title_text: ""
    tab_name: Executive
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:56px;border-radius:16px;background:linear-gradient(90deg,#A5111F 0%,#E31837 50%,#A5111F 100%);box-shadow:0 2px 8px rgba(165,17,31,.20);"><span style="font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:600;color:white;letter-spacing:0.8px;text-transform:uppercase;">Core KPI</span></div>'
    row: 0
    col: 4
    width: 20
    height: 2

  - name: exec_kpi_total_cost
    title: "Spend"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.total_cost_cur, american_family_care_search_looker_table.total_cost_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 4
    width: 4
    height: 3

  - name: exec_kpi_total_clicks
    title: "Clicks"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.total_clicks_cur, american_family_care_search_looker_table.total_clicks_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 8
    width: 4
    height: 3

  - name: exec_kpi_ctr
    title: "CTR"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.ctr_cur, american_family_care_search_looker_table.ctr_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 12
    width: 4
    height: 3

  - name: exec_kpi_cpc
    title: "CPC"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cpc_cur, american_family_care_search_looker_table.cpc_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 16
    width: 4
    height: 3

  - name: exec_kpi_total_impressions
    title: "Impressions"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.total_impressions_cur, american_family_care_search_looker_table.total_impressions_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 20
    width: 4
    height: 3

  - name: exec_kpi_engine_conversions
    title: "Conversions"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.engine_conversions_cur, american_family_care_search_looker_table.engine_conversions_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 5
    col: 4
    width: 4
    height: 3

  - name: exec_kpi_cvr
    title: "CVR"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cvr_cur, american_family_care_search_looker_table.cvr_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 5
    col: 8
    width: 4
    height: 3

  - name: exec_kpi_cpa
    title: "CPA"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cpa_cur, american_family_care_search_looker_table.cpa_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 5
    col: 12
    width: 4
    height: 3

  - name: exec_kpi_total_revenue
    title: "Revenue"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.total_revenue_cur, american_family_care_search_looker_table.total_revenue_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 5
    col: 16
    width: 4
    height: 3

  - name: exec_kpi_roas
    title: "ROAS"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.roas_cur, american_family_care_search_looker_table.roas_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 5
    col: 20
    width: 4
    height: 3

  - name: exec_trend_spend_conversions
    title: "Spend vs conversions by day"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_column
    fields: [american_family_care_search_looker_table.date_date, american_family_care_search_looker_table.total_cost, american_family_care_search_looker_table.engine_conversions]
    sorts: [american_family_care_search_looker_table.date_date]
    limit: 500
    show_view_names: false
    series_types:
      american_family_care_search_looker_table.engine_conversions: line
    series_colors:
      american_family_care_search_looker_table.total_cost: "#E31837"
      american_family_care_search_looker_table.engine_conversions: "#1D1D1B"
    y_axes: [{label: '', orientation: left, series: [{axisId: american_family_care_search_looker_table.total_cost, id: american_family_care_search_looker_table.total_cost}], showLabels: true, showValues: true, type: linear},
      {label: '', orientation: right, series: [{axisId: american_family_care_search_looker_table.engine_conversions, id: american_family_care_search_looker_table.engine_conversions}], showLabels: true, showValues: true, type: linear}]
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_value_labels: false
    legend_position: center
    point_style: none
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
    row: 8
    col: 4
    width: 20
    height: 9

  - name: exec_band_types
    type: text
    title_text: ""
    tab_name: Executive
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:56px;border-radius:16px;background:linear-gradient(90deg,#A5111F 0%,#E31837 50%,#A5111F 100%);box-shadow:0 2px 8px rgba(165,17,31,.20);"><span style="font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:600;color:white;letter-spacing:0.8px;text-transform:uppercase;">Conversions by type</span></div>'
    row: 17
    col: 4
    width: 20
    height: 2

  - name: exec_kpi_appointments
    title: "Appointment clicks"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.appointments_cur, american_family_care_search_looker_table.appointments_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 19
    col: 4
    width: 4
    height: 3

  - name: exec_kpi_bookings
    title: "Bookings"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.bookings_cur, american_family_care_search_looker_table.bookings_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 19
    col: 8
    width: 4
    height: 3

  - name: exec_kpi_discharged_patients
    title: "Discharged patients"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.discharged_patients_cur, american_family_care_search_looker_table.discharged_patients_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 19
    col: 12
    width: 4
    height: 3

  - name: exec_kpi_calls
    title: "Calls"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.calls_cur, american_family_care_search_looker_table.calls_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 19
    col: 16
    width: 4
    height: 3

  - name: exec_kpi_clinic_leads
    title: "Clinic leads"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.clinic_leads_cur, american_family_care_search_looker_table.clinic_leads_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 19
    col: 20
    width: 4
    height: 3

  - name: exec_kpi_cost_per_appointment
    title: "Cost per appointment click"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cost_per_appointment_cur, american_family_care_search_looker_table.cost_per_appointment_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 22
    col: 4
    width: 4
    height: 3

  - name: exec_kpi_cost_per_booking
    title: "Cost per booking"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cost_per_booking_cur, american_family_care_search_looker_table.cost_per_booking_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 22
    col: 8
    width: 4
    height: 3

  - name: exec_kpi_cost_per_discharged_patient
    title: "Cost per discharged patient"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cost_per_discharged_patient_cur, american_family_care_search_looker_table.cost_per_discharged_patient_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 22
    col: 12
    width: 4
    height: 3

  - name: exec_kpi_cost_per_call
    title: "Cost per call"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cost_per_call_cur, american_family_care_search_looker_table.cost_per_call_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 22
    col: 16
    width: 4
    height: 3

  - name: exec_kpi_cost_per_lead
    title: "Cost per lead"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cost_per_lead_cur, american_family_care_search_looker_table.cost_per_lead_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 22
    col: 20
    width: 4
    height: 3

  - name: exec_band_coverage
    type: text
    title_text: ""
    tab_name: Executive
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:56px;border-radius:16px;background:linear-gradient(90deg,#A5111F 0%,#E31837 50%,#A5111F 100%);box-shadow:0 2px 8px rgba(165,17,31,.20);"><span style="font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:600;color:white;letter-spacing:0.8px;text-transform:uppercase;">Coverage</span></div>'
    row: 25
    col: 4
    width: 20
    height: 2

  - name: exec_kpi_impression_share
    title: "Search impression share"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.impression_share_cur, american_family_care_search_looker_table.impression_share_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 27
    col: 4
    width: 5
    height: 3

  - name: exec_kpi_lost_is_rank
    title: "Lost IS (rank)"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.lost_is_rank_cur, american_family_care_search_looker_table.lost_is_rank_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 27
    col: 9
    width: 5
    height: 3

  - name: exec_kpi_lost_is_budget
    title: "Lost IS (budget)"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.lost_is_budget_cur, american_family_care_search_looker_table.lost_is_budget_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 27
    col: 14
    width: 5
    height: 3

  - name: exec_kpi_click_share
    title: "Click share"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.click_share_cur, american_family_care_search_looker_table.click_share_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 27
    col: 19
    width: 5
    height: 3

  - name: exec_band_dod
    type: text
    title_text: ""
    tab_name: Executive
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:56px;border-radius:16px;background:linear-gradient(90deg,#A5111F 0%,#E31837 50%,#A5111F 100%);box-shadow:0 2px 8px rgba(165,17,31,.20);"><span style="font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:600;color:white;letter-spacing:0.8px;text-transform:uppercase;">Day over day</span></div>'
    row: 30
    col: 4
    width: 20
    height: 2

  - name: DoD Delta Format
    type: filter
    tab_name: Executive
    row: 32
    col: 4
    width: 6
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: exec_dod_note
    type: text
    title_text: ""
    tab_name: Executive
    body_text: '<div style="font-family:''Google Sans'',Roboto,Arial,sans-serif;font-size:12px;color:#5F6368;padding:6px 4px;">Each Δ column compares a day with the day before it. Compare period with (filter bar) sets the vs PP on every tab.</div>'
    row: 32
    col: 10
    width: 14
    height: 1

  - name: exec_dod_table
    title: "Daily performance"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_grid
    fields: [american_family_care_search_looker_table.day, american_family_care_search_looker_table.date_date, american_family_care_search_looker_table.total_cost, american_family_care_search_looker_table.total_cost_change, american_family_care_search_looker_table.total_impressions, american_family_care_search_looker_table.total_impressions_change, american_family_care_search_looker_table.total_clicks, american_family_care_search_looker_table.total_clicks_change, american_family_care_search_looker_table.ctr, american_family_care_search_looker_table.ctr_change, american_family_care_search_looker_table.cpc, american_family_care_search_looker_table.cpc_change, american_family_care_search_looker_table.engine_conversions, american_family_care_search_looker_table.engine_conversions_change, american_family_care_search_looker_table.cpa, american_family_care_search_looker_table.cpa_change, american_family_care_search_looker_table.cvr, american_family_care_search_looker_table.cvr_change]
    sorts: [american_family_care_search_looker_table.date_date]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    show_totals: true
    show_row_totals: false
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_font_size: 12
    rows_font_size: 12
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      DoD Delta Format: american_family_care_search_looker_table.delta_format
    row: 33
    col: 4
    width: 20
    height: 12

  - name: exec_band_wow
    type: text
    title_text: ""
    tab_name: Executive
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:56px;border-radius:16px;background:linear-gradient(90deg,#A5111F 0%,#E31837 50%,#A5111F 100%);box-shadow:0 2px 8px rgba(165,17,31,.20);"><span style="font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:600;color:white;letter-spacing:0.8px;text-transform:uppercase;">Week over week</span></div>'
    row: 45
    col: 4
    width: 20
    height: 2

  - name: WoW Delta Format
    type: filter
    tab_name: Executive
    row: 47
    col: 4
    width: 6
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: exec_wow_note
    type: text
    title_text: ""
    tab_name: Executive
    body_text: '<div style="font-family:''Google Sans'',Roboto,Arial,sans-serif;font-size:12px;color:#5F6368;padding:6px 4px;">Each Δ column compares a week with the week before it. Weeks run Monday to Sunday. Green is better, red is worse.</div>'
    row: 47
    col: 10
    width: 14
    height: 1

  - name: exec_wow_table
    title: "Weekly performance (last 13 weeks)"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_grid
    fields: [american_family_care_search_looker_table.week_label, american_family_care_search_looker_table.days_with_data, american_family_care_search_looker_table.total_cost, american_family_care_search_looker_table.total_cost_change, american_family_care_search_looker_table.total_impressions, american_family_care_search_looker_table.total_impressions_change, american_family_care_search_looker_table.total_clicks, american_family_care_search_looker_table.total_clicks_change, american_family_care_search_looker_table.ctr, american_family_care_search_looker_table.ctr_change, american_family_care_search_looker_table.cpc, american_family_care_search_looker_table.cpc_change, american_family_care_search_looker_table.engine_conversions, american_family_care_search_looker_table.engine_conversions_change, american_family_care_search_looker_table.cpa, american_family_care_search_looker_table.cpa_change, american_family_care_search_looker_table.cvr, american_family_care_search_looker_table.cvr_change]
    filters:
      american_family_care_search_looker_table.date_date: "12 weeks ago for 13 weeks"
    sorts: [american_family_care_search_looker_table.week_label]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    show_totals: true
    show_row_totals: false
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_font_size: 12
    rows_font_size: 12
    listen:
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      WoW Delta Format: american_family_care_search_looker_table.delta_format
    row: 48
    col: 4
    width: 20
    height: 9

  - name: exec_band_mom
    type: text
    title_text: ""
    tab_name: Executive
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:56px;border-radius:16px;background:linear-gradient(90deg,#A5111F 0%,#E31837 50%,#A5111F 100%);box-shadow:0 2px 8px rgba(165,17,31,.20);"><span style="font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:600;color:white;letter-spacing:0.8px;text-transform:uppercase;">Month over month</span></div>'
    row: 57
    col: 4
    width: 20
    height: 2

  - name: MoM Delta Format
    type: filter
    tab_name: Executive
    row: 59
    col: 4
    width: 6
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: exec_mom_note
    type: text
    title_text: ""
    tab_name: Executive
    body_text: '<div style="font-family:''Google Sans'',Roboto,Arial,sans-serif;font-size:12px;color:#5F6368;padding:6px 4px;">Each Δ column compares a month with the month before it. Green is better, red is worse.</div>'
    row: 59
    col: 10
    width: 14
    height: 1

  - name: exec_mom_table
    title: "Monthly performance (this year)"
    tab_name: Executive
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_grid
    fields: [american_family_care_search_looker_table.date_month, american_family_care_search_looker_table.days_with_data, american_family_care_search_looker_table.total_cost, american_family_care_search_looker_table.total_cost_change, american_family_care_search_looker_table.total_impressions, american_family_care_search_looker_table.total_impressions_change, american_family_care_search_looker_table.total_clicks, american_family_care_search_looker_table.total_clicks_change, american_family_care_search_looker_table.ctr, american_family_care_search_looker_table.ctr_change, american_family_care_search_looker_table.cpc, american_family_care_search_looker_table.cpc_change, american_family_care_search_looker_table.engine_conversions, american_family_care_search_looker_table.engine_conversions_change, american_family_care_search_looker_table.cpa, american_family_care_search_looker_table.cpa_change, american_family_care_search_looker_table.cvr, american_family_care_search_looker_table.cvr_change, american_family_care_search_looker_table.total_budget, american_family_care_search_looker_table.budget_spent_pct]
    filters:
      american_family_care_search_looker_table.date_date: "this year"
    sorts: [american_family_care_search_looker_table.date_month]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    show_totals: true
    show_row_totals: false
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_font_size: 12
    rows_font_size: 12
    listen:
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      MoM Delta Format: american_family_care_search_looker_table.delta_format
    row: 60
    col: 4
    width: 20
    height: 9

  # ----------------------------------------------------------- TAB: Conversion

  - name: nav_conv_logo
    type: text
    title_text: ""
    tab_name: Conversion
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:100%;background:white;"><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSupnctT7R2nepOPV75YiJnMRQoW1shpvpmHDgc6iDXK5pw9iJhv-NuReI&s=10" style="height:110px;width:auto;display:block;" /></div>'
    row: 0
    col: 0
    width: 4
    height: 3

  - name: nav_conv_1
    type: button
    tab_name: Conversion
    rich_content_json: '{"text": "Executive overview","description": "Executive overview","href": "","targetTabName": "Executive","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 3
    col: 0
    width: 4
    height: 1

  - name: nav_conv_2
    type: button
    tab_name: Conversion
    rich_content_json: '{"text": "Conversion","description": "Conversion","href": "","targetTabName": "Conversion","newTab": false,"alignment": "left","size": "medium","style": "FILLED","color": "#E31837"}'
    row: 4
    col: 0
    width: 4
    height: 1

  - name: nav_conv_3
    type: button
    tab_name: Conversion
    rich_content_json: '{"text": "Traffic","description": "Traffic","href": "","targetTabName": "Traffic","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 5
    col: 0
    width: 4
    height: 1

  - name: nav_conv_4
    type: button
    tab_name: Conversion
    rich_content_json: '{"text": "Competition","description": "Competition","href": "","targetTabName": "Competition","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 6
    col: 0
    width: 4
    height: 1

  - name: nav_conv_5
    type: button
    tab_name: Conversion
    rich_content_json: '{"text": "Operations","description": "Operations","href": "","targetTabName": "Operations","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 7
    col: 0
    width: 4
    height: 1

  - name: nav_conv_6
    type: button
    tab_name: Conversion
    rich_content_json: '{"text": "Data dictionary","description": "Data dictionary","href": "","targetTabName": "Dictionary","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 8
    col: 0
    width: 4
    height: 1

  - name: conv_band_pursued
    type: text
    title_text: ""
    tab_name: Conversion
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:56px;border-radius:16px;background:linear-gradient(90deg,#A5111F 0%,#E31837 50%,#A5111F 100%);box-shadow:0 2px 8px rgba(165,17,31,.20);"><span style="font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:600;color:white;letter-spacing:0.8px;text-transform:uppercase;">Pursued conversions</span></div>'
    row: 0
    col: 4
    width: 20
    height: 2

  - name: conv_kpi_total_cost
    title: "Spend"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.total_cost_cur, american_family_care_search_looker_table.total_cost_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 4
    width: 4
    height: 3

  - name: conv_kpi_engine_conversions
    title: "Conversions"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.engine_conversions_cur, american_family_care_search_looker_table.engine_conversions_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 8
    width: 4
    height: 3

  - name: conv_kpi_cvr
    title: "CVR"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cvr_cur, american_family_care_search_looker_table.cvr_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 12
    width: 4
    height: 3

  - name: conv_kpi_cpa
    title: "CPA"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cpa_cur, american_family_care_search_looker_table.cpa_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 16
    width: 4
    height: 3

  - name: conv_kpi_booking_to_visit_rate
    title: "Booking to visit rate"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.booking_to_visit_rate_cur, american_family_care_search_looker_table.booking_to_visit_rate_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 20
    width: 4
    height: 3

  - name: conv_band_types
    type: text
    title_text: ""
    tab_name: Conversion
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:56px;border-radius:16px;background:linear-gradient(90deg,#A5111F 0%,#E31837 50%,#A5111F 100%);box-shadow:0 2px 8px rgba(165,17,31,.20);"><span style="font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:600;color:white;letter-spacing:0.8px;text-transform:uppercase;">Conversions by type</span></div>'
    row: 5
    col: 4
    width: 20
    height: 2

  - name: conv_kpi_appointments
    title: "Appointment clicks"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.appointments_cur, american_family_care_search_looker_table.appointments_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 7
    col: 4
    width: 4
    height: 3

  - name: conv_kpi_bookings
    title: "Bookings"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.bookings_cur, american_family_care_search_looker_table.bookings_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 7
    col: 8
    width: 4
    height: 3

  - name: conv_kpi_discharged_patients
    title: "Discharged patients"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.discharged_patients_cur, american_family_care_search_looker_table.discharged_patients_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 7
    col: 12
    width: 4
    height: 3

  - name: conv_kpi_calls
    title: "Calls"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.calls_cur, american_family_care_search_looker_table.calls_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 7
    col: 16
    width: 4
    height: 3

  - name: conv_kpi_clinic_leads
    title: "Clinic leads"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.clinic_leads_cur, american_family_care_search_looker_table.clinic_leads_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 7
    col: 20
    width: 4
    height: 3

  - name: conv_kpi_cost_per_appointment
    title: "Cost per appointment click"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cost_per_appointment_cur, american_family_care_search_looker_table.cost_per_appointment_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 10
    col: 4
    width: 4
    height: 3

  - name: conv_kpi_cost_per_booking
    title: "Cost per booking"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cost_per_booking_cur, american_family_care_search_looker_table.cost_per_booking_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 10
    col: 8
    width: 4
    height: 3

  - name: conv_kpi_cost_per_discharged_patient
    title: "Cost per discharged patient"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cost_per_discharged_patient_cur, american_family_care_search_looker_table.cost_per_discharged_patient_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 10
    col: 12
    width: 4
    height: 3

  - name: conv_kpi_cost_per_call
    title: "Cost per call"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cost_per_call_cur, american_family_care_search_looker_table.cost_per_call_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 10
    col: 16
    width: 4
    height: 3

  - name: conv_kpi_cost_per_lead
    title: "Cost per lead"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cost_per_lead_cur, american_family_care_search_looker_table.cost_per_lead_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 10
    col: 20
    width: 4
    height: 3

  - name: Conv Granularity
    type: filter
    tab_name: Conversion
    row: 13
    col: 4
    width: 6
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Bars
    type: filter
    tab_name: Conversion
    row: 13
    col: 10
    width: 7
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Line
    type: filter
    tab_name: Conversion
    row: 13
    col: 17
    width: 7
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: conv_trend
    title: "Performance over time"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_column
    fields: [american_family_care_search_looker_table.dynamic_date, american_family_care_search_looker_table.selected_metric_1, american_family_care_search_looker_table.selected_metric_2]
    sorts: [american_family_care_search_looker_table.dynamic_date]
    limit: 500
    show_view_names: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_x_axis_ticks: true
    show_value_labels: false
    legend_position: center
    point_style: none
    interpolation: linear
    series_types:
      american_family_care_search_looker_table.selected_metric_2: line
    series_colors:
      american_family_care_search_looker_table.selected_metric_1: "#1D1D1B"
      american_family_care_search_looker_table.selected_metric_2: "#E31837"
    y_axes: [{label: '', orientation: left, series: [{axisId: american_family_care_search_looker_table.selected_metric_1, id: american_family_care_search_looker_table.selected_metric_1}], showLabels: true, showValues: true, type: linear},
      {label: '', orientation: right, series: [{axisId: american_family_care_search_looker_table.selected_metric_2, id: american_family_care_search_looker_table.selected_metric_2}], showLabels: true, showValues: true, type: linear}]
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Conv Granularity: american_family_care_search_looker_table.date_granularity
      Conv Bars: american_family_care_search_looker_table.metric_selector_1
      Conv Line: american_family_care_search_looker_table.metric_selector_2
    row: 14
    col: 4
    width: 20
    height: 8

  - name: Conv Stack Metric
    type: filter
    tab_name: Conversion
    row: 22
    col: 4
    width: 6
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Stack Rows
    type: filter
    tab_name: Conversion
    row: 22
    col: 10
    width: 7
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Stack Color
    type: filter
    tab_name: Conversion
    row: 22
    col: 17
    width: 7
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: conv_breakdown_stack
    title: "Breakdown comparison"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_bar
    fields: [american_family_care_search_looker_table.selected_dimension_1, american_family_care_search_looker_table.selected_dimension_2, american_family_care_search_looker_table.selected_metric_1]
    pivots: [american_family_care_search_looker_table.selected_dimension_2]
    sorts: [american_family_care_search_looker_table.selected_metric_1 desc 0]
    limit: 25
    show_view_names: false
    column_limit: 12
    stacking: normal
    show_value_labels: false
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Conv Stack Metric: american_family_care_search_looker_table.metric_selector_1
      Conv Stack Rows: american_family_care_search_looker_table.dimension_selector_1
      Conv Stack Color: american_family_care_search_looker_table.dimension_selector_2
    row: 23
    col: 4
    width: 20
    height: 8

  - name: Conv Breakdown Rows
    type: filter
    tab_name: Conversion
    row: 31
    col: 4
    width: 5
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Breakdown Metric
    type: filter
    tab_name: Conversion
    row: 31
    col: 9
    width: 5
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Over Time By
    type: filter
    tab_name: Conversion
    row: 31
    col: 14
    width: 5
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Conv Over Time Metric
    type: filter
    tab_name: Conversion
    row: 31
    col: 19
    width: 5
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: conv_breakdown_vs
    title: "Breakdown vs comparison period"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_bar
    fields: [american_family_care_search_looker_table.selected_dimension_1, american_family_care_search_looker_table.selected_metric_1_cur, american_family_care_search_looker_table.selected_metric_1_prior]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    sorts: [american_family_care_search_looker_table.selected_metric_1_cur desc]
    limit: 12
    show_view_names: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_value_labels: false
    legend_position: center
    series_colors:
      american_family_care_search_looker_table.selected_metric_1_cur: "#1D1D1B"
      american_family_care_search_looker_table.selected_metric_1_prior: "#8C8C8C"
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Conv Breakdown Rows: american_family_care_search_looker_table.dimension_selector_1
      Conv Breakdown Metric: american_family_care_search_looker_table.metric_selector_1
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 32
    col: 4
    width: 10
    height: 9

  - name: conv_over_time
    title: "Breakdown over time"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_column
    fields: [american_family_care_search_looker_table.dynamic_date, american_family_care_search_looker_table.selected_dimension_2, american_family_care_search_looker_table.selected_metric_2]
    pivots: [american_family_care_search_looker_table.selected_dimension_2]
    sorts: [american_family_care_search_looker_table.dynamic_date]
    limit: 500
    show_view_names: false
    stacking: normal
    column_limit: 8
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_value_labels: false
    legend_position: center
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Conv Granularity: american_family_care_search_looker_table.date_granularity
      Conv Over Time By: american_family_care_search_looker_table.dimension_selector_2
      Conv Over Time Metric: american_family_care_search_looker_table.metric_selector_2
    row: 32
    col: 14
    width: 10
    height: 9

  - name: Conv Table By
    type: filter
    tab_name: Conversion
    row: 41
    col: 4
    width: 8
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: conv_by_type
    title: "Conversions by type"
    tab_name: Conversion
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_grid
    fields: [american_family_care_search_looker_table.selected_dimension_1, american_family_care_search_looker_table.total_cost, american_family_care_search_looker_table.appointments, american_family_care_search_looker_table.cost_per_appointment, american_family_care_search_looker_table.bookings, american_family_care_search_looker_table.cost_per_booking, american_family_care_search_looker_table.discharged_patients, american_family_care_search_looker_table.cost_per_discharged_patient, american_family_care_search_looker_table.calls, american_family_care_search_looker_table.cost_per_call, american_family_care_search_looker_table.clinic_leads, american_family_care_search_looker_table.cost_per_lead, american_family_care_search_looker_table.engine_conversions, american_family_care_search_looker_table.cpa, american_family_care_search_looker_table.cvr]
    sorts: [american_family_care_search_looker_table.total_cost desc]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    show_totals: true
    show_row_totals: false
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_font_size: 12
    rows_font_size: 12
    series_cell_visualizations:
      american_family_care_search_looker_table.total_cost:
        is_active: true
      american_family_care_search_looker_table.engine_conversions:
        is_active: true
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Conv Table By: american_family_care_search_looker_table.dimension_selector_1
    row: 42
    col: 4
    width: 20
    height: 9

  # -------------------------------------------------------------- TAB: Traffic

  - name: nav_traf_logo
    type: text
    title_text: ""
    tab_name: Traffic
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:100%;background:white;"><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSupnctT7R2nepOPV75YiJnMRQoW1shpvpmHDgc6iDXK5pw9iJhv-NuReI&s=10" style="height:110px;width:auto;display:block;" /></div>'
    row: 0
    col: 0
    width: 4
    height: 3

  - name: nav_traf_1
    type: button
    tab_name: Traffic
    rich_content_json: '{"text": "Executive overview","description": "Executive overview","href": "","targetTabName": "Executive","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 3
    col: 0
    width: 4
    height: 1

  - name: nav_traf_2
    type: button
    tab_name: Traffic
    rich_content_json: '{"text": "Conversion","description": "Conversion","href": "","targetTabName": "Conversion","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 4
    col: 0
    width: 4
    height: 1

  - name: nav_traf_3
    type: button
    tab_name: Traffic
    rich_content_json: '{"text": "Traffic","description": "Traffic","href": "","targetTabName": "Traffic","newTab": false,"alignment": "left","size": "medium","style": "FILLED","color": "#E31837"}'
    row: 5
    col: 0
    width: 4
    height: 1

  - name: nav_traf_4
    type: button
    tab_name: Traffic
    rich_content_json: '{"text": "Competition","description": "Competition","href": "","targetTabName": "Competition","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 6
    col: 0
    width: 4
    height: 1

  - name: nav_traf_5
    type: button
    tab_name: Traffic
    rich_content_json: '{"text": "Operations","description": "Operations","href": "","targetTabName": "Operations","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 7
    col: 0
    width: 4
    height: 1

  - name: nav_traf_6
    type: button
    tab_name: Traffic
    rich_content_json: '{"text": "Data dictionary","description": "Data dictionary","href": "","targetTabName": "Dictionary","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 8
    col: 0
    width: 4
    height: 1

  - name: traf_band
    type: text
    title_text: ""
    tab_name: Traffic
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:56px;border-radius:16px;background:linear-gradient(90deg,#A5111F 0%,#E31837 50%,#A5111F 100%);box-shadow:0 2px 8px rgba(165,17,31,.20);"><span style="font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:600;color:white;letter-spacing:0.8px;text-transform:uppercase;">Traffic</span></div>'
    row: 0
    col: 4
    width: 20
    height: 2

  - name: traf_kpi_total_impressions
    title: "Impressions"
    tab_name: Traffic
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.total_impressions_cur, american_family_care_search_looker_table.total_impressions_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 4
    width: 4
    height: 3

  - name: traf_kpi_total_clicks
    title: "Clicks"
    tab_name: Traffic
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.total_clicks_cur, american_family_care_search_looker_table.total_clicks_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 8
    width: 4
    height: 3

  - name: traf_kpi_ctr
    title: "CTR"
    tab_name: Traffic
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.ctr_cur, american_family_care_search_looker_table.ctr_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 12
    width: 4
    height: 3

  - name: traf_kpi_cpc
    title: "CPC"
    tab_name: Traffic
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.cpc_cur, american_family_care_search_looker_table.cpc_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 16
    width: 4
    height: 3

  - name: traf_kpi_total_cost
    title: "Spend"
    tab_name: Traffic
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.total_cost_cur, american_family_care_search_looker_table.total_cost_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 20
    width: 4
    height: 3

  - name: Traffic Granularity
    type: filter
    tab_name: Traffic
    row: 5
    col: 4
    width: 6
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Traffic Bars
    type: filter
    tab_name: Traffic
    row: 5
    col: 10
    width: 7
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Traffic Line
    type: filter
    tab_name: Traffic
    row: 5
    col: 17
    width: 7
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: traf_trend
    title: "Traffic over time"
    tab_name: Traffic
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_column
    fields: [american_family_care_search_looker_table.dynamic_date, american_family_care_search_looker_table.selected_metric_1, american_family_care_search_looker_table.selected_metric_2]
    sorts: [american_family_care_search_looker_table.dynamic_date]
    limit: 500
    show_view_names: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_x_axis_ticks: true
    show_value_labels: false
    legend_position: center
    point_style: none
    interpolation: linear
    series_types:
      american_family_care_search_looker_table.selected_metric_2: line
    series_colors:
      american_family_care_search_looker_table.selected_metric_1: "#1D1D1B"
      american_family_care_search_looker_table.selected_metric_2: "#E31837"
    y_axes: [{label: '', orientation: left, series: [{axisId: american_family_care_search_looker_table.selected_metric_1, id: american_family_care_search_looker_table.selected_metric_1}], showLabels: true, showValues: true, type: linear},
      {label: '', orientation: right, series: [{axisId: american_family_care_search_looker_table.selected_metric_2, id: american_family_care_search_looker_table.selected_metric_2}], showLabels: true, showValues: true, type: linear}]
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Traffic Granularity: american_family_care_search_looker_table.date_granularity
      Traffic Bars: american_family_care_search_looker_table.metric_selector_1
      Traffic Line: american_family_care_search_looker_table.metric_selector_2
    row: 6
    col: 4
    width: 20
    height: 8

  - name: Traffic Breakdown Rows
    type: filter
    tab_name: Traffic
    row: 14
    col: 4
    width: 5
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Traffic Breakdown Metric
    type: filter
    tab_name: Traffic
    row: 14
    col: 9
    width: 5
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Top Campaigns By
    type: filter
    tab_name: Traffic
    row: 14
    col: 14
    width: 10
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: traf_breakdown
    title: "Traffic breakdown"
    tab_name: Traffic
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_column
    fields: [american_family_care_search_looker_table.selected_dimension_1, american_family_care_search_looker_table.selected_metric_1, american_family_care_search_looker_table.ctr]
    sorts: [american_family_care_search_looker_table.selected_metric_1 desc]
    limit: 12
    show_view_names: false
    series_types:
      american_family_care_search_looker_table.ctr: scatter
    series_colors:
      american_family_care_search_looker_table.selected_metric_1: "#1D1D1B"
      american_family_care_search_looker_table.ctr: "#E31837"
    y_axes: [{label: '', orientation: left, series: [{axisId: american_family_care_search_looker_table.selected_metric_1, id: american_family_care_search_looker_table.selected_metric_1}], showLabels: true, showValues: true, type: linear},
      {label: '', orientation: right, series: [{axisId: american_family_care_search_looker_table.ctr, id: american_family_care_search_looker_table.ctr}], showLabels: true, showValues: true, type: linear}]
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_value_labels: false
    legend_position: center
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Traffic Breakdown Rows: american_family_care_search_looker_table.dimension_selector_1
      Traffic Breakdown Metric: american_family_care_search_looker_table.metric_selector_1
    row: 15
    col: 4
    width: 10
    height: 9

  - name: traf_top_campaigns
    title: "Top 15 campaigns"
    tab_name: Traffic
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_bar
    fields: [american_family_care_search_looker_table.campaign, american_family_care_search_looker_table.selected_metric_2]
    sorts: [american_family_care_search_looker_table.selected_metric_2 desc]
    limit: 15
    show_view_names: false
    show_value_labels: true
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    series_colors:
      american_family_care_search_looker_table.selected_metric_2: "#1D1D1B"
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Top Campaigns By: american_family_care_search_looker_table.metric_selector_2
    row: 15
    col: 14
    width: 10
    height: 9

  # ---------------------------------------------------------- TAB: Competition

  - name: nav_comp_logo
    type: text
    title_text: ""
    tab_name: Competition
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:100%;background:white;"><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSupnctT7R2nepOPV75YiJnMRQoW1shpvpmHDgc6iDXK5pw9iJhv-NuReI&s=10" style="height:110px;width:auto;display:block;" /></div>'
    row: 0
    col: 0
    width: 4
    height: 3

  - name: nav_comp_1
    type: button
    tab_name: Competition
    rich_content_json: '{"text": "Executive overview","description": "Executive overview","href": "","targetTabName": "Executive","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 3
    col: 0
    width: 4
    height: 1

  - name: nav_comp_2
    type: button
    tab_name: Competition
    rich_content_json: '{"text": "Conversion","description": "Conversion","href": "","targetTabName": "Conversion","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 4
    col: 0
    width: 4
    height: 1

  - name: nav_comp_3
    type: button
    tab_name: Competition
    rich_content_json: '{"text": "Traffic","description": "Traffic","href": "","targetTabName": "Traffic","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 5
    col: 0
    width: 4
    height: 1

  - name: nav_comp_4
    type: button
    tab_name: Competition
    rich_content_json: '{"text": "Competition","description": "Competition","href": "","targetTabName": "Competition","newTab": false,"alignment": "left","size": "medium","style": "FILLED","color": "#E31837"}'
    row: 6
    col: 0
    width: 4
    height: 1

  - name: nav_comp_5
    type: button
    tab_name: Competition
    rich_content_json: '{"text": "Operations","description": "Operations","href": "","targetTabName": "Operations","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 7
    col: 0
    width: 4
    height: 1

  - name: nav_comp_6
    type: button
    tab_name: Competition
    rich_content_json: '{"text": "Data dictionary","description": "Data dictionary","href": "","targetTabName": "Dictionary","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 8
    col: 0
    width: 4
    height: 1

  - name: comp_band
    type: text
    title_text: ""
    tab_name: Competition
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:56px;border-radius:16px;background:linear-gradient(90deg,#A5111F 0%,#E31837 50%,#A5111F 100%);box-shadow:0 2px 8px rgba(165,17,31,.20);"><span style="font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:600;color:white;letter-spacing:0.8px;text-transform:uppercase;">Coverage</span></div>'
    row: 0
    col: 4
    width: 20
    height: 2

  - name: comp_kpi_impression_share
    title: "Search impression share"
    tab_name: Competition
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.impression_share_cur, american_family_care_search_looker_table.impression_share_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 4
    width: 4
    height: 3

  - name: comp_kpi_lost_is_rank
    title: "Lost IS (rank)"
    tab_name: Competition
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.lost_is_rank_cur, american_family_care_search_looker_table.lost_is_rank_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 8
    width: 4
    height: 3

  - name: comp_kpi_lost_is_budget
    title: "Lost IS (budget)"
    tab_name: Competition
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.lost_is_budget_cur, american_family_care_search_looker_table.lost_is_budget_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 12
    width: 4
    height: 3

  - name: comp_kpi_click_share
    title: "Click share"
    tab_name: Competition
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.click_share_cur, american_family_care_search_looker_table.click_share_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 16
    width: 4
    height: 3

  - name: comp_kpi_eligible_impressions
    title: "Eligible impressions"
    tab_name: Competition
    model: afc_search
    explore: american_family_care_search_looker_table
    type: single_value
    fields: [american_family_care_search_looker_table.eligible_impressions_cur, american_family_care_search_looker_table.eligible_impressions_pop]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    limit: 1
    show_view_names: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "vs PP"
    enable_conditional_formatting: false
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 2
    col: 20
    width: 4
    height: 3

  - name: Comp Granularity
    type: filter
    tab_name: Competition
    row: 5
    col: 4
    width: 6
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: comp_is_trend
    title: "Impression share over time"
    tab_name: Competition
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_area
    fields: [american_family_care_search_looker_table.dynamic_date, american_family_care_search_looker_table.impression_share, american_family_care_search_looker_table.lost_is_rank, american_family_care_search_looker_table.lost_is_budget]
    sorts: [american_family_care_search_looker_table.dynamic_date]
    limit: 500
    show_view_names: false
    stacking: normal
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_value_labels: false
    legend_position: center
    point_style: none
    interpolation: linear
    series_colors:
      american_family_care_search_looker_table.impression_share: "#1D1D1B"
      american_family_care_search_looker_table.lost_is_rank: "#8C8C8C"
      american_family_care_search_looker_table.lost_is_budget: "#F28B96"
    y_axes: [{label: '', orientation: left, showLabels: true, showValues: true, minValue: 0, maxValue: 1, type: linear, valueFormat: '0%'}]
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Comp Granularity: american_family_care_search_looker_table.date_granularity
    row: 6
    col: 4
    width: 20
    height: 8

  - name: comp_by_account
    title: "Competition by account"
    tab_name: Competition
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_grid
    fields: [american_family_care_search_looker_table.account, american_family_care_search_looker_table.account_id, american_family_care_search_looker_table.eligible_impressions_cur, american_family_care_search_looker_table.impression_share_cur, american_family_care_search_looker_table.impression_share_delta, american_family_care_search_looker_table.lost_is_rank_cur, american_family_care_search_looker_table.lost_is_rank_delta, american_family_care_search_looker_table.lost_is_budget_cur, american_family_care_search_looker_table.lost_is_budget_delta, american_family_care_search_looker_table.click_share_cur, american_family_care_search_looker_table.click_share_delta]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    sorts: [american_family_care_search_looker_table.eligible_impressions_cur desc]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    show_totals: true
    show_row_totals: false
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_font_size: 12
    rows_font_size: 12
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 14
    col: 4
    width: 20
    height: 5

  - name: nav_ops_logo
    type: text
    title_text: ""
    tab_name: Operations
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:100%;background:white;"><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSupnctT7R2nepOPV75YiJnMRQoW1shpvpmHDgc6iDXK5pw9iJhv-NuReI&s=10" style="height:110px;width:auto;display:block;" /></div>'
    row: 0
    col: 0
    width: 4
    height: 3

  - name: nav_ops_1
    type: button
    tab_name: Operations
    rich_content_json: '{"text": "Executive overview","description": "Executive overview","href": "","targetTabName": "Executive","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 3
    col: 0
    width: 4
    height: 1

  - name: nav_ops_2
    type: button
    tab_name: Operations
    rich_content_json: '{"text": "Conversion","description": "Conversion","href": "","targetTabName": "Conversion","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 4
    col: 0
    width: 4
    height: 1

  - name: nav_ops_3
    type: button
    tab_name: Operations
    rich_content_json: '{"text": "Traffic","description": "Traffic","href": "","targetTabName": "Traffic","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 5
    col: 0
    width: 4
    height: 1

  - name: nav_ops_4
    type: button
    tab_name: Operations
    rich_content_json: '{"text": "Competition","description": "Competition","href": "","targetTabName": "Competition","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 6
    col: 0
    width: 4
    height: 1

  - name: nav_ops_5
    type: button
    tab_name: Operations
    rich_content_json: '{"text": "Operations","description": "Operations","href": "","targetTabName": "Operations","newTab": false,"alignment": "left","size": "medium","style": "FILLED","color": "#E31837"}'
    row: 7
    col: 0
    width: 4
    height: 1

  - name: nav_ops_6
    type: button
    tab_name: Operations
    rich_content_json: '{"text": "Data dictionary","description": "Data dictionary","href": "","targetTabName": "Dictionary","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 8
    col: 0
    width: 4
    height: 1

  - name: ops_band_pacing
    type: text
    title_text: ""
    tab_name: Operations
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:56px;border-radius:16px;background:linear-gradient(90deg,#A5111F 0%,#E31837 50%,#A5111F 100%);box-shadow:0 2px 8px rgba(165,17,31,.20);"><span style="font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:600;color:white;letter-spacing:0.8px;text-transform:uppercase;">Budget pacing</span></div>'
    row: 0
    col: 4
    width: 20
    height: 2

  - name: Budget Month
    type: filter
    tab_name: Operations
    row: 2
    col: 4
    width: 8
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: ops_pacing
    title: "Pacing by region"
    tab_name: Operations
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_grid
    fields: [american_family_care_search_looker_table.region_name, american_family_care_search_looker_table.total_budget, american_family_care_search_looker_table.total_cost, american_family_care_search_looker_table.budget_spent_pct, american_family_care_search_looker_table.pacing_days_elapsed, american_family_care_search_looker_table.pacing_days_in_month, american_family_care_search_looker_table.pacing_month_elapsed_pct, american_family_care_search_looker_table.pacing_projected_spend, american_family_care_search_looker_table.pacing_projected_vs_budget, american_family_care_search_looker_table.pacing_daily_spend_needed, american_family_care_search_looker_table.pacing_status]
    filters:
      american_family_care_search_looker_table.is_mapped: "Yes"
    sorts: [american_family_care_search_looker_table.region_name]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    show_totals: true
    show_row_totals: false
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_font_size: 12
    rows_font_size: 12
    series_cell_visualizations:
      american_family_care_search_looker_table.budget_spent_pct:
        is_active: true
    listen:
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Budget Month: american_family_care_search_looker_table.date_month
    row: 3
    col: 4
    width: 20
    height: 4

  - name: ops_cumulative
    title: "Cumulative spend vs budget"
    tab_name: Operations
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_line
    fields: [american_family_care_search_looker_table.date_date, american_family_care_search_looker_table.total_cost, american_family_care_search_looker_table.total_budget, american_family_care_search_looker_table.pacing_days_in_month]
    filters:
      american_family_care_search_looker_table.is_mapped: "Yes"
    sorts: [american_family_care_search_looker_table.date_date]
    limit: 500
    show_view_names: false
    dynamic_fields:
    - table_calculation: cumulative_spend
      label: Cumulative spend
      expression: "running_total(${american_family_care_search_looker_table.total_cost})"
      value_format_name: usd_0
      _kind_hint: measure
      _type_hint: number
    - table_calculation: even_pace
      label: Even pace to budget
      expression: "sum(${american_family_care_search_looker_table.total_budget}) * row() / max(${american_family_care_search_looker_table.pacing_days_in_month})"
      value_format_name: usd_0
      _kind_hint: measure
      _type_hint: number
    hidden_fields: [american_family_care_search_looker_table.total_cost, american_family_care_search_looker_table.total_budget, american_family_care_search_looker_table.pacing_days_in_month]
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_value_labels: false
    legend_position: center
    point_style: none
    interpolation: linear
    series_colors:
      cumulative_spend: "#1D1D1B"
      even_pace: "#E31837"
    listen:
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Budget Month: american_family_care_search_looker_table.date_month
    row: 7
    col: 4
    width: 10
    height: 8

  - name: ops_budget_months
    title: "Monthly budget vs spend"
    tab_name: Operations
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_column
    fields: [american_family_care_search_looker_table.date_month, american_family_care_search_looker_table.total_budget, american_family_care_search_looker_table.total_cost]
    filters:
      american_family_care_search_looker_table.date_date: "this year"
      american_family_care_search_looker_table.is_mapped: "Yes"
    sorts: [american_family_care_search_looker_table.date_month]
    limit: 500
    show_view_names: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_value_labels: false
    legend_position: center
    series_colors:
      american_family_care_search_looker_table.total_budget: "#D9D9D9"
      american_family_care_search_looker_table.total_cost: "#1D1D1B"
    listen:
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
    row: 7
    col: 14
    width: 10
    height: 8

  - name: ops_band_cost
    type: text
    title_text: ""
    tab_name: Operations
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:56px;border-radius:16px;background:linear-gradient(90deg,#A5111F 0%,#E31837 50%,#A5111F 100%);box-shadow:0 2px 8px rgba(165,17,31,.20);"><span style="font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:600;color:white;letter-spacing:0.8px;text-transform:uppercase;">Cost breakdown</span></div>'
    row: 15
    col: 4
    width: 20
    height: 2

  - name: Spend Breakdown By
    type: filter
    tab_name: Operations
    row: 17
    col: 4
    width: 8
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: ops_spend_share
    title: "Spend share"
    tab_name: Operations
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_bar
    fields: [american_family_care_search_looker_table.selected_dimension_1, american_family_care_search_looker_table.total_cost]
    sorts: [american_family_care_search_looker_table.total_cost desc]
    limit: 14
    show_view_names: false
    show_value_labels: true
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    series_colors:
      american_family_care_search_looker_table.total_cost: "#1D1D1B"
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Spend Breakdown By: american_family_care_search_looker_table.dimension_selector_1
    row: 18
    col: 4
    width: 10
    height: 9

  - name: ops_spend_months
    title: "Spend by month"
    tab_name: Operations
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_column
    fields: [american_family_care_search_looker_table.date_month, american_family_care_search_looker_table.selected_dimension_1, american_family_care_search_looker_table.total_cost]
    pivots: [american_family_care_search_looker_table.selected_dimension_1]
    filters:
      american_family_care_search_looker_table.date_date: "this year"
    sorts: [american_family_care_search_looker_table.date_month]
    limit: 500
    show_view_names: false
    stacking: normal
    column_limit: 8
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_value_labels: false
    legend_position: center
    listen:
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Spend Breakdown By: american_family_care_search_looker_table.dimension_selector_1
    row: 18
    col: 14
    width: 10
    height: 9

  - name: ops_band_market
    type: text
    title_text: ""
    tab_name: Operations
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:56px;border-radius:16px;background:linear-gradient(90deg,#A5111F 0%,#E31837 50%,#A5111F 100%);box-shadow:0 2px 8px rgba(165,17,31,.20);"><span style="font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:600;color:white;letter-spacing:0.8px;text-transform:uppercase;">Market view (inferred from campaign names)</span></div>'
    row: 27
    col: 4
    width: 20
    height: 2

  - name: ops_market
    title: "Market view"
    tab_name: Operations
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_grid
    fields: [american_family_care_search_looker_table.market, american_family_care_search_looker_table.region, american_family_care_search_looker_table.total_cost_cur, american_family_care_search_looker_table.total_clicks_cur, american_family_care_search_looker_table.ctr_cur, american_family_care_search_looker_table.engine_conversions_cur, american_family_care_search_looker_table.cpa_cur, american_family_care_search_looker_table.cpa_delta, american_family_care_search_looker_table.impression_share_cur]
    filters:
      american_family_care_search_looker_table.in_cmp_scope: "Yes"
    sorts: [american_family_care_search_looker_table.total_cost_cur desc]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    show_totals: true
    show_row_totals: false
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_font_size: 12
    rows_font_size: 12
    series_cell_visualizations:
      american_family_care_search_looker_table.total_cost_cur:
        is_active: true
    listen:
      Date Range: american_family_care_search_looker_table.date_range
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      KPI Comparison: american_family_care_search_looker_table.comparison_mode
    row: 29
    col: 4
    width: 20
    height: 7

  - name: ops_band_search
    type: text
    title_text: ""
    tab_name: Operations
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:56px;border-radius:16px;background:linear-gradient(90deg,#A5111F 0%,#E31837 50%,#A5111F 100%);box-shadow:0 2px 8px rgba(165,17,31,.20);"><span style="font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:600;color:white;letter-spacing:0.8px;text-transform:uppercase;">Search metrics vs cost</span></div>'
    row: 36
    col: 4
    width: 20
    height: 2

  - name: Ops Granularity
    type: filter
    tab_name: Operations
    row: 38
    col: 4
    width: 6
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: Search Metric
    type: filter
    tab_name: Operations
    row: 38
    col: 10
    width: 8
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: ops_metric_vs_cost
    title: "Search metric trend vs spend"
    tab_name: Operations
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_column
    fields: [american_family_care_search_looker_table.dynamic_date, american_family_care_search_looker_table.total_cost, american_family_care_search_looker_table.selected_metric_1]
    sorts: [american_family_care_search_looker_table.dynamic_date]
    limit: 500
    show_view_names: false
    series_types:
      american_family_care_search_looker_table.selected_metric_1: line
    series_colors:
      american_family_care_search_looker_table.total_cost: "#E31837"
      american_family_care_search_looker_table.selected_metric_1: "#1D1D1B"
    y_axes: [{label: '', orientation: left, series: [{axisId: american_family_care_search_looker_table.total_cost, id: american_family_care_search_looker_table.total_cost}], showLabels: true, showValues: true, type: linear},
      {label: '', orientation: right, series: [{axisId: american_family_care_search_looker_table.selected_metric_1, id: american_family_care_search_looker_table.selected_metric_1}], showLabels: true, showValues: true, type: linear}]
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_value_labels: false
    legend_position: center
    point_style: none
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Ops Granularity: american_family_care_search_looker_table.date_granularity
      Search Metric: american_family_care_search_looker_table.metric_selector_1
    row: 39
    col: 4
    width: 10
    height: 8

  - name: ops_conv_vs_cost
    title: "Conversions vs spend"
    tab_name: Operations
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_column
    fields: [american_family_care_search_looker_table.dynamic_date, american_family_care_search_looker_table.total_cost, american_family_care_search_looker_table.engine_conversions]
    sorts: [american_family_care_search_looker_table.dynamic_date]
    limit: 500
    show_view_names: false
    series_types:
      american_family_care_search_looker_table.engine_conversions: line
    series_colors:
      american_family_care_search_looker_table.total_cost: "#8C8C8C"
      american_family_care_search_looker_table.engine_conversions: "#1D1D1B"
    y_axes: [{label: '', orientation: left, series: [{axisId: american_family_care_search_looker_table.total_cost, id: american_family_care_search_looker_table.total_cost}], showLabels: true, showValues: true, type: linear},
      {label: '', orientation: right, series: [{axisId: american_family_care_search_looker_table.engine_conversions, id: american_family_care_search_looker_table.engine_conversions}], showLabels: true, showValues: true, type: linear}]
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_value_labels: false
    legend_position: center
    point_style: none
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Ops Granularity: american_family_care_search_looker_table.date_granularity
    row: 39
    col: 14
    width: 10
    height: 8

  - name: ops_rev_vs_cost
    title: "Revenue vs spend by campaign (top 10 by spend)"
    tab_name: Operations
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_column
    fields: [american_family_care_search_looker_table.campaign, american_family_care_search_looker_table.total_cost, american_family_care_search_looker_table.total_revenue]
    sorts: [american_family_care_search_looker_table.total_cost desc]
    limit: 10
    show_view_names: false
    series_types:
      american_family_care_search_looker_table.total_revenue: line
    series_colors:
      american_family_care_search_looker_table.total_cost: "#1D1D1B"
      american_family_care_search_looker_table.total_revenue: "#E31837"
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_value_labels: false
    legend_position: center
    x_axis_label_rotation: -40
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
    row: 47
    col: 4
    width: 10
    height: 8

  - name: ops_top_roas
    title: "Top campaigns by ROAS (spend of $1,000 or more)"
    tab_name: Operations
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_bar
    fields: [american_family_care_search_looker_table.campaign, american_family_care_search_looker_table.roas]
    filters:
      american_family_care_search_looker_table.total_cost: ">=1000"
    sorts: [american_family_care_search_looker_table.roas desc]
    limit: 10
    show_view_names: false
    show_value_labels: true
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    series_colors:
      american_family_care_search_looker_table.roas: "#1D1D1B"
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
    row: 47
    col: 14
    width: 10
    height: 8

  - name: ops_band_detail
    type: text
    title_text: ""
    tab_name: Operations
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:56px;border-radius:16px;background:linear-gradient(90deg,#A5111F 0%,#E31837 50%,#A5111F 100%);box-shadow:0 2px 8px rgba(165,17,31,.20);"><span style="font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:600;color:white;letter-spacing:0.8px;text-transform:uppercase;">Detailed performance</span></div>'
    row: 55
    col: 4
    width: 20
    height: 2

  - name: Ops Campaign
    type: filter
    tab_name: Operations
    row: 57
    col: 4
    width: 8
    height: 1
    ui_config:
      type: dropdown_menu
      display: overflow

  - name: ops_detail
    title: "Detailed performance table"
    tab_name: Operations
    model: afc_search
    explore: american_family_care_search_looker_table
    type: looker_grid
    fields: [american_family_care_search_looker_table.mapping_channel, american_family_care_search_looker_table.campaign, american_family_care_search_looker_table.total_cost, american_family_care_search_looker_table.total_impressions, american_family_care_search_looker_table.total_clicks, american_family_care_search_looker_table.ctr, american_family_care_search_looker_table.cpc, american_family_care_search_looker_table.engine_conversions, american_family_care_search_looker_table.cpa, american_family_care_search_looker_table.cvr, american_family_care_search_looker_table.total_revenue, american_family_care_search_looker_table.roas]
    sorts: [american_family_care_search_looker_table.total_cost desc]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    show_totals: true
    show_row_totals: false
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_font_size: 12
    rows_font_size: 12
    series_cell_visualizations:
      american_family_care_search_looker_table.total_cost:
        is_active: true
      american_family_care_search_looker_table.total_clicks:
        is_active: true
      american_family_care_search_looker_table.engine_conversions:
        is_active: true
    listen:
      Date Range: american_family_care_search_looker_table.date_date
      Region: american_family_care_search_looker_table.region
      Account: american_family_care_search_looker_table.account_rollup
      Condition: american_family_care_search_looker_table.condition
      Budget Group: american_family_care_search_looker_table.budget_group
      Mapping Channel: american_family_care_search_looker_table.mapping_channel
      Channel: american_family_care_search_looker_table.channel
      Conversion Type: american_family_care_search_looker_table.conversion_actions
      Ops Campaign: american_family_care_search_looker_table.campaign
    row: 58
    col: 4
    width: 20
    height: 12

  # ----------------------------------------------------------- TAB: Dictionary

  - name: nav_dict_logo
    type: text
    title_text: ""
    tab_name: Dictionary
    body_text: '<div style="display:flex;justify-content:center;align-items:center;height:100%;background:white;"><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSupnctT7R2nepOPV75YiJnMRQoW1shpvpmHDgc6iDXK5pw9iJhv-NuReI&s=10" style="height:110px;width:auto;display:block;" /></div>'
    row: 0
    col: 0
    width: 4
    height: 3

  - name: nav_dict_1
    type: button
    tab_name: Dictionary
    rich_content_json: '{"text": "Executive overview","description": "Executive overview","href": "","targetTabName": "Executive","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 3
    col: 0
    width: 4
    height: 1

  - name: nav_dict_2
    type: button
    tab_name: Dictionary
    rich_content_json: '{"text": "Conversion","description": "Conversion","href": "","targetTabName": "Conversion","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 4
    col: 0
    width: 4
    height: 1

  - name: nav_dict_3
    type: button
    tab_name: Dictionary
    rich_content_json: '{"text": "Traffic","description": "Traffic","href": "","targetTabName": "Traffic","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 5
    col: 0
    width: 4
    height: 1

  - name: nav_dict_4
    type: button
    tab_name: Dictionary
    rich_content_json: '{"text": "Competition","description": "Competition","href": "","targetTabName": "Competition","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 6
    col: 0
    width: 4
    height: 1

  - name: nav_dict_5
    type: button
    tab_name: Dictionary
    rich_content_json: '{"text": "Operations","description": "Operations","href": "","targetTabName": "Operations","newTab": false,"alignment": "left","size": "medium","style": "TRANSPARENT","color": "#3C4043"}'
    row: 7
    col: 0
    width: 4
    height: 1

  - name: nav_dict_6
    type: button
    tab_name: Dictionary
    rich_content_json: '{"text": "Data dictionary","description": "Data dictionary","href": "","targetTabName": "Dictionary","newTab": false,"alignment": "left","size": "medium","style": "FILLED","color": "#E31837"}'
    row: 8
    col: 0
    width: 4
    height: 1

  - name: dict_links
    type: text
    title_text: ""
    tab_name: Dictionary
    body_text: '<div style="font-family:''Google Sans'',Roboto,Arial,sans-serif;"><div style="font-size:15px;text-align:center;margin-bottom:6px;">Useful links</div><div style="display:flex;flex-wrap:wrap;"><div style="flex:1 1 22%;min-width:210px;"><a href="https://docs.google.com/spreadsheets/d/1YUQQNuK-qr_9zZQ7fh5HygV6-IFRv_lTCelmY3FLxA4/edit?gid=0#gid=0" target="_blank" style="display:block;text-decoration:none;color:#262D33;border:1px solid #E4E6E9;border-radius:10px;padding:12px 14px;margin:6px;background:#FFFFFF;"><b>Auto-Pacing sheet</b><br><span style="font-size:12px;color:#5F6368;">The legacy Google Sheet this dashboard replaces. The mapping and budget tabs live here too.</span><br><span style="font-size:12px;color:#E31837;font-weight:600;">Open in Google Sheets</span></a></div><div style="flex:1 1 22%;min-width:210px;"><a href="https://docs.google.com/spreadsheets/d/1YUQQNuK-qr_9zZQ7fh5HygV6-IFRv_lTCelmY3FLxA4/edit?gid=0#gid=0" target="_blank" style="display:block;text-decoration:none;color:#262D33;border:1px solid #E4E6E9;border-radius:10px;padding:12px 14px;margin:6px;background:#FFFFFF;"><b>Campaign mapping</b><br><span style="font-size:12px;color:#5F6368;">Mapping tab: campaign name to Region, Account group, Keyword type, Condition, Budget group (AFC_MatchTable).</span><br><span style="font-size:12px;color:#E31837;font-weight:600;">Open the mapping tab</span></a></div><div style="flex:1 1 22%;min-width:210px;"><a href="https://docs.google.com/spreadsheets/d/1YUQQNuK-qr_9zZQ7fh5HygV6-IFRv_lTCelmY3FLxA4/edit?gid=0#gid=0" target="_blank" style="display:block;text-decoration:none;color:#262D33;border:1px solid #E4E6E9;border-radius:10px;padding:12px 14px;margin:6px;background:#FFFFFF;"><b>Budget mapping</b><br><span style="font-size:12px;color:#5F6368;">DEPT Budget Mapping tab: monthly budget for Southeast and Northeast (AFC_Budget_MatchTable).</span><br><span style="font-size:12px;color:#E31837;font-weight:600;">Open the budget tab</span></a></div><div style="flex:1 1 22%;min-width:210px;"><a href="https://docs.google.com/document/d/1IApCUY_7WbSMgosNQ4FDf3_-WukuZvzpT5kkj3u-x5c/edit?tab=t.0" target="_blank" style="display:block;text-decoration:none;color:#262D33;border:1px solid #E4E6E9;border-radius:10px;padding:12px 14px;margin:6px;background:#FFFFFF;"><b>Data dictionary</b><br><span style="font-size:12px;color:#5F6368;">Field-by-field reference: sources, calculation logic and legacy comparisons.</span><br><span style="font-size:12px;color:#E31837;font-weight:600;">Open in Google Docs</span></a></div></div></div>'
    row: 0
    col: 4
    width: 20
    height: 4

  - name: dict_rules
    type: text
    title_text: ""
    tab_name: Dictionary
    body_text: '<div style="font-family:''Google Sans'',Roboto,Arial,sans-serif;font-size:13px;color:#3c4043;padding:6px 10px;"><div style="font-size:15px;text-align:center;margin-bottom:6px;">Mapping and budget updates</div>Mapping and budget sheets are ingested automatically on the 1st and 15th of each month. Add or remove rows between runs. Do not rename, reorder, add or remove columns: the ingestion reads a fixed structure. New campaigns show as <b>Unmapped</b> until they are added to the mapping sheet. Budget is set per Region and Month, and budget rows exist on their own so future months appear as soon as the sheet has them.</div>'
    row: 4
    col: 4
    width: 20
    height: 3

  - name: dict_fields
    type: text
    title_text: ""
    tab_name: Dictionary
    body_text: '<div style="font-family:''Google Sans'',Roboto,Arial,sans-serif;font-size:13px;color:#262D33;"><div style="font-size:15px;text-align:center;margin-bottom:6px;">Field reference</div><table style="border-collapse:collapse;width:100%;"><tr><td colspan="2" style="background:#F6F7F9;font-weight:700;color:#5F6368;padding:6px 10px;">Dimensions</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Date, Day, Week, Month, Year</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Calendar date of the activity. Weeks run Monday to Sunday and are labelled with the ISO week of the Monday.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Account</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Corporate NE (AFC Corporate New England) and Corporate SE (AFC Corporate Clinics). Corp-managed Ad.Works will be added once its accounts are connected.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Region</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">NE or SE from the mapping sheet. Budget is matched on it.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Campaign type</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Google campaign type (Search, Performance Max).</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Keyword type</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Brand, NonBrand or PMax from the mapping sheet.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Condition, Budget group, Account group</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">AFC campaign groupings from the mapping sheet.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Market (inferred)</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Read from the metro code or clinic town in the campaign name.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Conversion type</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Picks which conversion families count as Conversions. Moves Conversions, CPA, CVR, Revenue and ROAS only; spend and traffic never change with it.</td></tr><tr><td colspan="2" style="background:#F6F7F9;font-weight:700;color:#5F6368;padding:6px 10px;">Measures</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Spend, Impressions, Clicks</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">From Google Ads. Spend in dollars.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Bookings</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Bookings created (Booking_Created_FP, FP - Appointment Booked). Tracked since August 2026.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Discharged patients</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Patients discharged after a visit (Booking_Discharged_FP, Discharged Patient): the closest signal to a completed visit. Tracked since August 2026.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Calls</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Clicks to call, calls from ads, website phone calls and call leads.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Appointment clicks</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Clicks on Schedule appointment (GA4 and FP). Not recorded since mid-September 2026.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Clinic leads</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Per-clinic &quot;Leads (clinic ID) - Town&quot; actions. Not recorded since mid-September 2026 (NE since August 2026).</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Conversions</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Sum of the families picked in the Conversion type filter. Default: appointment clicks, calls, clinic leads (to be confirmed now that bookings tracking replaced appointment clicks and clinic leads).</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Revenue</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Google conversion value for the families in the Conversion type filter.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Budget</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Monthly planned spend per Region from the budget sheet.</td></tr><tr><td colspan="2" style="background:#F6F7F9;font-weight:700;color:#5F6368;padding:6px 10px;">Calculated, always from period totals</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">CTR, CPC</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Clicks / Impressions, Spend / Clicks.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">CPA, CVR, ROAS</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Spend / Conversions, Conversions / Clicks, Revenue / Spend.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Cost per booking, discharged patient, call</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Spend / that conversion family (same for appointment clicks and clinic leads).</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Booking to visit rate</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Discharged patients / Bookings: the share of bookings that became a visit.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Search impression share</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Impressions / Eligible impressions. Lost IS (rank) and Lost IS (budget) = lost eligible impressions / eligible impressions. Click share = Clicks / Eligible clicks.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Budget spent, projected</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Spend to date / Budget. Projected = spend to date / days elapsed x days in month.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Deltas</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">% change or absolute change (points for rates) vs the previous period or the previous row. Green is better, red is worse; for CPC and CPA lower is better.</td></tr><tr><td colspan="2" style="background:#F6F7F9;font-weight:700;color:#5F6368;padding:6px 10px;">Notes</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Tracking change</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Conversion tracking changed in August to September 2026 (from appointment clicks and clinic leads to FP bookings), so comparisons across those months are not like for like.</td></tr><tr><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;font-weight:600;white-space:nowrap;vertical-align:top;">Year over year</td><td style="padding:6px 10px;border-bottom:1px solid #E4E6E9;">Same period last year fills in once the data covers last year (history starts January 2026).</td></tr></table></div>'
    row: 7
    col: 4
    width: 20
    height: 14

  - name: dict_decisions
    type: text
    title_text: ""
    tab_name: Dictionary
    body_text: '<div style="font-family:''Google Sans'',Roboto,Arial,sans-serif;font-size:13px;color:#262D33;padding:0 10px;"><div style="font-size:15px;text-align:center;margin-bottom:6px;">Decisions we need from AFC</div><ol style="padding-left:18px;margin:0;"><li style="margin:0 0 8px;"><b>Conversion tracking change</b><br><span style="color:#5F6368;">Schedule appointment clicks and clinic leads stopped recording around mid-September 2026; Booking_Created_FP and Booking_Discharged_FP started in August. Please confirm the switch was intentional and the cutover date.</span></li><li style="margin:0 0 8px;"><b>What counts as a conversion</b><br><span style="color:#5F6368;">Should Conversions (and CPA, CVR) now be Bookings + Calls? The current default, appointment clicks + calls + clinic leads, is effectively calls only since October.</span></li><li style="margin:0 0 8px;"><b>Booking tracking in NE</b><br><span style="color:#5F6368;">NE clinic leads stopped after July. Is booking tracking set up for the NE clinics?</span></li><li style="margin:0 0 8px;"><b>Ad.Works accounts</b><br><span style="color:#5F6368;">Which Corp-managed Ad.Works accounts should be connected, and their account IDs, so Ad.Works can be added to the Account filter.</span></li><li style="margin:0 0 8px;"><b>Clinic and franchisee reporting</b><br><span style="color:#5F6368;">How clinic and franchise accounts should be grouped beyond Corporate NE, Corporate SE and Ad.Works.</span></li><li style="margin:0 0 8px;"><b>Conversion values</b><br><span style="color:#5F6368;">Are Google Ads conversion values real revenue? If not, ROAS will be labelled indicative or hidden.</span></li><li style="margin:0 0 8px;"><b>Mapping ownership</b><br><span style="color:#5F6368;">Who at AFC adds new campaigns to the mapping sheet when they launch, so they don''t show as Unmapped?</span></li></ol></div>'
    row: 21
    col: 4
    width: 20
    height: 8

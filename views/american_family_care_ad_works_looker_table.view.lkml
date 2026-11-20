view: american_family_care_ad_works_looker_table {
  sql_table_name: "DBO"."AmericanFamilyCare_AdWorks_Looker_table" ;;

  dimension: account {
    type: string
    sql: ${TABLE}."Account" ;;
  }
  dimension: account_id {
    type: string
    sql: ${TABLE}."Account_ID" ;;
  }
  dimension: ad_group {
    type: string
    sql: ${TABLE}."AdGroup" ;;
  }
  dimension: ad_group_id {
    type: string
    sql: ${TABLE}."AdGroup_ID" ;;
  }
  dimension: available_clicks {
    type: number
    sql: ${TABLE}."Available_Clicks" ;;
  }
  dimension: available_impressions {
    type: number
    sql: ${TABLE}."Available_Impressions" ;;
  }
  dimension: campaign {
    type: string
    sql: ${TABLE}."Campaign" ;;
  }
  dimension: campaign_id {
    type: string
    sql: ${TABLE}."Campaign_ID" ;;
  }
  dimension: channel {
    type: string
    sql: ${TABLE}."Channel" ;;
  }
  dimension: clicks {
    type: number
    sql: ${TABLE}."Clicks" ;;
  }
  dimension: clickthrough_conversions {
    type: number
    sql: ${TABLE}."Click-through_Conversions" ;;
  }
  dimension: client {
    type: string
    sql: ${TABLE}."Client" ;;
  }
  dimension: client_id {
    type: string
    sql: ${TABLE}."Client_ID" ;;
  }
  dimension: clinic_count {
    type: number
    sql: ${TABLE}."Clinic_Count" ;;
  }
  dimension: clinic_ids {
    type: string
    sql: ${TABLE}."Clinic_IDs" ;;
  }
  dimension: clinics {
    type: string
    sql: ${TABLE}."Clinics" ;;
  }
  dimension: conversion_id {
    type: string
    sql: ${TABLE}."Conversion_ID" ;;
  }
  dimension: conversion_type {
    type: string
    sql: ${TABLE}."Conversion_Type" ;;
  }
  dimension: cost {
    type: number
    sql: ${TABLE}."Cost" ;;
  }
  dimension_group: date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."Date" ;;
  }
  dimension: day {
    type: string
    sql: ${TABLE}."Day" ;;
  }
  dimension: device {
    type: string
    sql: ${TABLE}."Device" ;;
  }
  dimension: dma {
    type: string
    sql: ${TABLE}."DMA" ;;
  }
  dimension: facility_ids {
    type: string
    sql: ${TABLE}."Facility_IDs" ;;
  }
  dimension: first_opening_year {
    type: number
    sql: ${TABLE}."First_Opening_Year" ;;
  }
  dimension: franchisee {
    type: string
    sql: ${TABLE}."Franchisee" ;;
  }
  dimension: impressions {
    type: number
    sql: ${TABLE}."Impressions" ;;
  }
  dimension: month {
    type: string
    sql: ${TABLE}."Month" ;;
  }
  dimension: primary_conversions {
    type: number
    sql: ${TABLE}."Primary_Conversions" ;;
  }
  dimension: primary_revenue {
    type: number
    sql: ${TABLE}."Primary_Revenue" ;;
  }
  dimension: publisher {
    type: string
    sql: ${TABLE}."Publisher" ;;
  }
  dimension: revenue {
    type: number
    sql: ${TABLE}."Revenue" ;;
  }
  dimension: search_impressions_lost_to_budget {
    type: number
    sql: ${TABLE}."Search_Impressions_Lost_to_Budget" ;;
  }
  dimension: search_impressions_lost_to_rank {
    type: number
    sql: ${TABLE}."Search_Impressions_Lost_to_Rank" ;;
  }
  dimension: source {
    type: string
    sql: ${TABLE}."Source" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."State" ;;
  }
  dimension: total_conversions {
    type: number
    sql: ${TABLE}."Total_Conversions" ;;
  }
  dimension: video_completions {
    type: number
    sql: ${TABLE}."Video_Completions" ;;
  }
  dimension: video_views {
    type: number
    sql: ${TABLE}."Video_Views" ;;
  }
  dimension: viewthrough_conversions {
    type: number
    sql: ${TABLE}."View-through_Conversions" ;;
  }
  dimension: week_end {
    type: string
    sql: ${TABLE}."Week_End" ;;
  }
  dimension: week_of_year {
    type: string
    sql: ${TABLE}."Week_of_Year" ;;
  }
  dimension: week_start {
    type: string
    sql: ${TABLE}."Week_Start" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."Year" ;;
  }
  measure: count {
    type: count
  }
}

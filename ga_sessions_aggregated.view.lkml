
view: ga_sessions_weekly {
  view_label: "Weekly Sessions Summary"
  derived_table: {
    datagroup_trigger: weekly_cache
    explore_source: ga_sessions {
      timezone: "America/New_York"
      column: visitStart_week {}
      column: market {}
      column: is_google_analytics { field: device.is_google_analytics }
      column: is_weightwatchers { field: first_page.is_weightwatchers }
      column: sus1_visitors {}
      column: homepage_visitors {}
      column: group_id_new { field:hits_eventInfo.group_id_new}
      column: my_day_users {}
      column: connect_users {}
      column: groups_users {}
      column: myday_groups_carousel_users {}
      column: homepage_prospect_visitors {}
      column: deviceCategory { field: device.deviceCategory }
      column: screenResolution {field:device.screenResolution}
      column: deviceInfo {field:device.mobileDeviceInfo}
      column: unique_prospects {}
      column: unique_funnel_prospects {}
      column: unique_visitors {}
      column: session_count {}
      column: transactions_count { field: totals.transactions_count }
      column: count_sessions_event1 { field: funnel_growth_dashboard.count_sessions_event1_prospects }
      column: count_sessions_event12 { field: funnel_growth_dashboard.count_sessions_event12_prospects }
      column: count_sessions_event123 { field: funnel_growth_dashboard.count_sessions_event123_prospects }
      column: count_sessions_event1234 { field: funnel_growth_dashboard.count_sessions_event1234_prospects }
      column: count_sessions_event12345 { field: funnel_growth_dashboard.count_sessions_event12345_prospects }
      column: iaf_copyLink_desktop {}
      column: iaf_sendEmail_desktop {}
      column: iaf_myDay_users_desktop {}
      column: numVisitsConverting {}
#       column: unique_invited_visitors { field: invited_users.unique_visitors }
      filters: {
        field: ga_sessions.partition_date
        value: "70 weeks ago for 70 weeks"
#         value: "1 weeks ago for 1 weeks"
      }
      filters: {
        field: ga_sessions.visitStart_week
        value: "70 weeks ago for 70 weeks"
#           value: "1 weeks ago for 1 weeks"
      }
      filters: {
        field: funnel_growth_dashboard.partition_date
        value: "70 weeks ago for 70 weeks"
        # value: "1 weeks ago for 1 weeks"
      }
#       filters: {
#         field: invited_users.partition_date
#         value: "70 weeks ago for 70 weeks"
#         # value: "1 weeks ago for 1 weeks"
#       }
#       filters: {
#         # This filter enables us to force a left join on the invited_users view.
#         field: invited_users.left_join
#         value: "Yes"
#       }

    }
  }
  dimension: visitStart_week {
    view_label: "Session"
    label: "Visit Start Week"
    type: date_week
    convert_tz: no
  }
  dimension: market {
    view_label: "Session"
    label: "Market"
  }
  dimension: is_google_analytics {
    view_label: "Session"
    label: "Device Is Google Analytics"
    type: yesno
  }
  dimension: is_weightwatchers {
    view_label: "Session:First Page Visited"
    label: "Is weightwatchers.com"
    type: yesno
  }
  dimension: deviceCategory {
    view_label: "Session"
    label: "Device Category"
  }

  dimension: screenResolution {
    view_label: "Session"
    label: "screenResolution"
  }

  dimension: deviceInfo {
    view_label: "Session"
    label: "deviceInfo"
  }

  measure: connect_users {
    type: sum
  }

measure: session_count {
  type: sum
}

  measure: myday_groups_carousel_users {
    type: sum
  }

  dimension: region_name {
    type: string
    sql:  case when ${market} = "US"
    then "United States"
    WHEN ${market} = "DE"
    THEN "Germany"
    WHEN ${market} = "GB"
    THEN "UK"
    WHEN ${market} = "FR"
    THEN "France"
    WHEN ${market} = "CA"
    THEN "Canada"
    WHEN ${market} = "SE"
    THEN "Sweden"
    WHEN ${market} = "AU"
    THEN "ANZ"
    WHEN ${market} = "NL"
    THEN "Netherlands"
    WHEN ${market} = "BE"
    THEN "Belgium"
    WHEN ${market} = "CH"
    THEN "Switzerland"
    WHEN ${market} = "BR"
    then "Brazil"
    ELSE null
    end ;;
  }

dimension: group_id_new {
  type: string
}

dimension: group_id_name {
  type: string
  sql: case when ${group_id_new} = '6ad99fd2-3dd7-4bf6-ae09-7bdb5f940395' then 'Black Women'
              WHEN ${group_id_new} = 'bfb51aec-f1bd-4ab3-9667-a97b04636cc8' then 'Arizona Members'
              WHEN ${group_id_new} = 'f8bb2853-68d2-4f1b-b2ed-9ef81c6d0ea4' THEN 'Cincinnati Members'
              WHEN ${group_id_new} = '2357dc29-e414-43d9-bbe2-71dbb529fad5' THEN 'Dry WW'
              WHEN ${group_id_new} = '4a2d8345-3118-4adb-884d-1d6862876392' THEN 'San Antonio Members'
              WHEN ${group_id_new} = 'e7f04720-549e-4aa3-a842-247dcd9c7b8c' THEN 'Latinas'
              WHEN ${group_id_new} = '0ba56447-dab4-4db3-9ae9-ad4e9207915f' THEN 'Portland Members'
              WHEN ${group_id_new} = '52bc0eb3-cec4-4df3-9b62-35f424bf1124' THEN 'Kansas City Members'
              WHEN ${group_id_new} = 'ef4233b6-6936-448a-a55c-629fa4e5dfb3' THEN 'Triathlon Prep'
              WHEN ${group_id_new} = '956da33d-5de0-43eb-979f-3ea0541be575' THEN 'Minneapolis Members'
              WHEN ${group_id_new} = 'eac9b5a8-5196-4b4f-aa43-e3d5298f8b25' THEN 'Wisconsin Members'
              WHEN ${group_id_new} = 'fd937f96-5c80-4bb3-919d-b89bcd22b63b' THEN 'Washington, DC Members'
              WHEN ${group_id_new} = '6b03f7f3-e9b4-4afa-a9c0-af9feb387b5b' THEN 'Seattle Members'
              WHEN ${group_id_new} = '52d817ac-d285-4dd0-b69a-a4d34e8a14a6' then 'San Diego Members'
              WHEN ${group_id_new} = 'ddcfc003-7eac-4b08-a8f3-6068d4bde4e8' then 'Michigan Members'
              WHEN ${group_id_new} = '7f63ed8d-5036-43e8-9377-71f6e808890b' then 'Bay Area Members'
              WHEN ${group_id_new} = 'd530acd3-976a-40db-a4b7-fcc09d819e44' then 'Living with Diabetes'
              WHEN ${group_id_new} = '15349788-2b5d-4f57-bbf0-72278f03b375' then 'Food Finds'
              WHEN ${group_id_new} = 'a1294e41-83b9-4bbe-ac05-e48759f375d4' then 'Bride To Be'
              WHEN ${group_id_new} = 'e428367d-28d0-4c73-8de4-b64a23edf7a8' then 'Maschen statt naschen'
              WHEN ${group_id_new} = 'ca232bce-71cf-4f8b-a634-fa17da1cfec9' then 'Fashionistas'
              WHEN ${group_id_new} = '47a2f052-174f-4f1c-810a-02017d3eeff4' then 'En stabilisation'
              WHEN ${group_id_new} = '2d1adf78-acf5-4820-8607-0dc647b01480' then 'Gratidão'
              WHEN ${group_id_new} = '2507eb10-9d56-497f-9926-33e0dab8b698' then 'Autocompaixão'
              WHEN ${group_id_new} = '99a3930e-7062-4256-8a54-210ed4a1e74f' then 'Self-Compassion'
              WHEN ${group_id_new} = '74d95b92-9dc2-4bc5-ac6c-d5bbfcaed281' then 'New to Activity'
              WHEN ${group_id_new} = 'eb56eb99-b035-48f8-8cc9-2d49465f10a2' then 'Gratitude'
              WHEN ${group_id_new} = '45f7ec26-605d-409c-97af-7e61e6badebc' then 'Cardio'
              WHEN ${group_id_new} = '7f125194-14ec-411b-9369-5116a82ace3b' then 'Jardinage'
              WHEN ${group_id_new} = '91a42458-8566-4179-9d2b-fbf990073469' then 'Mindfulness'
              WHEN ${group_id_new} = 'a13032ed-9f91-4a83-9dea-79c69a5b8968' then 'Always Improving'
              WHEN ${group_id_new} = '0058ad3b-06cd-4758-9dd4-0e886a092ded' then 'New to Activity'
              WHEN ${group_id_new} = 'de1f3f0b-0bc8-4d39-a6ad-5a5a8b98e42e' then 'Meditation'
              WHEN ${group_id_new} = '1bc9de2f-3e06-41e0-9750-76dc963b240c' then 'Eu amo viajar'
              WHEN ${group_id_new} = 'a2671644-cc94-499c-85cd-d14870aad0ea' then 'Se remettre sur la bonne voie'
              WHEN ${group_id_new} = '21bfc85a-3f73-4ab1-abcc-4eed2b1d7864' then 'Gratitude'
              WHEN ${group_id_new} = '8c53d9a2-2467-4cb9-8a14-1296085fcaf7' then 'Academia'
              WHEN ${group_id_new} = '1f769abf-a08e-4151-b0c8-1d94277b6130' then 'New to Activity'
              WHEN ${group_id_new} = '0df55cfc-bdc1-4e4b-95a6-15059b6988aa' then 'Mindfulness'
              WHEN ${group_id_new} = 'bc3f5620-94c2-49b6-b1bb-1264a8c962a9' then 'Mindfulness'
              WHEN ${group_id_new} = 'ae8bbdd0-0d0f-4aba-9f79-68757749db59' then 'Hitta glädje'
              WHEN ${group_id_new} = 'aaf38e1e-91b1-4d34-95ae-54c2f36e13ff' then 'Caminhada'
              WHEN ${group_id_new} = 'd08b1005-7ca2-408e-af8c-29d134662636' then 'Glúten Free'
              WHEN ${group_id_new} = 'f2e33ee6-094d-4ebd-abff-fe23814c93a4' then 'PontosFit'
              WHEN ${group_id_new} = '64911e21-6265-431f-96ce-0213f5638132' then 'Mindfullness'
              WHEN ${group_id_new} = 'abd62f2a-fd78-4306-bee3-77af12c96a2d' then 'Step Trackers'
              WHEN ${group_id_new} = '7d423e33-77cb-4159-bd3a-d3a8f9a9e1cb' then 'My Why'
              WHEN ${group_id_new} = '20950dfa-4c09-46a6-8cc2-e3d7f86e98b8' then 'Gratitude'
              WHEN ${group_id_new} = '68d621f2-8f20-40f7-9d89-b00e0a64ee76' then 'Mindfulness'
              WHEN ${group_id_new} = '447fac0b-0b11-4e44-878c-1c4904dfa68b' then '60+'
              WHEN ${group_id_new} = '6055d6ef-2ff9-4593-ab4a-5c009ed1b015' then 'Nurses of WW'
              WHEN ${group_id_new} = '64bf8f32-d376-4127-9d8c-c9d3571cc2bd' then '5K Prep'
              WHEN ${group_id_new} = '4b30b70b-1e43-4fb6-8bc4-0fadc0f3595b' then 'Crafts'
              WHEN ${group_id_new} = 'ace452e4-a08b-4caf-88f7-68742b42e132' then 'Instant Pot Lovers'
              WHEN ${group_id_new} = '4b9eff42-75e6-4090-bcec-d2c5050041bb' then 'Tennis'
              WHEN ${group_id_new} = '6883d2b8-4e38-488b-b481-cf1fe19fbba0' then 'Wine Lovers'
              WHEN ${group_id_new} = 'd6324a08-11b9-4eb2-90ae-a4a8dd5ec9b2' then 'Brides'
              WHEN ${group_id_new} = 'c75277c6-abf5-47dc-bdd5-2d6a3d117523' then '70s Plus'
              WHEN ${group_id_new} = 'e9141ed5-a6b7-45f1-b7e6-6ccab193f6ec' then 'Aaptiv Lovers'
              WHEN ${group_id_new} = 'b1d8cb1a-93bc-461d-81ba-9a7d33f6dd46' then 'Futurs mariés'
              WHEN ${group_id_new} = '220f0bca-3307-4e90-b635-3e04de2128a5' then 'Kosher'
              WHEN ${group_id_new} = '2298d494-68c8-4ace-9de8-d07c24c711dc' then 'Then and Now'
              WHEN ${group_id_new} = 'ec1cc3ea-6b84-43e1-91f7-3e702fcac2db' then 'Hommes'
              WHEN ${group_id_new} = '80e2fd5a-836f-4b01-acda-cf258bd316a6' then 'Pilates'
              WHEN ${group_id_new} = '32e40f54-8c2d-4198-9b5d-e4309267a1a2' then 'Skiing'
              WHEN ${group_id_new} = '3751fa15-639e-4e2d-9e4a-b04433014d4c' then 'LGBTQ+'
              WHEN ${group_id_new} = '763c19e3-8c4c-4882-ae42-69807de33322' then 'Cooking for 1'
              WHEN ${group_id_new} = '9e9ca186-36d4-43c8-968e-ba49c42ed00f' then 'Stay-at-Home Parents'
              WHEN ${group_id_new} = 'c2f79559-7f49-4f0b-9ae1-7c7d02e7df78' then 'In My 60s'
              WHEN ${group_id_new} = '7d3c5420-a985-406a-b991-4de26623913d' then 'Club des tortues'
              WHEN ${group_id_new} = 'f469124e-f31c-4261-9b9b-746709065e43' then 'Pfundsgruppe'
              WHEN ${group_id_new} = '7c4cc791-37c2-42e5-a7e4-ab8286443d60' then 'Rezepte'
              WHEN ${group_id_new} = 'b323b46b-3df4-48db-8443-aaf1cdd6bdde' then '(K)eine Frage des Alters'
              WHEN ${group_id_new} = '5cbf129e-3e1c-409c-8b37-353e6a2a695e' then '10 lb club'
              WHEN ${group_id_new} = 'd810a00b-e436-4ba5-a201-64237ddff5d3' then 'In My 50s'
              WHEN ${group_id_new} = '355ca630-cac2-44aa-b015-ab5b914dfa79' then 'Mamas unter sich'
              WHEN ${group_id_new} = '868b313c-379e-45d8-9066-c2b14b48db66' then 'Nouveaux'
              WHEN ${group_id_new} = 'ef1dbeb0-8ff2-4b3b-87fa-48a97fe0c6f2' then '100+ lb club'
              WHEN ${group_id_new} = '11576244-e8bf-4302-9569-67055857c4ba' then 'Végétarien'
              WHEN ${group_id_new} = 'b5814e8a-e423-45d1-b37e-a405e6865452' then 'Neu hier'
              WHEN ${group_id_new} = 'bf3bd975-1c76-457d-a63a-d15aa39f3ab6' then 'Vegans'
              WHEN ${group_id_new} = '0a14dde6-402f-4bfa-91d3-ca8274b0f201' then 'In My 20s'
              WHEN ${group_id_new} = '32c0c675-aa54-422d-b973-fa6a6fa90260' then 'Running'
              WHEN ${group_id_new} = 'cb6972a3-8c36-49d5-bdab-afc3bc55e230' then 'Recipes'
              WHEN ${group_id_new} = '03849453-b810-4acb-9d38-573549c7f88a' then 'Turtle Club'
              WHEN ${group_id_new} = '0e0d0164-6e2d-4c9f-850a-eea25063aa34' then 'Meal Prep'
              WHEN ${group_id_new} = '10bbd814-6132-4293-af82-bcfe4f21cb88' then 'Gluten Free'
              WHEN ${group_id_new} = '9d62112f-c794-4a3c-9474-6278a669e04e' then '25 lb club'
              WHEN ${group_id_new} = 'd4782fdb-36ad-4587-857a-1cea847a4848' then 'Foodies'
              WHEN ${group_id_new} = 'ef6e3b74-965c-485f-9194-d638ce6bda25' then 'In My 40s'
              WHEN ${group_id_new} = '81675bab-5a08-4afa-b6dd-265813ade60f' then 'Recipes'
              WHEN ${group_id_new} = '4dadf0b0-3dc9-4cd3-9576-b52b82248663' then 'Meal Prep'
              WHEN ${group_id_new} = '322ebe16-a251-4089-8443-d5d00ca0fdec' then 'Living with Pets'
              WHEN ${group_id_new} = 'edade505-35fa-4f32-af17-b9ed75fb8c6f' then 'Motivé'
              WHEN ${group_id_new} = '7f56e262-b062-4729-b99b-634b7edd7113' then 'Newbies'
              WHEN ${group_id_new} = '39bbf1de-655c-44df-804f-ceba729ee043' then 'Vegetarian'
              WHEN ${group_id_new} = '70bc7079-0a72-4342-b58f-9f7cad55fd4a' then 'Durchstarten'
              WHEN ${group_id_new} = '475e530a-fa02-4b2a-82d6-e7f8263e0500' then '50 lb club'
              WHEN ${group_id_new} = '2e0c2b51-0aa0-449f-930f-dd0971cec3db' then 'Yoga'
              WHEN ${group_id_new} = '6ebd0b30-c782-402e-b40b-f49acf8a598d' then 'In my 20s'
              WHEN ${group_id_new} = '3693fb03-7b38-4e40-aab0-18cff786bcc5' then 'In my 30s'
              WHEN ${group_id_new} =  '4bec5a1a-2e0b-49f5-a652-972d60714503' then 'Menu Prep'
              WHEN ${group_id_new} =  '635f37fb-54b4-402f-adae-349784bb5a06' then 'Book Club'
              WHEN ${group_id_new} =  '6cfb4ff8-63f0-4317-88ed-b40bf7d787e4' then 'Crafty Corner'
              WHEN ${group_id_new} =  '7e3d26a7-821f-4712-8f88-43bd5adddede' then 'Mums and Dads'
              WHEN ${group_id_new} =  '9153474f-6e7f-4369-b7e4-b530b9a930cd' then 'Running'
              WHEN ${group_id_new} =  '9719900f-fce9-485c-9c1e-5da7162c42a6' then 'In my 30s'
              WHEN ${group_id_new} =  '21968ac7-336f-44b2-a522-292f4d091117' then 'Foodies'
              WHEN ${group_id_new} =  '8b17ae2f-86b9-4f02-9241-f47fb317ac56' then 'Vélo'
              WHEN ${group_id_new} =  '453a250f-801a-4e4f-b51f-b6eab0c4f7fb' then 'Futurs mariés'
              WHEN ${group_id_new} =  'de1f3f0b-0bc8-4d39-a6ad-5a5a8b98e42e' then 'Meditation'
              WHEN ${group_id_new} =  'a2aed4a4-263e-43ec-ae29-c45408add273' then 'Les hommes WW'
              WHEN ${group_id_new} =  '68cdf35f-8550-4e1d-92f6-94908276f25b' then 'En pleine conscience'
              WHEN ${group_id_new} =  '6e2962aa-9e5d-4f56-b7fc-01e45411c469' then 'Végétaliens'
              WHEN ${group_id_new} =  'baa4d146-ec95-4a5d-910a-e1d954eaa8a9' then 'Étudiants WW'
              WHEN ${group_id_new} =  '8d7258a7-c712-4a76-b28f-baec9d8fead6' then 'Club de lecture'
              WHEN ${group_id_new} =  '95acbd0c-8dc5-459d-abba-f1cda62ac13b' then 'Manutenção'
              WHEN ${group_id_new} =  '3fea7df3-b30a-4c26-953b-05e2b5feb977' then 'Gym'
              WHEN ${group_id_new} =  '551db6e4-405b-40a0-92a9-d99e450b8e09' then 'Voyager'
              WHEN ${group_id_new} =  'abdf508c-1a31-4d09-add3-58be0b4f0b15' then 'Hommes'
              WHEN ${group_id_new} =  'e74376b3-f68f-4b64-ab5f-01423a3ad3b4' then 'Avós'
              WHEN ${group_id_new} =  'b93432de-6017-466a-89b5-56000ecda564' then 'Noivas & Noivos'
              WHEN ${group_id_new} =  '9703e166-4fe5-433f-a0cd-08c9e459d408' then 'Tuinieren'
              WHEN ${group_id_new} =  '4022ed1d-4fd5-4ffd-8195-3affffe63aee' then 'Reizen'
              WHEN ${group_id_new} =  '25e630b2-dcde-4bdd-84b3-884f26750441' then 'Gars WW'
              WHEN ${group_id_new} =  'b42edd7e-d18a-409f-8661-19c1e4770119' then 'Devagar e sempre'
              WHEN ${group_id_new} =  'b98e0f2e-cffc-460d-8a9d-b013be61a416' then 'Course à pied'
              WHEN ${group_id_new} =  '1037b908-032c-4362-9fe0-6ad2caa58346' then 'Garten'
              WHEN ${group_id_new} =  'b5d11202-cd08-415f-a735-99fbf9455f30' then 'Lire'
              WHEN ${group_id_new} =  'b6ba453e-bd40-4e53-82aa-5095dd4c87a5' then 'Amamentando'
              WHEN ${group_id_new} =  '58e56300-45de-4e06-bc9a-abfccaf63b53' then 'Pets'
              WHEN ${group_id_new} =  '8e970dd2-59e3-4cab-8024-66b26a5ea9fd' then 'Végétalien'
              WHEN ${group_id_new} =  '0a529775-9318-4ebf-9b86-feb620b068c7' then 'Fitness'
              WHEN ${group_id_new} =  '2f3b18d7-ab50-49a1-ab5f-aa2b20100af2' then 'Mon histoire'
              WHEN ${group_id_new} =  '4619e313-4fc7-460b-99f1-11dd417bde3c' then 'Mindfulness'
              WHEN ${group_id_new} =  '718d1e95-84b4-4d04-8832-a5b0c94d1eff' then 'Fietsen'
              WHEN ${group_id_new} =  '617e65ae-9881-4ed6-96ad-b15516266b17' then 'Kitchen Novices'
              WHEN ${group_id_new} =  'ab9abd11-d1ce-4531-9511-1bb815e9612e' then '1 Year In'
              WHEN ${group_id_new} =  '76cdcbf3-e8e1-4cf6-94fa-81e3dcbf321a' then 'Meal preppen'
              WHEN ${group_id_new} =  '6a385303-75dd-4082-866d-39d1dddb5dde' then 'Goal Setting'
              WHEN ${group_id_new} =  '72062975-0bf5-483b-9397-cb2c05253eed' then 'Goal Setting'
              WHEN ${group_id_new} =  '068e786c-3328-4c06-ba0b-ceafbfd2bb37' then 'Get Back on Track'
              ##WHEN ${group_id_new} =  'b7d79c1a-8213-4d57-af1d-773b56c9d8c3' then 'WW on the road'
              WHEN ${group_id_new} =  'ae63367b-41b8-490d-8f02-f43450acccae' then 'Hiking'
              WHEN ${group_id_new} =  '5cc9e4e8-c83f-4f3e-868b-7d6ed5e20995' then 'Vegetarisch'
              WHEN ${group_id_new} =  '9748291f-2dfd-47c8-bc59-8ab55bbcc13a' then 'Family friendly foodies'
              WHEN ${group_id_new} =  '6ed5e4cc-f523-4699-95ed-84e37e7534fa' then 'Dairy Free'
              WHEN ${group_id_new} = '7398a634-723c-454d-ab68-953e72ea30e4' then 'Newbies'
              WHEN ${group_id_new} = '21968ac7-336f-44b2-a522-292f4d091117' then 'Foodies'
              WHEN ${group_id_new} = 'c0484f1c-6602-4a84-986e-1669eae60125' then 'Grandparents'
              WHEN ${group_id_new} = '86f69da3-092a-4b7a-bd77-44459b818d22' then 'Crossfit Enthusiasts'
              WHEN ${group_id_new} = '563dd7a2-6bf6-41a4-ad5d-89a4d86a67a1' then 'Courir'
              when ${group_id_new} = 'd32853ef-fb31-4480-ba7f-605fab8e3329' then 'Get Back on Track'
              when ${group_id_new} = '4cee7bb6-c212-4997-af4f-feceb8c49ef8' then 'Meal Prep'
              when ${group_id_new} = '77d61645-d54f-476d-b2d9-75ee51cb7bb7' then 'Book Lovers'
              when ${group_id_new} = '8979c120-f06a-4f78-835f-d2f834bc6f0a' then 'Mannen'
              when ${group_id_new} = 'b460d2bc-62f8-4625-8344-70abe47acf21' then 'Studenten'
              when ${group_id_new} = 'bb9b3c0c-a4a9-4092-b7f7-b458f7933273' then 'Opnieuw beginnen'
              when ${group_id_new} = '1f0e2e07-d3df-489d-b9b2-ed93dd4b4fba' then 'Préparation de repas'
              when ${group_id_new} = '37f3365f-d4a8-43f9-ac9e-1ae3f0d4ac91' then 'Students'
              when ${group_id_new} = 'baa4d146-ec95-4a5d-910a-e1d954eaa8a9' then 'Étudiants WW'
              when ${group_id_new} = '80a331b5-2696-4eb9-bd9d-c722ac61af81' then 'Huisdieren'
              when ${group_id_new} = '4f45b5d2-092e-492b-aff2-a9209e616980' then 'Here for Health'
              when ${group_id_new} = '1018889a-9b00-442a-8443-24f85a6cf85c' then 'Sportschool'
              when ${group_id_new} = 'a625537b-e779-4a1c-831d-25ce3817c655' then 'Für die ganze Familie'
              WHEN ${group_id_new} = 'c128b21c-753f-4807-95f2-af661eff9138' THEN 'Meine Motivation'
              WHEN ${group_id_new} = 'fdc3424b-f0d5-4194-b4ba-68cb8e18b105' THEN 'Glutenfrei'
              WHEN ${group_id_new} = '4bd07f76-1a54-4e2a-be45-47281cd0a7ff' THEN 'Endspurt'
              WHEN ${group_id_new} = '45cc51cc-2412-489e-a2b5-38a3057da3cb' THEN 'Erhaltung'
              WHEN ${group_id_new} = '589f6f9b-d05d-4718-bf66-10f7a5f2d56a' THEN 'Hålla vikten'
              WHEN ${group_id_new} = 'b20e0c36-eb7c-4fbf-9ee8-c946a2207a4b' THEN 'Tiere'
              WHEN ${group_id_new} = 'f2abc75c-2f43-491b-8027-a984f3028de8' THEN 'Amis des animaux'
              WHEN ${group_id_new} = '1627767d-2d94-4714-8afe-c89964893d9c' THEN 'Loisirs créatifs'
              WHEN ${group_id_new} = '1810c72e-f945-4317-bcb9-f00b4f30d455' THEN 'Yoga'
              WHEN ${group_id_new} = '85d65a9f-0119-43e3-ad53-2edf53352ba5' THEN 'Foodhacks'
              WHEN ${group_id_new} = '2a7e1993-e0f4-487a-bcac-666d8def707a' THEN 'Blau ist das Ziel'
              WHEN ${group_id_new} = '30738689-739e-4367-8d3f-149980c44e10' THEN 'Corrida'
              WHEN ${group_id_new} = '3cf71a6a-6275-4899-83a7-c790b479a12b' THEN 'Zen'
              WHEN ${group_id_new} = '2faea726-d0fc-42d5-9443-335624ab428f' THEN 'Mitt varför'
              WHEN ${group_id_new} = 'ec3167e7-25f4-4b4a-8e05-1d9de0379a15' THEN 'Passionnés de cuisine'
              WHEN ${group_id_new} =  '14ab4f5e-4cc1-4aed-aee4-21e065d4b3a2' then 'In my 20s'
              WHEN ${group_id_new} =  '7c7735a9-bc8a-4761-b764-01a5d81e5f03' then 'Pour les mamans'
              WHEN ${group_id_new} =  '3c3d9f7c-9e0f-449d-9067-ae436581fe02' then 'Wandelen'
              WHEN ${group_id_new} =  'eb10dbe9-898b-4c4d-b398-ef35f2bea259' then 'Mijn verhaal'
              when ${group_id_new} = '89638b22-d0f0-4f8b-bbb1-e61bbb8d9c1e' then 'Stabiliser'
              when ${group_id_new} = 'd05b4824-c3a6-4291-ba71-a423c5d8f2d8' then 'Nouvelles mamans'
              when ${group_id_new} = '26ac535a-cfc2-4e7a-a7d5-d469d4fadc98' then 'Vardagspusslet'
              when ${group_id_new} = 'c4551f83-267a-406a-9910-5fbd9f1f2109' then 'Créativité'
              when ${group_id_new} = '33716424-afc4-48ba-a1b0-67b3364f99c1' then 'Étudiants'
              when ${group_id_new} = '8fd0cf8f-7080-4b8d-be23-fb12d1311c75' then 'Low Carb'
              when ${group_id_new} = '7d423e33-77cb-4159-bd3a-d3a8f9a9e1cb' then 'My Why'
              when ${group_id_new} = '8c53d9a2-2467-4cb9-8a14-1296085fcaf7' then 'Academia'
              when ${group_id_new} = 'a2671644-cc94-499c-85cd-d14870aad0ea' then 'Se remettre sur la bonne voie'
              when ${group_id_new} = '7f125194-14ec-411b-9369-5116a82ace3b' then 'Jardinage'
              when ${group_id_new} = 'e9145864-d124-4720-8b13-859018ded2f1' then 'Achtsamkeit'
              when ${group_id_new} = '718d1e95-84b4-4d04-8832-a5b0c94d1eff' then 'Fietsen'
              when ${group_id_new} = '44f29671-5fe0-4dab-a317-a87d605592e3' then 'Vegetarisch'
              when ${group_id_new} = '53430d0c-438d-4c7d-abec-6d5a74dd7035' then 'En famille'
              when ${group_id_new} = '8af2e67b-2742-4092-9ef6-f2fc850ca59a' then 'Turtle Club'
              when ${group_id_new} = '94421a9f-114a-4af6-b9af-b7f063cba2fc' then 'Craft Corner'
              when ${group_id_new} = '9ca40a57-dc66-4f73-9b6b-7ebfd17e7979' then 'Walking'
              when ${group_id_new} = 'bd620f26-273a-48c8-a8e8-6e480ea913bb' then 'Meal Prep'
              when ${group_id_new} = 'c4cf9e38-fcf2-491c-a722-a755e0886ab8' then 'Maintaining'
              when ${group_id_new} = 'f421dc3e-9091-4de7-83d0-33815266e7aa' then 'Yoga / Pilates et cie'
              when ${group_id_new} = '1afef7c5-e867-4e6a-891f-2a7c1ca972bc' then 'Back on Track'
              when ${group_id_new} = 'b8c6ee3c-c08a-4693-9c66-b27530cca6ca' then 'Newbies'
              when ${group_id_new} = 'bc33dd33-83eb-405d-adfb-d5fb7fc510a6' then 'Marche'
              when ${group_id_new} = '7483eedb-5ac8-4c93-b373-2ddfebe8bd56' then 'Mamas unter sich'
              when ${group_id_new} = 'a596a353-65f0-4abc-9485-38bd0bc5774d' then 'Vegan'
              when ${group_id_new} = '0a9a1fb5-9c3c-4b8c-a2d3-1c6292909136' then 'Laufen'
              when ${group_id_new} = 'a9c78002-3999-4c0c-862b-53be46a03589' then 'Vegan'
              when ${group_id_new} = '8da8838a-8376-475a-9668-9c7fbcf999c3' then 'Over 50 and Fabulous'
              when ${group_id_new} = '2e23884d-c315-4841-bfd6-ceac5fa1dc95' then 'Grooms'
              when ${group_id_new} = '5a67ff54-64fc-484e-a9c4-c531b1e01272' then 'Foodies'
              when ${group_id_new} = '70a60962-6460-4354-9790-237dc86f52be' then 'Vegetarian'
              when ${group_id_new} = 'b0ba67ae-e6ff-4bdf-bd95-7c05d98dc438' then 'Team slak'
              when ${group_id_new} = '2ec112d5-5d92-4892-9b5e-6163000d47af' then 'Maintaining'
              when ${group_id_new} = '3d75f614-e90f-42b8-a32e-7ea28b7a7b5b' then 'Mums'
              when ${group_id_new} = '908f8a65-3fb1-4fe5-8d67-103c72700f5c' then 'Proferences alimentaires'
              when ${group_id_new} = 'a81aa3f8-ff3b-4b59-b39a-a4faa78ab0cb' then 'Over 50 and Fabulous'
              when ${group_id_new} =  '81675bab-5a08-4afa-b6dd-265813ade60f' THEN 'Recipes'
              when ${group_id_new} =  '7f56e262-b062-4729-b99b-634b7edd7113' THEN 'Newbies'
              when ${group_id_new} =  '34066c5c-c28f-4910-aa72-946b787ce45a' THEN 'Recepten delen'
              when ${group_id_new} =  '09c2ddfe-62bd-4a04-bf93-ba77d7a3c6b3' THEN 'Partager des recettes'
              when ${group_id_new} =  '30708ba0-f910-4ff7-8ffb-1a667d310bba' THEN 'Nieuwe leden'
              when ${group_id_new} =  'f257942e-dc6b-47ce-b801-6ce512f0790d' THEN 'Hardlopen'
              when ${group_id_new} =  '1f0c2255-8914-4f65-aa78-3ca782536cc8' THEN 'Nieuwe moeders'
              when ${group_id_new} =  '1f72d33e-aaef-47d2-8050-c17f8434c4af' THEN 'Stabiliseren'
               when ${group_id_new} =  '1018889a-9b00-442a-8443-24f85a6cf85c' THEN 'Sportschool'
               when ${group_id_new} =  '447fac0b-0b11-4e44-878c-1c4904dfa68b' THEN '60+'
               when ${group_id_new} =  'b0ba67ae-e6ff-4bdf-bd95-7c05d98dc438' THEN 'Team slak'
               when ${group_id_new} =  '8e1688dc-c1d1-44b2-bf3e-f9b48a1612a2' THEN 'Fietsen'
                when ${group_id_new} =  '0058ad3b-06cd-4758-9dd4-0e886a092ded' THEN 'New to Activity'
                  when ${group_id_new} =  '03849453-b810-4acb-9d38-573549c7f88a' THEN 'Turtle Club'
                when ${group_id_new} =  '0a14dde6-402f-4bfa-91d3-ca8274b0f201' THEN 'In My 20s'
                when ${group_id_new} =  '21968ac7-336f-44b2-a522-292f4d091117' THEN 'Foodies'
                when ${group_id_new} =  '322ebe16-a251-4089-8443-d5d00ca0fdec' THEN 'Living with Pets'
            when ${group_id_new} =  '0a9a1fb5-9c3c-4b8c-a2d3-1c6292909136' THEN 'Laufen'
            when ${group_id_new} =  '0e0d0164-6e2d-4c9f-850a-eea25063aa34' THEN 'Meal Prep'
            when ${group_id_new} =  '1810c72e-f945-4317-bcb9-f00b4f30d455' THEN 'Yoga'
            when ${group_id_new} =  '2a7e1993-e0f4-487a-bcac-666d8def707a' THEN 'Blau ist das Ziel'
            when ${group_id_new} =  '355ca630-cac2-44aa-b015-ab5b914dfa79' THEN 'Mamas unter sich'
            when ${group_id_new} =  '44f29671-5fe0-4dab-a317-a87d605592e3' THEN 'Vegetarisch'
            when ${group_id_new} =  '9a279cd1-12e4-4a1b-a116-269838c28485' THEN 'Singles'
            when ${group_id_new} =  'cf3b3606-d2a5-4631-807b-480864145da2' THEN 'Sleep'
            when ${group_id_new} =  '2e7b3343-2152-40be-adbe-90ddd7d2ba87' THEN 'Recepten delen'
            when ${group_id_new} =  'd4e1c9ce-038e-48d4-84b1-2727534d20bc' THEN 'Nieuwe leden'
            when ${group_id_new} =  '87a20d02-0fe9-4639-a026-c46db53e9df6' THEN 'Meal Preppen'
            when ${group_id_new} =  'd19cc6a6-f37f-4314-8b82-1472272faa8b' THEN 'Wandelen'
              ELSE ${group_id_new}
              END ;;
}


  measure: my_day_users {
    type: sum
  }

  measure: iaf_copyLink_desktop {
    type: sum
  }

  measure: iaf_sendEmail_desktop {
    type: sum
  }

  measure: groups_users {
    type: sum
  }
  measure: transactions_count {
    view_label: "Session"
    label: "Session Transactions Count"
    type: sum
  }
  measure: unique_prospects {
    view_label: "Session"
    label: "Unique Prospects"
    type: sum
  }
  measure: unique_funnel_prospects {
    view_label: "Session"
    label: "Unique Funnel Prospects"
    type: sum
  }
  measure: unique_visitors {
    view_label: "Session"
    label: "Unique Visitors"
    type: sum
  }
  measure: sus1_visitors {
    view_label: "Session"
    label: "SUS1 Visitors"
    type: sum
  }
  measure: homepage_visitors {
    view_label: "Session"
    label: "Homepage Visitors"
    type: sum
  }
  measure: homepage_prospect_visitors {
    view_label: "Session"
    label: "Homepage Prspect Visitors"
    type: sum
  }
  measure: count_sessions_event1 {
    view_label: "Funnel Growth Dashboard"
    label: "Sign up Step 1"
    type: sum
  }
  measure: count_sessions_event12 {
    view_label: "Funnel Growth Dashboard"
    label: "Registration"
    description: "Only includes sessions which also completed event 1"
    type: sum
  }
  measure: count_sessions_event123 {
    view_label: "Funnel Growth Dashboard"
    label: "Payment"
    description: "Only includes sessions which also completed events 1 and 2"
    type: sum
  }
  measure: count_sessions_event1234 {
    view_label: "Funnel Growth Dashboard"
    label: "Review"
    description: "Only includes sessions which also completed events 1, 2 and 3"
    type: sum
  }
  measure: count_sessions_event12345 {
    view_label: "Funnel Growth Dashboard"
    label: "Confirmation"
    description: "Only includes sessions which also completed events 1, 2, 3 and 4"
    type: sum
  }
  measure: unique_invited_visitors {
    type: sum
    view_label: "Invited Visitors"
  }

  measure: iaf_myDay_users_desktop {
    view_label: "Session"
    label: "My Day Desktop Users"
    type: sum
  }

  measure: numVisitsConverting {
    view_label: "Session"
    label: "Average Visits before Signup"
    type: average
  }

}

view: ga_iaf_weekly {
  view_label: "Weekly Invite A Friend Summary"
  derived_table: {
    datagroup_trigger: weekly_cache
    explore_source: ga_sessions {
      timezone: "America/New_York"
      column: visitStart_week {}
      column: market {}
      column: is_google_analytics { field: device.is_google_analytics }
      column: is_weightwatchers { field: first_page.is_weightwatchers }
      column: homepage_prospect_visitors {}
      column: deviceCategory { field: device.deviceCategory }
      column: unique_visitors {}
      column: transactions_count { field: totals.transactions_count }
      column: unique_invited_visitors { field: invited_users.unique_visitors }
      column: unique_funnel_prospects {field:invited_users.unique_funnel_prospects}
      filters: {
        field: ga_sessions.partition_date
        value: "70 weeks ago for 70 weeks"
#         value: "1 weeks ago for 1 weeks"
      }
      filters: {
        field: ga_sessions.visitStart_week
        value: "70 weeks ago for 70 weeks"
#           value: "1 weeks ago for 1 weeks"
      }
      filters: {
        field: invited_users.partition_date
        value: "70 weeks ago for 70 weeks"
        # value: "1 weeks ago for 1 weeks"
      }

    }
  }
  dimension: visitStart_week {
    view_label: "Session"
    label: "Visit Start Week"
    type: date_week
    convert_tz: no
  }
  dimension: market {
    view_label: "Session"
    label: "Market"
  }
  dimension: is_google_analytics {
    view_label: "Session"
    label: "Device Is Google Analytics"
    type: yesno
  }
  dimension: is_weightwatchers {
    view_label: "Session:First Page Visited"
    label: "Is weightwatchers.com"
    type: yesno
  }
  dimension: deviceCategory {
    view_label: "Session"
    label: "Device Category"
  }
  measure: transactions_count {
    view_label: "Session"
    label: "Session Transactions Count"
    type: sum
  }
  measure: unique_invited_visitors {
    type: sum
    view_label: "Invited Visitors"
  }
  measure: unique_funnel_prospects {
    type: sum
    view_label: "Invited Visitors"
  }
}

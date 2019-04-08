view: new_autobanned_comments {
  derived_table: {
    persist_for: "127 hours"
    sql:
  SELECT DISTINCT
week_date as week,
(CASE WHEN regexp_contains(word , '^harassing$|^harassed$|^trolls$|^harass$|^troll$|^gomi$|^tolerated$|^gofundme$|^tolerate$|^a\b$/b$$|^fuhrer$|^threatened$|^fucking$|^suicide$|^fucker$|^ssn$|^fascist$|^sexist$|^fascism$|^sex$|^facist$|^retard$|^facism$|^racist$|^dwlz$|^racial$|^diuretics$|^prostitute$|^dietbet$|^promo$|^dictator$|^petition$|^dick$|^oppressor$|^cunt$|^objectionable$|^coupon$|^Nazism$|^consensual$|^motherfucking$|^code$|^login$|^cock$|^impersonation$|^censorship$|^hater$|^censor$|^harassment$|^bullying$|^trolling$|^bully$|^threatening$|^bulimia$|^stalk$|^bulemia$|^sexism$|^bitchface$|^rape$|^bitch$|^r\b+f$|^bilemia$|^privacy$|^belimia$|^oppressive$|^bbb$|^nazi$|^asshole$|^lawsuit$|^ass$|^hateful$|^anorexic$|^tolerating$|^anorexia$|^slut$|^annorexic$|^racism$|^annorexia$|^opressed$|^annerexic$|^motherfucker$|^annerexia$|^tyrant$|^anerexic$|^retarded$|^anerexia$|^nonconsensual$|^abusive$|^threaten$|^abuser$|^hooker$|^abused$|^promotion$|^abuse$')
    then also_subquery.word
      wheN regexp_contains(two_words, '^time only$|^built bars$|^punched me$|^cut myself$|^bitch face$|^customer service$|^rodan\b+fields$|^I\'m selling$|^time offer$|^hit me$|^national socialism$|^her consent$|^been cutting$|^choked me$|^beachbody coach$|^security number$|^my consent$|^cant log$|^attorney general$|^cannot log$|^my code$|^buy my$|^ass hole$|^scroll past$|^fuck you$|^scroll on$|^find him$|^cyber bullying$|^find her$|^customer care$|^fat pig$|^hit me$|^rodan and$|^he hit$|^rodan \b+$|^cannot track$|^mindy grossman$|^business bureau$|^sexy time$|^non consensual$|^log in$|^slapped me$|^am selling$|^cant track$|^domestic abuse$|^not track$|^spark people$|^class action$|^their consent$|^cut me$|^im selling$|^can\'t track$|^identity theft$')
      then also_subquery.two_words
      END) as word ,
COUNT(DISTINCT(CASE WHEN ( also_subquery.row_rank =1 and also_subquery.flagged_count is null AND also_subquery.is_invisible is true and also_subquery.flagged IS TRUE) THEN also_subquery.post_id END)) AS auto_nomanageraction,
COUNT(DISTINCT(CASE WHEN (also_subquery.row_rank =1 and  also_subquery.flagged_count is null AND also_subquery.is_invisible is true and also_subquery.flagged IS FALSE) THEN also_subquery.post_id END)) AS auto_banned ,
COUNT(DISTINCT(CASE WHEN ((also_subquery.row_rank=1 and also_subquery.flagged_count BETWEEN 1 AND 20) AND also_subquery.flagged IS TRUE) THEN also_subquery.post_id END)) as report_nomanageraction ,
COUNT(DISTINCT(CASE WHEN ((also_subquery.row_rank=1 and also_subquery.flagged_count>0) AND (also_subquery.is_invisible is FALSE) and (also_subquery.flagged IS FALSE)) THEN also_subquery.post_id END)) as reported_approved ,
COUNT(DISTINCT(CASE WHEN ((also_subquery.row_rank=1 and also_subquery.flagged_count BETWEEN 1 and 20) AND (also_subquery.is_invisible is true) and (also_subquery.flagged IS FALSE)) THEN also_subquery.post_id END)) AS reported_banned,
COUNT(DISTINCT(CASE WHEN ( also_subquery.row_rank=1 and also_subquery.flagged_count>20 AND also_subquery.is_invisible is true and also_subquery.flagged IS TRUE) THEN also_subquery.post_id END))  as reported20_nomanageraction,
COUNT(DISTINCT(CASE WHEN (also_subquery.row_rank=1 and also_subquery.flagged_count>20 AND also_subquery.is_invisible is true and also_subquery.flagged IS FALSE) THEN also_subquery.post_id END))  as reported20_managerban,
COUNT(DISTINCT (CASE WHEN (also_subquery.row_rank = 1 and also_subquery.flagged_count is null and also_subquery.is_invisible is FALSE AND also_subquery.flagged is TRUE) then also_subquery.post_id END)) AS actionneeded_noaction,
COUNT(DISTINCT (CASE WHEN (also_subquery.row_rank=1 AND also_subquery.flagged_count is null and also_subquery.is_invisible IS FALSE AND also_subquery.flagged is FALSE) THEN also_subquery.post_id END)) as not_reported_orflagged,
count(distinct also_subquery.post_id) as total_posts
from
(
SELECT DISTINCT
  post_id,
  word,
  two_words,
  full_content,
  flagged,
  flagged_count,
  is_invisible,
  date_created,
  row_rank
  FROM
    (
    SELECT
    payload_comment.uuid AS post_id,
    payload_comment.content as full_content,
    REGEXP_EXTRACT_ALL(LOWER(payload_comment.content), r'[a-z][a-z][a-z]+\'?[a-z]?') one_words,
    REGEXP_EXTRACT_ALL(LOWER(payload_comment.content), r'[a-z][a-z][a-z]+\'?[a-z]?[ ][a-z][a-z][a-z]+\'?[a-z]?') two_words,
    payload_comment.flagged AS flagged,
    payload_comment.flags_count AS flagged_count,
    payload_comment.invisible AS is_invisible,
    extract(date from payload_comment.created_at) as date_created,
    payload_comment.updated_at  AS date_updated,
    ROW_NUMBER() OVER(PARTITION BY payload_comment.uuid  order by payload_comment.updated_at desc ) as row_rank
    FROM `wwi-datalake-1.wwi_events_pond.connect_Comment`
    WHERE payload_comment.is_deleted IS FALSE
    AND payload_comment.created_at  > TIMESTAMP('2018-11-19 00:00:01')
    and payload_comment.user.locale = 'en-US'
    #and headers_action = 'Update'
    #AND payload_post.uuid = '928d9c1d-e3e8-46f8-a93a-c4f38b948f8a'
    ) subquery  , UNNEST(one_words) word, unnest(two_words) two_words
    #WHERE post_id = '240320da-cb28-40d5-92f2-678f34b65e97'
    #WHERE post_id = 'f36ddca9-7001-4038-a1c1-d8b52aeff8f7'
  WHERE regexp_contains(word , '^harassing$|^harassed$|^trolls$|^harass$|^troll$|^gomi$|^tolerated$|^gofundme$|^tolerate$|^a\b$/b$$|^fuhrer$|^threatened$|^fucking$|^suicide$|^fucker$|^ssn$|^fascist$|^sexist$|^fascism$|^sex$|^facist$|^retard$|^facism$|^racist$|^dwlz$|^racial$|^diuretics$|^prostitute$|^dietbet$|^promo$|^dictator$|^petition$|^dick$|^oppressor$|^cunt$|^objectionable$|^coupon$|^Nazism$|^consensual$|^motherfucking$|^code$|^login$|^cock$|^impersonation$|^censorship$|^hater$|^censor$|^harassment$|^bullying$|^trolling$|^bully$|^threatening$|^bulimia$|^stalk$|^bulemia$|^sexism$|^bitchface$|^rape$|^bitch$|^r\b+f$|^bilemia$|^privacy$|^belimia$|^oppressive$|^bbb$|^nazi$|^asshole$|^lawsuit$|^ass$|^hateful$|^anorexic$|^tolerating$|^anorexia$|^slut$|^annorexic$|^racism$|^annorexia$|^opressed$|^annerexic$|^motherfucker$|^annerexia$|^tyrant$|^anerexic$|^retarded$|^anerexia$|^nonconsensual$|^abusive$|^threaten$|^abuser$|^hooker$|^abused$|^promotion$|^abuse$')
   OR regexp_contains(two_words, '^time only$|^built bars$|^punched me$|^cut myself$|^bitch face$|^customer service$|^rodan\b+fields$|^I\'m selling$|^time offer$|^hit me$|^national socialism$|^her consent$|^been cutting$|^choked me$|^beachbody coach$|^security number$|^my consent$|^cant log$|^attorney general$|^cannot log$|^my code$|^buy my$|^ass hole$|^scroll past$|^fuck you$|^scroll on$|^find him$|^cyber bullying$|^find her$|^customer care$|^fat pig$|^hit me$|^rodan and$|^he hit$|^rodan \b+$|^cannot track$|^mindy grossman$|^business bureau$|^sexy time$|^non consensual$|^log in$|^slapped me$|^am selling$|^cant track$|^domestic abuse$|^not track$|^spark people$|^class action$|^their consent$|^cut me$|^im selling$|^can\'t track$|^identity theft$')
    ) also_subquery
INNER JOIN
unnest(GENERATE_DATE_ARRAY('2018-11-18', '2019-12-31', INTERVAL 1 week)) as week_date
ON (EXTRACT(week from date_created) = extract(week from week_date)
    AND EXTRACT(year from date_created) = extract(year from week_date))
GROUP BY 1,2;;
}
  dimension_group: week  {
    timeframes: [week,week_of_year,raw,date]
    type:  time
    datatype: datetime
    convert_tz: no
    sql: timestamp(${TABLE}.week) ;;
  }

  dimension: word {
    type: string
    sql: ${TABLE}.word ;;
  }

  measure: auto_nomanageraction_comments {
    type: sum
    sql: ${TABLE}.auto_nomanageraction ;;
  }
  measure: autobanned_and_banned_comments {
    type: sum
    sql: ${TABLE}.auto_banned ;;
  }
  measure: report_nomanageraction_comments{
    type: sum
    sql: ${TABLE}.report_nomanageraction ;;
  }
  measure: reported_approved_comments {
    type: sum
    sql: ${TABLE}.reported_approved ;;
  }
  measure: reported_banned_comments {
    type: sum
    sql: ${TABLE}.reported_banned ;;
  }
  measure: reported20_nomanageraction_comments {
    type: sum
    sql: ${TABLE}.reported20_nomanageraction ;;
  }
  measure: reported20_banned_comments {
    type: sum
    sql: ${TABLE}.reported20_managerban ;;
  }
  measure: actionneeded_noaction_comments {
    type: sum
    sql: ${TABLE}.actionneeded_noaction ;;
  }
  measure: not_reported_orflagged_comments {
    type: sum
    sql: ${TABLE}.not_reported_orflagged ;;
  }
  measure: total_comments {
    type: sum
    sql: ${TABLE}.total_posts;;
  }
}

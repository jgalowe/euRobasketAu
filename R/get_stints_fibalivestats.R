get_stints_fibalivestats = function(gameid) {
  
  #Load play by play
  pbp = get_raw_pbp_fibalivestats(gameid)
  
  #Load starting lineups
  url_s5 = paste('http://www.fibalivestats.com/data/',gameid,'/data.json', sep = '')
  starting_5s = fromJSON(url_s5)
  
  #get teams names
  home_team_name = starting_5s$tm$`1`$name
  away_team_name = starting_5s$tm$`2`$name
  
  #home starters
  home_s5 = c()
  for(i in 1:length(starting_5s$tm$`1`$pl)) {
    if(starting_5s$tm$`1`$pl[[i]]$starter==1) {
      starter = starting_5s$tm$`1`$pl[[i]]$name
      home_s5 = c(home_s5, starter)
    }
  }
  
  #away starters
  away_s5 = c()
  for(i in 1:length(starting_5s$tm$`2`$pl)) {
    if(starting_5s$tm$`2`$pl[[i]]$starter==1) {
      starter = starting_5s$tm$`2`$pl[[i]]$name
      away_s5 = c(away_s5, starter)
    }
  }
  
  #create data frame with substitutions
  
  #extract rows numbers when substitution starts, subType == 'in'
  subs_in_rows = as.numeric(rownames(pbp[pbp$actionType == 'substitution' & pbp$subType == 'in',]))
  
  subs_out_rows = as.numeric(rownames(pbp[pbp$actionType == 'substitution' & pbp$subType == 'out',]))
  
  subs = data.frame(row_in = subs_in_rows,
                    row_out = subs_out_rows)
  
  #check if subs$row_out subType is 'out', filter out sub of true
  #subs = subs[which(pbp$subType[subs$row_out]=='out'),]
  
  #add player in, player out and team
  subs$player_in = pbp$player[subs$row_in]
  subs$player_out = pbp$player[subs$row_out]
  subs$team = pbp$tno[subs$row_in]
  
  #some substitutions happens on the same time, so it's needed create a unique id for each 'group' of substitutions
  subs$sub_group = NA
  subs$sub_group[1] = 1
  
  for(i in 2:(nrow(subs))) {
    row_diff = subs$row_in[i] - subs$row_in[i-1]
    if(row_diff == 2) {
      subs$sub_group[i] = subs$sub_group[i-1]
    } else {
      subs$sub_group[i] = subs$sub_group[i-1]+1
    }
  }
  
  
  #create data.frame with players on court
  players_on_court = data.frame(cbind(t(home_s5), t(away_s5)), stringsAsFactors = FALSE)
  
  names(players_on_court) = c('home_P1',
                              'home_P2',
                              'home_P3',
                              'home_P4',
                              'home_P5',
                              'away_P1',
                              'away_P2',
                              'away_P3',
                              'away_P4',
                              'away_P5')
  
  #function for stints data
  get_stint_data = function(start_row, end_row) {
    
    #subset stint with start_row and end_row
    stint = pbp[start_row:end_row,]
    stint = stint[!is.na(stint$team_short_name),]
    
    #subset home actions and away actions
    home_actions = stint[which(stint$tno == 1),]
    away_actions = stint[which(stint$tno == 2),]
    
    #calculate actions types for home team
    
    #assists
    home_assists = nrow(home_actions[which(home_actions$actionType == 'assist'),])
    
    #scoring
    #2pt
    home_2pt = home_actions[which(home_actions$actionType == '2pt'),]
    home_2pt_fga = nrow(home_2pt)
    home_2pt_fgm = nrow(home_2pt[which(home_2pt$success == 1),])
    `home_2pt_fg%` = round((home_2pt_fgm/home_2pt_fga),2)
    
    #points at the rim
    home_patr = home_actions[home_actions$subType ==  "layup"|home_actions$subType ==  "drivinglayup"|home_actions$subType == "dunk",]
    home_patr_a = nrow(home_patr)
    home_patr_m = nrow(home_patr[which(home_patr$success == 1),])
    `home_patr_fg%`= round((home_patr_m/home_patr_m),2)
    
    #3pt
    home_3pt = home_actions[which(home_actions$actionType == '3pt'),]
    home_3pt_fga = nrow(home_3pt)
    home_3pt_fgm = nrow(home_3pt[which(home_3pt$success == 1),])
    `home_3pt_fg%`= round((home_3pt_fgm/home_3pt_fga),2)
    
    #free throws
    home_fts = home_actions[which(home_actions$actionType == 'freethrow'),]
    home_fta = nrow(home_fts)
    home_ftm = nrow(home_fts[which(home_fts$success == 1),])
    `home_ft%` = round((home_ftm/home_fta),2)
    
    #turnovers
    home_tovs = nrow(home_actions[which(home_actions$actionType == 'turnover'),])
    
    #rebounds
    home_rebs = home_actions[which(home_actions$actionType == 'rebound'),]
    home_orebs = nrow(home_rebs[which(home_rebs$subType == 'offensive'),])
    home_drebs = nrow(home_rebs[which(home_rebs$subType == 'defensive'),])
    
    #steals
    home_steals = nrow(home_actions[which(home_actions$actionType == 'steal'),])
    
    #blocks
    home_blocks = nrow(home_actions[which(home_actions$actionType == 'block'),])
    
    #pts scored home
    home_pts = (home_2pt_fgm*2) + (home_3pt_fgm*3) + home_ftm
    
    #turnover types
    home_ballhandling = nrow(home_actions[home_actions$subType ==  "ballhandling"|home_actions$subType == "doubledribble"|home_actions$subType == "travel",])
    home_badpass = nrow( home_actions[home_actions$subType ==  "badpass",])
    home_oFoul = nrow(home_actions[home_actions$subType ==  "offensive",])
    home_3sec =nrow( home_actions[home_actions$subType ==  "3sec",])
    home_8sec = nrow(home_actions[home_actions$subType ==  "8sec",])
    home_24sec = nrow(home_actions[home_actions$subType ==  "24sec",])
    
    
    
    #create data.frame with actions
    home = data.frame(cbind(
      home_pts,
      home_2pt_fgm,
      home_2pt_fga,
      `home_2pt_fg%`,
      home_patr_m,
      home_patr_a,
      `home_patr_fg%`,
      home_3pt_fgm,
      home_3pt_fga,
      `home_3pt_fg%`,
      home_ftm,
      home_fta,
      `home_ft%`,
      home_drebs,
      home_orebs,
      home_assists,
      home_tovs,
      home_steals,
      home_blocks,
      home_ballhandling,
      home_badpass,
      home_oFoul,
      home_3sec,
      home_8sec,
      home_24sec))
    
    #calculate home possesions
    home$home_possesions = ((home$home_2pt_fga+home$home_3pt_fga) + home$home_tovs + (0.44*home$home_fta) - home$home_orebs)
    home$home_possesions[home$home_possesions < 0] = 0
    
    #calculate actions types for away team
    
    #assists
    away_assists = nrow(away_actions[which(away_actions$actionType == 'assist'),])
    
    #scoring
    #2pt
    away_2pt = away_actions[which(away_actions$actionType == '2pt'),]
    away_2pt_fga = nrow(away_2pt)
    away_2pt_fgm = nrow(away_2pt[which(away_2pt$success == 1),])
    `away_2pt_fg%` = round((away_2pt_fgm/away_2pt_fga),2)
    
    #points at the rim
    away_patr = away_actions[away_actions$subType ==  "layup"|away_actions$subType ==  "drivinglayup"|away_actions$subType == "dunk",]
    away_patr_a = nrow(away_patr)
    away_patr_m = nrow(away_patr[which(away_patr$success == 1),])
    `away_patr_fg%`= round((away_patr_m/away_patr_m),2)
    
    #3pt
    away_3pt = away_actions[which(away_actions$actionType == '3pt'),]
    away_3pt_fga = nrow(away_3pt)
    away_3pt_fgm = nrow(away_3pt[which(away_3pt$success == 1),])
    `away_3pt_fg%`= round((away_3pt_fgm/away_3pt_fga),2)
    
    #free throws
    away_fts = away_actions[which(away_actions$actionType == 'freethrow'),]
    away_fta = nrow(away_fts)
    away_ftm = nrow(away_fts[which(away_fts$success == 1),])
    `away_ft%` = round((away_ftm/away_fta),2)
    
    #turnovers
    away_tovs = nrow(away_actions[which(away_actions$actionType == 'turnover'),])
    
    #rebounds
    away_rebs = away_actions[which(away_actions$actionType == 'rebound'),]
    away_orebs = nrow(away_rebs[which(away_rebs$subType == 'offensive'),])
    away_drebs = nrow(away_rebs[which(away_rebs$subType == 'defensive'),])
    
    #steals
    away_steals = nrow(away_actions[which(away_actions$actionType == 'steal'),])
    
    #blocks
    away_blocks = nrow(away_actions[which(away_actions$actionType == 'block'),])
    
    #pts scored away
    away_pts = (away_2pt_fgm*2) + (away_3pt_fgm*3) + away_ftm
    
    #turnover types
    away_ballhandling = nrow(away_actions[away_actions$subType ==  "ballhandling"|away_actions$subType == "doubledribble"|away_actions$subType == "travel",])
    away_badpass = nrow( away_actions[away_actions$subType ==  "badpass",])
    away_oFoul = nrow(away_actions[away_actions$subType ==  "offensive",])
    away_3sec =nrow( away_actions[away_actions$subType ==  "3sec",])
    away_8sec = nrow(away_actions[away_actions$subType ==  "8sec",])
    away_24sec = nrow(away_actions[away_actions$subType ==  "24sec",])
    
    #create data.frame with actions
    away = data.frame(cbind(
      away_pts,
      away_2pt_fgm,
      away_2pt_fga,
      `away_2pt_fg%`,
      away_patr_m,
      away_patr_a,
      `away_patr_fg%`,
      away_3pt_fgm,
      away_3pt_fga,
      `away_3pt_fg%`,
      away_ftm,
      away_fta,
      `away_ft%`,
      away_drebs,
      away_orebs,
      away_assists,
      away_tovs,
      away_steals,
      away_blocks,
      away_ballhandling,
      away_badpass,
      away_oFoul,
      away_3sec,
      away_8sec,
      away_24sec))
    
    #calculate away possesions
    away$away_possesions = ((away$away_2pt_fga+away$away_3pt_fga) + away$away_tovs + (0.44*away$away_fta) - away$away_orebs)
    away$away_possesions[away$away_possesions < 0] = 0
    #combine home and away
    stint_data = cbind(home, away)
    
    #NaNs to 0
    stint_data[stint_data == 'NaN'] = 0
    
    return(stint_data)
  }
  
  #create stints data.frame
  #first row
  first_row_start = 1
  first_row_end = subs$row_in[1]-1
  stints.df = cbind(players_on_court, get_stint_data(first_row_start, first_row_end))
  
  
  
  #loop for all other substitutions
  for(i in 1:max(subs$sub_group)) {
    #get players on court before substitution
    players_on_court = stints.df[i, 1:10]
    
    #make substitutions
    subs_to_make = subs[subs$sub_group == i,]
    
    for(j in 1:nrow(subs_to_make)) {
      
      sub = subs_to_make[j,]
      if(sub$team == 1) {
        players_on_court[1:5][grep(sub$player_out, players_on_court[1:5],ignore.case = TRUE)] = sub$player_in
      } else if(sub$team == 2) {
        players_on_court[6:10][grep(sub$player_out, players_on_court[6:10],ignore.case = TRUE)] = sub$player_in
      }
    }
    
    #cbind players on court after substitutions with actions
    
    if(i != max(subs$sub_group)) {
      
      stints.df[i+1,] = cbind(players_on_court,
                              get_stint_data(start_row = min(subs_to_make$row_in),
                                             end_row = (min(subs$row_in[subs$sub_group == i+1])-1)))
      
    } else if(i == max(subs$sub_group)) {
      
      stints.df[i+1,] = cbind(players_on_court,
                              get_stint_data(start_row = min(subs_to_make$row_in),
                                             end_row = nrow(pbp)))
      
    }
    
  }
  stints.df= stints.df[, c(1:10, 45, 46, 47,48,49, 11:44,50:62)]
  stints.df$home_team = home_team_name
  stints.df$away_team = away_team_name
  return(stints.df)
}

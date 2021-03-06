% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_team_stats_realgm.R
\name{get_team_stats_realgm}
\alias{get_team_stats_realgm}
\title{Load team stats from realgm.com}
\usage{
get_team_stats_realgm(league, season, type, split = "Team_Totals")
}
\arguments{
\item{league}{character, league name from realgm.com, you can find all
available names using get_realgm_league_names()}

\item{season}{numeric, second year of season, ie. for season 2016-17 use 2017,
for season 2013-14 use 2014}

\item{type}{character, type of stats to download, choose from:
Totals, Averages, Per_48, Per_40, Per_36, Per_Minute,
Minute_Per, Misc_Stats, Advanced_Stats}

\item{split}{character, 'Team_Totals' set by default, choose from:
Team_Totals, Team_Starters, Team_Bench,
Opponent_Totals, Opponent_Starters, Opponent_Bench}
}
\value{
data frame with team stats
}
\description{
Load different types of team stats for chosen league and season
from realgm.com. You need to specify league name, season and stats type.
}
\examples{

#Load Advanced Stats for Spanish ACB Teams, season 2014-15
get_team_stats_realgm('Spanish ACB', 2015, type = 'Advanced_Stats')

#Load Totals for British BBL teams, season 2015-16,
#use 'Opponent Starters as a split
get_team_stats_realgm('British BBL', 2016, type = 'Totals', split = 'Opponent_Starters')
}

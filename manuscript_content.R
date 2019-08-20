# Script Summary
#   Generate figures to be included in the journal submission
#
# Map of Alaska showing station locations
#
# Example of wind speed time series before and after adjustment
#
# Quantile mapping ECDF 
# 
# Sample time series of winds during specific events
#
# Checkerboard ttest results
#
# Output files:
#   /figures/manuscript/AK_ASOS_station_locations.pdf
#   /figured/manuscript/asos_discont_adj_ex.pdf



#-- Setup ---------------------------------------------------------------------
workdir <- getwd()
datadir <- file.path(workdir, "data")
figdir <- file.path(workdir, "figures", "manuscript")
code_dir <- file.path(workdir, "code")

#------------------------------------------------------------------------------

#-- AK Map of Stations --------------------------------------------------------
library(dplyr)
library(lubridate)
library(ggplot2)
library(ggrepel)
library(sf)
library(USAboundaries)

# load select stations
select_stations <- readRDS(file.path(datadir, "AK_ASOS_select_stations.RDS"))
stids <- select_stations$stid
# alaska sf object
alaska <- us_states(states = "AK", resolution = "high")
ak_sf <- st_transform(alaska, 26935)
# station coordinates as sf object
coords <- as.data.frame(select_stations[, c("stid", "lon", "lat")])
coords <- st_as_sf(coords, coords = c("lon", "lat"), crs = 4326)
coords <- st_transform(coords, 26935)

# tier 2 stations coordinates as sf (commented out)
#coords_2 <- select_stations %>% 
#  filter(tier == 2) %>% 
#  select(lon, lat) %>%
#  as.data.frame()
#coords_2 <- st_as_sf(coords_2, coords = c("lon", "lat"), crs = 4326)
#coords_2 <- st_transform(coords_2, 26935)

# plot
p <- ggplot(data = ak_sf) + geom_sf(fill = "cornsilk", size = 0.25) +
  xlab("Lng") + ylab("Lat") +
  theme_bw() +
  theme(axis.text = element_text(color = "black", size = 8),
        axis.title = element_text(size = 10)) +
  geom_sf(data = coords, shape = 19, col = "darkred", size = 0.75) #+ 
#  geom_sf(data = coords_2, shape = 21, size = 2, fill = "cyan")

fig_path <- file.path(figdir, "AK_ASOS_select_locations.pdf")
ggsave(fig_path, p, device = "pdf", width = 3.54, height = 2.05)

#------------------------------------------------------------------------------

#-- Discontinuity Adjustment Time Series --------------------------------------
library(dplyr)
library(lubridate)
library(ggplot2)
library(gridExtra)
library(grid)

# select/adj data summarized by month
monthly_adj_path <- file.path(datadir, 
                              "AK_ASOS_monthly_select_adj_19800101_to_20150101.Rds")
asos_monthly <- readRDS(monthly_adj_path)
# changepoints
asos_adj_dir <- file.path(datadir, "AK_ASOS_stations_adj")
cpts_df <- readRDS(file.path(asos_adj_dir, "cpts_df.Rds"))

# x scale to be used for both plots
date_labels <- c("1980", "1985", "1990", "1995", 
                 "2000", "2005", "2010", "2015")
date_breaks <- ymd(c("1980-01-01", "1985-01-01", "1990-01-01", "1995-01-01", 
                     "2000-01-01", "2005-01-01", "2010-01-01", "2015-01-01"))

# display time series for PAED and PAFA
stid1 <- "PADK"
asos_station1 <- asos_monthly %>% 
  filter(stid == stid1)

# changepoint info
cpts_temp1 <- cpts_df[cpts_df$stid == stid1, ]
# starting x for mean 1 horizontal line
x1_start1 <- ymd("1980-01-01")
x1_end1 <- cpts_temp1[1, 2]
x2_end1 <- ymd("2015-01-01")
m1_1 <- cpts_temp1[1, 4]
m2_1 <- cpts_temp1[1, 5]

p1 <- ggplot(asos_station1, aes(ym_date, avg_sped, group = 1)) + 
  geom_line(col = "grey") +
  xlim(ymd("1980-01-01"), ymd("2015-01-01")) + 
  scale_x_date(date_labels = date_labels, breaks = date_breaks) + 
  ggtitle("Kodiak Municipal Airport") + 
  geom_vline(xintercept = x1_start1, col = "gray50", 
             lty = 3, size = 1) + 
  geom_vline(xintercept = x2_end1, col = "gray50", 
             lty = 3, size = 1) + 
  geom_vline(xintercept = x1_end1, 
             col = "red", size = 1.5) + 
  geom_segment(aes(x = x1_start1, xend = x1_end1, y = m1_1, yend = m1_1),
               col = "blue") +
  geom_segment(aes(x = x1_end1, xend = x2_end1, y = m2_1, yend = m2_1),
               col = "blue") +
  geom_line(aes(ym_date, avg_sped_adj, group = 1)) + 
  scale_y_continuous(limits = c(5, 25), breaks = c(5, 10, 15, 20, 25)) +
  theme_bw() + 
  theme(panel.grid = element_blank(), 
        axis.title = element_blank(),
        plot.title = element_text(size = 10)) 

# second station (two discontinuities)
# display time series for PAED and PAFA
stid2 <- "PAEI"
asos_station2 <- asos_monthly %>% 
  filter(stid == stid2)

# changepoint info
cpts_temp2 <- cpts_df[cpts_df$stid == stid2, ]
# starting x for mean 1 horizontal line
x1_start2 <- ymd("1980-01-01")
x1_end2 <- cpts_temp2[1, 2]
x2_end2 <- cpts_temp2[1, 3]
x3_end2 <- ymd("2015-01-01")
m1_2 <- cpts_temp2[1, 4]
m2_2 <- cpts_temp2[1, 5]
m3_2 <- cpts_temp2[1, 6]

p2 <- ggplot(asos_station2, aes(ym_date, avg_sped, group = 1)) + 
  geom_line(col = "grey") +
  xlim(ymd("1980-01-01"), ymd("2015-01-01")) + 
  scale_x_date(date_labels = date_labels, breaks = date_breaks) + 
  ggtitle("Eielson AFB") + 
  geom_vline(xintercept = x1_start2, col = "gray50", 
             lty = 3, size = 1) + 
  geom_vline(xintercept = x3_end2, col = "gray50", 
             lty = 3, size = 1) + 
  geom_vline(xintercept = x1_end2, 
             col = "red", size = 1.5) + 
  geom_vline(xintercept = c(x1_end2, x2_end2), 
             col = "red", size = 1.5) + 
  geom_segment(aes(x = x1_start2, xend = x1_end2, y = m1_2, yend = m1_2),
               col = "blue") +
  geom_segment(aes(x = x1_end2, xend = x2_end2, y = m2_2, yend = m2_2),
               col = "blue") +
  geom_segment(aes(x = x2_end2, xend = x3_end2, y = m3_2, yend = m3_2),
               col = "blue") +
  geom_line(aes(ym_date, avg_sped_adj, group = 1)) +
  scale_y_continuous(limits = c(0, 8), breaks = c(0, 2, 4, 6, 8)) +
  theme_bw() + 
  theme(panel.grid = element_blank(),
        axis.title = element_blank(),
        axis.text.y = element_text(margin = margin(l = 5, r = 2)),
        plot.title = element_text(size = 10)) 

p <- arrangeGrob(p1, p2, nrow = 2, 
                 left = textGrob("Avg Wind Speed (mph)", 
                                 gp = gpar(fontsize = 10),
                                 rot = 90),
                 bottom = textGrob("Time", gp = gpar(fontsize = 10)))
fig_path <- file.path(figdir, "asos_discont_adj_ex.pdf")
ggsave(fig_path, p, device = "pdf", width = 7.25, height = 2.65)

#------------------------------------------------------------------------------

#-- ERA & CM3 ECDFs -----------------------------------------------------------
library(dplyr)
library(lubridate)

# ggECDF_compare modified for manuscript
ggECDF_compare <- function(obs, sim, sim_adj, p_tag = " ",
                           sim_lab, obs_lab, cols = 1){
  require(gridExtra)
  require(ggplot2)
  require(grid)
  require(wesanderson)
  
  df1 <- data.frame(sped = c(sim, obs),
                    quality = c(rep("1", length(sim)),
                                rep("2", length(obs))))
  
  df2 <- data.frame(sped = c(sim_adj, obs),
                    quality = c(rep("1", length(sim_adj)),
                                rep("2", length(obs))))
  
  # extract legend, code borrowed from SO (for sharing legend between plots)
  # https://github.com/hadley/ggplot2/wiki/Share-a-legend-between-two-ggplot2-graphs
  g_legend <- function(a.gplot){
    tmp <- ggplot_gtable(ggplot_build(a.gplot))
    leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend <- tmp$grobs[[leg]]
    return(legend)}
  
  # original data
  xmax <- quantile(obs, probs = seq(0, 1, 1/500))[500] + 5
  p1 <- ggplot(df1, aes(sped, color = quality)) + 
    stat_ecdf(size = 0.5) + 
    xlim(c(0, xmax)) + #scale_color_discrete(name = "  ", 
                        #                    labels = c(sim_lab, obs_lab)) + 
    # ggtitle(p_title) +
    # labs(tag = p_tag) +
    theme_bw() + 
    theme(legend.position = "top",
          plot.title = element_text(vjust = -1),
          axis.title = element_blank(),
          panel.grid = element_blank(),
          axis.text.x = element_text(size = 7),
          axis.text.y = element_text(size = 7),
          legend.text = element_text(size = 8),
          legend.margin = margin(-5, 0, 0, 0),
          plot.margin = unit(c(2, 2, 2, 2), "mm"))
  
  if(cols == 1){
    p1 <- p1 + scale_color_manual(values = c("#FD6467", "#F1BB7B"),
                                  name = "   ",
                                  labels = c(sim_lab, obs_lab))
  } else {
    p1 <- p1 + scale_color_manual(values = c("#5B1A18", "#FD6467"),
                                  name = "   ",
                                  labels = c(sim_lab, obs_lab))
  }

  # corrected data
  p2 <- ggplot(df2, aes(sped, color = quality)) + 
    stat_ecdf(size = 0.5) + 
    xlim(c(0, xmax))  + #ggtitle(" ") + 
    # labs(tag = "  ") +
    theme_bw() +
    theme(plot.title = element_text(vjust = -1),
          axis.title = element_blank(),
          panel.grid = element_blank(),
          axis.text = element_text(size = 7),
          plot.margin = unit(c(2, 2, 2, 2), "mm"))
  
  if(cols == 1){
    p2 <- p2 + scale_color_manual(values = c("#FD6467", "#F1BB7B"),
                                  name = "   ",
                                  labels = c(sim_lab, obs_lab))
  } else {
    p2 <- p2 + scale_color_manual(values = c("#5B1A18", "#FD6467"),
                                  name = "   ",
                                  labels = c(sim_lab, obs_lab))
  }
  
  # legend code adapted from:
  # https://github.com/hadley/ggplot2/wiki/Share-a-legend-between-two-ggplot2-graphs
  tmp <- ggplot_gtable(ggplot_build(p1))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  mylegend <- tmp$grobs[[leg]]
  
  p <- arrangeGrob(mylegend,
                   arrangeGrob(p1 + theme(legend.position = "none"),
                               p2 + theme(legend.position = "none"), 
                               nrow = 1,
                               bottom = textGrob("Wind Speed (mph)",
                                                 x = unit(0.55, "npc"),
                                                 vjust = -0.5,
                                                 gp = gpar(fontsize = 8)),
                               left = textGrob("Cumulative Probability",
                                               gp = gpar(fontsize = 8),
                                               rot = 90, hjust = 0.35)),
                   nrow = 2, heights = c(1, 40),
                   top = textGrob(p_tag,
                                  x = unit(0.05, "npc"),
                                  y = unit(0.30, "npc"), 
                                  just = c("left", "top")))
  return(p)
}

asos_dir <- file.path(datadir, "AK_ASOS_stations_adj")
asos <- readRDS(file.path(asos_dir, "PANC.Rds")) %>%
  filter(t_round < ymd("2015-01-01"))
era_dir <- file.path(datadir, "ERA_stations_adj")
era <- readRDS(file.path(era_dir, "PANC_era_adj.Rds")) %>%
  filter(ts < ymd("2015-01-01"))
cm3_dir <- file.path(datadir, "CM3_stations_adj")
cm3 <- readRDS(file.path(cm3_dir, "PANC_cm3h_adj.Rds"))

p1 <- ggECDF_compare(asos$sped_adj, era$sped, era$sped_adj + 0.5, 
                     "A", "ERA-Interim", "ASOS")

obs2 <- era$sped_adj[era$ts < ymd("2006-01-01")]
p2 <- ggECDF_compare(obs2, cm3$sped, cm3$sped_adj + 0.5,
                     "B", "CM3 Historical", "ERA-Interim", 2)

p <- arrangeGrob(p1, p2, nrow = 2)

fig_path <- file.path(figdir, "ERA_CM3_ECDFs.pdf")
ggsave(fig_path, p, dev = "pdf", width = 3.54, height = 4)

#------------------------------------------------------------------------------

#-- High Wind Events ----------------------------------------------------------
# Need John to choose a couple

#------------------------------------------------------------------------------

#-- t-test heatmap ----------------------------------------------------------
source(file.path(code_dir, "helpers.R"))

stid_names <- read.csv(file.path(datadir, "AK_ASOS_names_key.csv"),
                       stringsAsFactors = FALSE)

cm3_monthly <- readRDS(file.path(datadir, "CM3_clim_monthly.Rds"))
ccsm4_monthly <- readRDS(file.path(datadir, "CCSM4_clim_monthly.Rds"))

stations <- readRDS(file.path(datadir, "AK_ASOS_select_stations.Rds"))
stids <- stations$stid
stid_names <- stations %>% select(stid, station_name)

# CM3
cm3_ttest <- lapply(stids, t_test_stid, cm3_monthly) %>%
  bind_rows() 

# CCSM4
ccsm4_ttest <- lapply(stids, t_test_stid, ccsm4_monthly) %>%
  bind_rows() 

# t-test heatmap results function
#tHeatmap <- function(t_obj, p_mod){

cm3_sig <- cm3_ttest %>% 
  left_join(stations, by = "stid") %>%
  mutate(sig = if_else(p_val <= 0.05 & mean_x < mean_y, 
                       "Future Signif. Higher", 
                       "Future Signif. Lower"),
         sig = if_else(p_val > 0.05, "No Signif. Difference", sig),
         sig = factor(sig, levels = c("No Signif. Difference",
                                      " ",
                                      "Future Signif. Lower", 
                                      "Future Signif. Higher")),
         mo = factor(mo, levels = month.abb),
         dsrc = factor("CM3", levels = c("CM3", "CCSM4"))) %>%
  select(stid, sig, mo, dsrc)

results_df <- ccsm4_ttest %>% 
  left_join(stations, by = "stid") %>%
  mutate(sig = if_else(p_val <= 0.05 & mean_x < mean_y, 
                       "Future Signif. Higher", 
                       "Future Signif. Lower"),
         sig = if_else(p_val > 0.05, "No Signif. Difference", sig),
         sig = factor(sig, levels = c("No Signif. Difference",
                                      " ",
                                      "Future Signif. Lower", 
                                      "Future Signif. Higher")),
         mo = factor(mo, levels = month.abb),
         dsrc = factor("CCSM4", levels = c("CM3", "CCSM4"))) %>%
  select(stid, sig, mo, dsrc) %>%
  bind_rows(cm3_sig) %>%
  left_join(stid_names, by = "stid") %>%
  select(pub_name, sig, mo, dsrc)

# function to increase vertical spacing between legend keys
# @clauswilke
draw_key_polygon3 <- function(data, params, size) {
  lwd <- min(data$size, min(size) / 4)
  
  grid::rectGrob(
    width = grid::unit(0.6, "npc"),
    height = grid::unit(0.6, "npc"),
    gp = grid::gpar(
      col = data$colour,
      fill = alpha(data$fill, data$alpha),
      lty = data$linetype,
      lwd = lwd * .pt,
      linejoin = "mitre"
    ))
}

# register new key drawing function, 
# the effect is global & persistent throughout the R session
GeomTile$draw_key = draw_key_polygon3

p <- ggplot(results_df, aes(x = mo, y = reorder(pub_name, desc(pub_name)))) +
  geom_tile(aes(fill = sig, color = sig)) + 
  scale_fill_manual(values = c("White", "white", "#46ACC8", "#E58601"),
                    drop = FALSE) + 
  scale_color_manual(values = c("grey", "white", "grey", "grey"),
                     drop = FALSE) +
  scale_x_discrete(breaks = c("Jan", "Mar", "May", "Jul", "Sep", "Nov")) +
  ylab("Location") + xlab("Month") + 
  #labs(fill = "Significance\nat \u03B1 = 0.05") +
  theme_bw() + 
  theme(legend.direction = "vertical",
        legend.key.size = unit(0.6, "line"),
        legend.title = element_blank(),
        legend.margin = margin(c(0, 1, 0, 1)),
        legend.text = element_text(margin = margin(l = 3, r = 3),
                                   size = 8),
        axis.text = element_text(size = 7, color = "black"),
        axis.title = element_text(size = 8), 
        strip.background = element_blank(),
        strip.text = element_text(margin = margin(c(1, 0, 1, 0))),
        legend.key = element_rect(color = NA, fill = NA),
        legend.justification = c(0, 0),
        legend.position = "bottom") +
  guides(fill = guide_legend(ncol = 2)) +
  facet_wrap(~dsrc)

plot_path <- file.path(figdir, "wrf_clim_ttest_signif_heatmap.pdf")
ggsave(plot_path, p, device = "pdf", height = 7, width = 3.54)

#------------------------------------------------------------------------------
#Load the needed libraries
library(tidyverse)
library(maps)
library(CoordinateCleaner)
data(countryref)

#Import a world map
world <- map_data("world")

countries <- as_tibble(countryref) %>%
        distinct(name, .keep_all = TRUE) %>%
        rename(nationality = name,
               long = centroid.lon,
               lat = centroid.lat)

#Get the astronaut data set
astronauts <-
        readr::read_csv(
                'https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-07-14/astronauts.csv'
        )

#Wrangle these data
astronauts <- astronauts %>%
        select(number, name, sex, nationality) %>%
        #The names of nationalities are inconsistent with country data
        #Choose presently existing countries, fix spelling errors, and
        #otherwise make consistent
        mutate(
                nationality = if_else(nationality == "U.S.S.R/Russia", "Russia",
                                      nationality),
                nationality = if_else(nationality == "U.S.S.R/Ukraine",
                                      "Ukraine", nationality),
                nationality = if_else(nationality == "Czechoslovakia",
                                      "Czechia", nationality),
                nationality = if_else(nationality == "U.K./U.S.", "United Kingdom",
                                      nationality),
                nationality = if_else(nationality == "U.K.", "United Kingdom", nationality),
                nationality = if_else(nationality == "UAE",
                                      "United Arab Emirates", nationality),
                nationality = if_else(nationality == "Hungry", "Hungary",
                                      nationality),
                nationality = if_else(nationality == "Korea", "South Korea",
                                      nationality),
                nationality = if_else(nationality == "Malysia", "Malaysia",
                                      nationality),
                nationality = if_else(nationality == "Netherland", "Netherlands",
                                      nationality),
                nationality = if_else(
                        nationality == "Republic of South Africa",
                        "South Africa",
                        nationality
                ),
                nationality = if_else(nationality == "U.S.", "United States", nationality),
                sex = if_else(sex == "female", "Women", "Men")
        ) %>%
        distinct(number, .keep_all = TRUE) %>%
        group_by(nationality) %>%
        count(sex) %>%
        left_join(countries) %>%
        select(c(nationality, sex, n, lat, long)) %>%
        arrange(sex)

#Create visualization
ggplot() +
        #Draw world map
        geom_polygon(
                data = world,
                aes(x = long, y = lat, group = group),
                fill = "gray",
                alpha = .3
        ) +
        #Plot data
        geom_jitter(
                data = astronauts,
                aes(
                        x = long,
                        y = lat,
                        size = n,
                        fill = sex
                ),
                alpha = .7,
                shape = 21,
                color = "black",
                position = position_jitter(
                        width = 3,
                        height = 3,
                        seed = 1234
                )
        ) +
        scale_fill_manual(values = (c("Men" = "#1b9e77", "Women" = "#7570b3"))) +
        scale_size(range = c(1, 40), labels = NULL) +
        #Fix labels, etc.
        labs(
                title = "Where on Earth do Astronauts Come From?",
                subtitle = "293 out of 565 humans who have traveled to space were American men",
                caption = "Source: Mariya Stavnichuk and Tatsuya Corlett (2020)
             Data set records only binary gender",
                x = NULL,
                y = NULL,
                fill = NULL
        ) +
        theme(
                legend.position = "bottom",
                axis.text.x = element_blank(),
                axis.ticks.x = element_blank(),
                axis.text.y = element_blank(),
                axis.ticks.y = element_blank()
        ) +
        guides(size = FALSE) +
        coord_quickmap()
ggsave("images/2020-07-14-astronauts.png")

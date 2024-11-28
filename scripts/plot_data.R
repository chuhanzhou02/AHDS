options(repos = c(CRAN = "https://cloud.r-project.org"))
install.packages("topicmodels")
library(tidyverse)
library(tidytext)
library(topicmodels)
library(ggplot2)

data <- read_tsv("/home/zch/AHDS_project/clean/article_clean.tsv")
dir.create("plots", showWarnings = FALSE)

data <- data %>% 
  select(Year, Cleaned_Title) %>% 
  drop_na() %>% 
  rename(year = Year, title = Cleaned_Title)

all_words_by_year <- data %>%
  group_by(year) %>%
  summarise(text = paste(title, collapse = " "))

word_frequencies_by_year <- all_words_by_year %>%
  unnest_tokens(word, text) %>%
  filter(!word %in% stop_words) %>%
  count(year, word) %>%
  spread(key = word, value = n, fill = 0)

word_totals <- colSums(word_frequencies_by_year[-1])
top_words <- names(sort(word_totals, decreasing = TRUE))[1:10]

word_trends_top <- word_frequencies_by_year %>%
  select(year, all_of(top_words)) %>%
  gather(key = "word", value = "frequency", -year)

word_trends_top <- word_trends_top %>%
  drop_na() %>%  
  filter(frequency >= 0 & year >= 2019 & year <= 2026)  

word_order <- word_trends_top %>%
  group_by(word) %>%
  summarise(total_frequency = sum(frequency)) %>%
  arrange(desc(total_frequency)) %>%
  pull(word)

word_trends_top <- word_trends_top %>%
  mutate(word = factor(word, levels = word_order))

gg <- ggplot(word_trends_top, aes(x = year, y = frequency, color = word, group = word)) +
  geom_line(linewidth = 1.2, alpha = 0.8) +
  scale_color_viridis_d(option = "plasma", begin = 0, end = 0.9) +
  scale_x_continuous(
    breaks = seq(2019, 2026, by = 1),
    limits = c(2019, 2026)
  ) +
  labs(
    title = "Word Frequency Trends from 2019 to 2026",
    x = "Year",
    y = "Frequency",
    color = "Words"
  ) +
  theme_minimal() +
  theme(
    legend.position = "right",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5, size = 16)
  ) +
  guides(color = guide_legend(reverse = FALSE))

ggsave("/home/zch/AHDS_project/plots/Word_Frequency_Trends_2019-2026.png", width = 8, height = 6)

covid_data <- word_trends_top %>% filter(word == "covid")
other_words_data <- word_trends_top %>% filter(word != "covid")

covid_data <- covid_data %>% mutate(group = "COVID Only")
other_words_data <- other_words_data %>% mutate(group = "Other Words")

combined_data <- bind_rows(covid_data, other_words_data)

gg <- ggplot(combined_data, aes(x = year, y = frequency, color = word, group = word)) +
  geom_line(linewidth = 1.2, alpha = 0.8) +
  scale_color_viridis_d(option = "plasma", begin = 0, end = 0.9) +
  scale_x_continuous(
    breaks = seq(2019, 2026, by = 1),
    limits = c(2019, 2026)
  ) +
  labs(
    title = "Thematic Word Frequency Trends (2019-2026)",
    x = "Year",
    y = "Frequency",
    color = "Words"
  ) +
  theme_minimal() +
  theme(
    legend.position = "right",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5, size = 16)
  ) +
  facet_wrap(~group, scales = "free_y") +
  guides(color = guide_legend(reverse = FALSE))

ggsave("/home/zch/AHDS_project/plots/Thematic_Word_Frequency_Trends_2019-2026.png", width = 8, height = 6)

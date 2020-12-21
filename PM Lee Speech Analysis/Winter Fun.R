library(readr)
library(stringi)
library(tidytext)
library(tidyr)
library(ggplot2)
library(ggthemes)

#import list of stop words
data("stop_words")

#create list of speech file names
speech_files = list.files(path = "./Speeches")


#create tidy dfs of speeches
for (i in 1:length(speech_files)) {
  speech <- read_lines(paste0("./Speeches/",speech_files[i])) %>% stri_remove_empty()
  speechdf <- tibble(line = 1:length(speech), sentence=speech) %>% 
    unnest_tokens(word,sentence) %>%
    anti_join(stop_words)
  
  assign(paste0("df",i),speechdf)
}

#bind all words together
#label the dfs with dates before binding
binded_words <- bind_rows(mutate(df1, date=as.Date("08-02", format="%d-%m")),
                          mutate(df2, date=as.Date("16-02", format="%d-%m")),
                          mutate(df3, date=as.Date("12-03", format="%d-%m")),
                          mutate(df4, date=as.Date("03-04", format="%d-%m")),
                          mutate(df5, date=as.Date("10-04", format="%d-%m")),
                          mutate(df6, date=as.Date("21-04", format="%d-%m")),
                          mutate(df7, date=as.Date("23-06", format="%d-%m")),
                          mutate(df8, date=as.Date("14-12", format="%d-%m")))

#compare word counts across speeches
count_words <- binded_words %>% 
  #remove all numerics in the words
  mutate(word = stri_extract(word, regex = "[a-z']+")) %>% na.omit() %>%
  count(date,word) %>%
  #count proportions instead of raw count to account for length of speech
  mutate(proportion = n / sum(n)) %>%
  select(-n) %>% 
  group_by(date) %>%
  #arrange the words by proportion used
  arrange(desc(proportion), .by_group = TRUE) %>%
  #extract top 5 words used
  slice(1:5) %>%
  #add in column for graph highlighting
  mutate(tohigh = ifelse(proportion == max(proportion), "Yes", "No"))

date.labs <- c("8th Feb", "16th Feb", "12th March", "3rd Apr", "10th Apr", "21st Apr", "23rd Jun", "14th Dec")
names(date.labs) <- c("2020-02-08", "2020-02-16", "2020-03-12", "2020-04-03", "2020-04-10", "2020-04-21", "2020-06-23", "2020-12-14")

#plot graph using "reorder_within" to get bars to line up nicely
count_words %>% ggplot(aes(y=proportion, x=reorder_within(word,-proportion,date), fill=tohigh)) +
  scale_x_reordered() +
  geom_bar(stat="identity") +
  facet_wrap(~date, ncol=2, scales="free", labeller = labeller(date = date.labs)) + 
  labs(title = "Top Words used by PM Lee in Speeches", x="", y="Proportion Used") +
  scale_fill_manual(values = c( "Yes"="tomato", "No"="lightblue" ), guide = FALSE ) +
  theme_economist(dkpanel = TRUE) +
  theme(axis.title.y = element_text(family = "sans", size = 15, margin=margin(0,30,0,0)),
        plot.title = element_text(family = "sans", size = 18, margin=margin(0,0,10,0)),
        panel.margin.x=unit(1, "lines") , panel.margin.y=unit(3,"lines"))

#use regex to extract words of interest
word_series <- binded_words %>%
  mutate(word = stri_extract(word, regex = "covid|vaccine|virus|singapore")) %>% na.omit() %>%
  count(date, word)

#plot graph over time of change in the count of words selected
word_series %>% ggplot(aes(y=n, x=date, color=word)) +
  labs(title="Change in words used in speech from Feb - Dec", x="Date",y="Count", color="Word") +
  theme_economist(base_size = 15) +
  geom_line(size=1) +
  theme(legend.position = "right", axis.title.y = element_text(family = "sans", size = 15, margin=margin(0,30,0,0)),
        axis.title.x = element_text(family = "sans", size = 15, margin=margin(30,0,0,0)),
        legend.title = element_text(size=15))

#quick sentiment analysis of each speech
sentiment_words <- binded_words %>% inner_join(get_sentiments("bing")) %>%
  group_by(date) %>%
  count(sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative) %>%
  mutate(newdate = format(date, "%d %b"))

#plot out sentiments
sentiment_words %>% ggplot(aes(y=sentiment, x=factor(newdate, levels = newdate), fill=sentiment)) +
  geom_bar(stat="identity") +
  labs(title="Change in sentiment over time", x="Date", y="Sentiment", fill="Sentiment Score") +
  theme_economist(base_size = 15) +
  scale_color_economist() +
  theme(legend.position = "right", axis.title.y = element_text(family = "sans", size = 15, margin=margin(0,30,0,0)),
        axis.title.x = element_text(family = "sans", size = 15, margin=margin(30,0,0,0)),
        legend.title = element_text(size=15))

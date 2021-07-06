# import libraries to download stock data
library(tidyquant)
library(dplyr)
library(zoo)

# download STI data
STI_csv <- read.csv("sti.csv") %>% mutate(Date = as.Date(STI$Date, format = "%Y-%m-%d")) %>%
  select(c("Date","Close", "Volume"))
# mutate to get daily returns using Adj Close
STI_returns <- STI_csv %>% tq_transmute(select = Close, mutate_fun = periodReturn, period="daily", col_rename = "returns") %>% mutate(returns = returns*100)
# read PSI data 
psi <- read.csv("psi.csv") %>% 
  mutate(Date = as.Date(psi$Date, format = "%d/%m/%Y"))

# join to create new df with returns, volume, PSI
STI_vol <- STI_csv %>% select("Date", "Volume") %>% mutate(Volume = Volume/100000)
df <- 1
df <- inner_join(psi, STI_returns, by = "Date") 
df <- inner_join(df, STI_vol, by = "Date")
df_logit <- df %>% mutate(psi_ma = rollapply(PSI, 21, mean, fill=NA),
                          vol_ma = rollapply(Volume, 21, mean, fill=NA)) %>%
  na.omit() %>% mutate(psi_high = ifelse(PSI > psi_ma, 1, 0),
                       vol_high = ifelse(Volume > vol_ma, 1, 0),
                       stock_bi = ifelse(returns > 0 ,1, 0)) 

model <- lm(Volume ~ PSI + Date, data = df_logit)
summary(model)
plot(df$PSI, df$Volume, xlab = "PSI", ylab="Trade Volume (00,000)", col="red")
abline(lm(df$Volume ~ df$PSI), col = "blue")
plot(df$Date, df$Volume)

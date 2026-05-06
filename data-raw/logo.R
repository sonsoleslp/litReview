library(ggplot2)
library(hexSticker)

df <- data.frame(
  cat = factor(c("A", "B", "C", "D", "E"), levels = c("A", "B", "C", "D", "E")),
  freq = c(3, 5, 2, 7, 4)
)

palette <- c("#ff9da7", "#7ea9c7", "#f16769", "#b07aa1", "#edc948")

subplot <- ggplot(df, aes(x = cat, y = freq, fill = cat)) +
  geom_bar(stat = "identity", width = 0.7) +
  scale_fill_manual(values = palette) +
  theme_void() +
  theme(legend.position = "none")

sticker(
  subplot,
  package = "litReview",
  p_size = 22,
  p_y = 1.45,
  p_color = "#ffffff",
  p_family = "sans",
  s_x = 1, s_y = 0.78,
  s_width = 1.3, s_height = 0.9,
  h_fill = "#333",
  h_color = "#76b7b2",
  h_size = 1.5,
  filename = "man/figures/logo.png",
  dpi = 300
)

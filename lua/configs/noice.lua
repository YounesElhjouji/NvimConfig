require("notify").setup {
  render = "minimal",
  stages = "static", -- No animations
  timeout = 2000, -- Duration of the notification
  background_colour = "#000000", -- Black background for minimal distraction
  max_width = 30, -- Narrower notification width
  max_height = 10, -- Shorter notification height
}

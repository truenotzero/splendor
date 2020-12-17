import Config

config :frontend, Splendor.Session,
  major: 95,
  minor: "1",
  locale: 8


config :frontend, Splendor.CustomOFBCipher,
  key: <<0x13, 0x08, 0x06, 0xB4, 0x1B, 0x0F, 0x33, 0x52>>

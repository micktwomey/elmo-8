PICO_8_PALETTE_MAP_ELM=src/Elmo8/Textures/Pico8PaletteMap.elm
PICO_8_PALETTE_MAP_PNG=palettes/pico-8-palette-map.png
PICO_8_FONT_ELM=src/Elmo8/Textures/Pico8Font.elm
PICO_8_FONT_PNG=font/pico-8_regular_8.png
CONVERTER=tools/convert_to_data_uri.py
SOURCES=$(shell find examples src -name '*.elm')

.PHONY: all
all: $(PICO_8_PALETTE_MAP_ELM) $(PICO_8_FONT_ELM)

$(PICO_8_PALETTE_MAP_ELM): Makefile $(CONVERTER) $(PICO_8_PALETTE_MAP_PNG)
	python3 $(CONVERTER) \
		Elmo8.Textures.Pico8PaletteMap \
		pico8PaletteMapDataUri \
		image/png \
		$(PICO_8_PALETTE_MAP_PNG) \
		$(PICO_8_PALETTE_MAP_ELM)

$(PICO_8_FONT_ELM): Makefile $(CONVERTER) $(PICO_8_FONT_PNG)
	python3 $(CONVERTER) \
		Elmo8.Textures.Pico8Font \
		pico8FontDataUri \
		image/png \
		$(PICO_8_FONT_PNG) \
		$(PICO_8_FONT_ELM)

documentation.json: $(SOURCES)
	elm make --docs=documentation.json --warn

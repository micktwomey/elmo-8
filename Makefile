PICO_8_PALETTE_MAP_ELM=src/Elmo8/Textures/Pico8PaletteMap.elm
PICO_8_PALETTE_MAP_PNG=palettes/pico-8-palette-map.png

PICO_8_FONT_ELM=src/Elmo8/Textures/Pico8Font.elm
PICO_8_FONT_PNG=font/pico-8_regular_8.png

CONVERTER=tools/convert_to_data_uri.py

SOURCES=$(shell find examples src -name '*.elm')

.PHONY: all
all: $(PICO_8_PALETTE_MAP_ELM) $(PICO_8_FONT_ELM) examples

$(PICO_8_PALETTE_MAP_ELM): Makefile $(CONVERTER) $(PICO_8_PALETTE_MAP_PNG)
	mkdir -p src/Elmo8/Textures
	python3 $(CONVERTER) \
		Elmo8.Textures.Pico8PaletteMap \
		pico8PaletteMapDataUri \
		image/png \
		$(PICO_8_PALETTE_MAP_PNG) \
		$(PICO_8_PALETTE_MAP_ELM)
	elm format --yes $(PICO_8_PALETTE_MAP_ELM)

$(PICO_8_FONT_ELM): Makefile $(CONVERTER) $(PICO_8_FONT_PNG)
	mkdir -p src/Elmo8/Textures
	python3 $(CONVERTER) \
		Elmo8.Textures.Pico8Font \
		pico8FontDataUri \
		image/png \
		$(PICO_8_FONT_PNG) \
		$(PICO_8_FONT_ELM)
	elm format --yes $(PICO_8_FONT_ELM)

.PHONY: examples
examples:
	mkdir -p _example
	elm make --output _example/examples.js examples/*.elm
	cp examples/*.png _example/
	mkdir -p assets
	cp $(PICO_8_PALETTE_MAP_PNG) assets/
	cp $(PICO_8_FONT_PNG) assets/

documentation.json: $(SOURCES)
	elm make --docs=documentation.json --warn

.PHONY: format
format:
	elm format --upgrade --yes src/ examples/

.PHONY: upgrade
upgrade:
	elm upgrade


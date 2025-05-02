# JUIN

JUIN stands for **J**avaScript **U**ser **In**terface. JUIN is a Lua library that enabled constructing simple user interfaces through JavaScript configuration files.

Currently JUIN supports 3 UI controls:

* Button
* Image
* Label

Each control has some configuration options. A simple JSON layout file might look as such:

```json
[
	{
		"type": "image", // type of UI control to render
		"z_index": -1, // order of drawing - higher values are drawn on top of lower values
		"file": "gfx/menu_background.png", // path to a file to render
		"pos": [ 0.5, 0.5 ] // a position on screen, either relative or absolute
	},	
	{
		"type": "label",
		"text": "CLEAR THE GRID", // text for the label control
		"font": {
			"file": "fnt/Kalam/Kalam-Regular.ttf",
			"size": 60,
		},
		"pos": [ 0.5, 0.15 ],
		"states": { // configuration per state, normal, highlight, disabled, ...
			"normal": {
				"fg_color": "#000000",
			},
		}
	},
	{
		"type": "button",
		"text": "NEW GAME", // text for the button
		"margin": [ 20, 10, 20, 0 ], // margin around the text
		"font": {
			"file": "fnt/Kalam/Kalam-Bold.ttf",
			"size": 40,
		},
		"pos": [ 0.5, 0.4 ],
		"click": "newGame", // an function to invoke on the bound class
		"states": {
			"normal": {
				"fg_color": "#ffffff",
				"bg_color": "#333333",
			},
			"hovered": {
				"fg_color": "#ffffff",
				"bg_color": "#882222",
			},
			"pressed": {
				"fg_color": "#ffffff",
				"bg_color": "#BB3333",
			},
		}
	},
]
```

This library is still a work in progress. Work remaining:

- Shared visual styles to avoid having to configure each control separately
- Implement additional control states (disabled is currently not implemented)
- Probably add a few more UI controls


operators = {
	{
		descr:	"Addition",
		id:		"addi",
		ranges: {
			{
				id: "10",
				descr: "Von eins bis zehn",
				types: { 
					{ id: 1, name: "Punkte", long_descr: "Spiel so schnell du kannst", img_filename: "zeit.svg"},
					{ id: 2, name: "Auf Zeit", long_descr: "Wie viele Aufgaben schaffst du?", img_filename: "zeit.svg"},
					{ id: 3, name: "Marathon", long_desr: "Halt durch!", img_filename: "zeit.svg"}
				},
				img_filename: "bis_zehn.svg"
			},
			{
				id: "20",
				descr: "Von eins bis zwanzig",
				types: { 
					{ id: 1, name: "Punkte", long_descr: "Spiel so schnell du kannst", img_filename: "zeit.svg"},
					{ id: 2, name: "Waage", long_descr: "Gleich die Waage aus", img_filename: "scale.svg"},
					{ id: 3, name: "Marathon", long_desr: "Halt durch!", img_filename: "zeit.svg"}
				},
				img_filename: "bis_zwanzig.svg"
			}

		},
		img_filename: "addi.svg"
	},
	{
		descr:	"Multiplikation",
		id:		"mult",
		ranges: {
			{
				id: "small",
				descr: "Kleines Einmaleins",
				types: { 
					{ id: 1, name: "Eine Reihe", long_descr: "Üb' eine einzelne Reihe", img_filename: "eine_reihe.svg"},
					{ id: 2, name: "Alle Reihen gemischt", long_descr: "Kannst du schon alle?", img_filename: "alle_reihen.svg"},
					{ id: 3, name: "Marathon", long_desr: "Halt durch!", img_filename: "zeit.svg"}
				},
				img_filename: "bis_zehn.svg"
			},
			{
				id: "big",
				descr: "Großes Einmaleins",
				types: { 
					{ id: 1, name: "Punkte", long_descr: "Spiel so schnell du kannst", img_filename: "zeit.svg"},
					{ id: 2, name: "Auf Zeit", long_descr: "Gleich die Waage aus", img_filename: "scale.svg"},
					{ id: 3, name: "Marathon", long_desr: "Halt durch!", img_filename: "zeit.svg"}
				},
				img_filename: "bis_zwanzig.svg"
			}
		},
		img_filename: "mult.svg"
	}
}
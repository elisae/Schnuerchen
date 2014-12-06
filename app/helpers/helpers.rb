
def getGameCategories

	operators = Operator.map { |op|
		ranges = op.gameranges.map { |gr|
			types = gr.gametypes.map { |gt|
				gt.to_hash
			}
			puts types
			gr.to_hash.merge(:types=>types)
		}
		op.to_hash.merge(:ranges=>ranges)
	}

	return operators
end
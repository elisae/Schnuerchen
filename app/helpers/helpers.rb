
def getGameCategories
	operators = Operator.map { |op|
		ranges = op.gameranges.map { |gr|
			types = gr.gametypes.map { |gt|
				gt.to_hash
			}
			unless types.any?
				types = nil
			end
			gr.to_hash.merge(:types=>types)
		}
		unless ranges.any?
			ranges = nil
		end
		op.to_hash.merge(:ranges=>ranges)
	}
	return operators
end
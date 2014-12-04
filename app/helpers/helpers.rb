
def getGameCategories
	gametypes_hash = Gametype.map { |gt|
		gt.to_hash
	}
	ranges_hash = Gamerange.map { |rng|
		rng.to_hash.merge({:gametypes => gametypes_hash})
	}
	operators_hash = Operator.map { |op|
		op.to_hash.merge({:ranges => ranges_hash})
	}
	return operators_hash
end
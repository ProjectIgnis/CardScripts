--古代の機械融合
--Ancient Gear Fusion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.AddSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x7),nil,nil,s.fextra)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
end
s.listed_names={83104731,95735217}
function s.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.filterchk(c)
	return c:IsFaceup() and c:IsCode(83104731,95735217) and c:IsOnField()
end
function s.fcheck(tp,sg,fc,mg)
	if sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
		return sg:IsExists(s.filterchk,1,nil) end
	return true
end
function s.fextra(e,tp,mg)
	if mg:IsExists(s.filterchk,1,nil) then
		return Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK,0,nil),s.fcheck
	end
	return nil
end
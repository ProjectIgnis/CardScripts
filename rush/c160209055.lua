--天翔変化
--Divine Transformation
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	c:RegisterEffect(Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),Fusion.OnFieldMat,s.fextra))
end
function s.checkmat(tp,sg,fc)
	return sg:IsExists(Card.IsRace,1,nil,RACE_FAIRY) and (fc:IsRace(RACE_CELESTIALWARRIOR) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND))
end
function s.fextra(e,tp,mg)
	local fusg=Duel.GetMatchingGroup(Fusion.OnFieldMat,tp,LOCATION_MZONE,0,nil)
	local extrag=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_HAND,0,nil)
	fusg:Merge(extrag)
	return fusg,s.checkmat
end
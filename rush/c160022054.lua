--奇跡の秘術
--Miracle Secret Arts
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,nil,s.mfilter,s.fextra,Fusion.ShuffleMaterial,nil,nil,2)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil)
end
function s.mfilter(c)
	if not c:IsCode(CARD_DARK_MAGICIAN,78193831) then return false end
	if c:IsLocation(LOCATION_GRAVE) then return c:IsAbleToDeck() end
	return true
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)==1 and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==1
end
function s.fextra(e,tp,mg)
	local eg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	if #eg>0 then
		return eg,s.fcheck
	end
	return nil
end
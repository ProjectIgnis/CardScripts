--サイバー・ラッシュ・フュージョン
--Cyber Rush Fusion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,s.filter,s.mfilter,s.fextra,Fusion.ShuffleMaterial,nil,s.stage2,nil,nil,nil,nil,nil,nil,nil,nil,nil,5)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_MZONE,0,1,nil)
end
function s.filter(c)
	return c:ListsCodeAsMaterial(CARD_CYBER_DRAGON)
end
function s.mfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLocation(LOCATION_GRAVE|LOCATION_MZONE) and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil)
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==0 then
		Duel.SpecialSummonComplete()
		local sg=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,LOCATION_MZONE,0,tc)
		if #sg>0 then
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
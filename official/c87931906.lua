--月光融合
--Lunalight Fusion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0xdf),nil,s.fextra)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
s.listed_series={0xdf}
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA+LOCATION_DECK)<=1
end
function s.fextra(e,tp,mg)
	if Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA) then
		local eg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.exfilter(c)
	return c:IsMonster() and c:IsSetCard(0xdf) and c:IsAbleToGrave()
end

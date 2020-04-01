--オッドアイズ・フュージョン
--Odd-Eyes Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),nil,s.fextra)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={0x99}
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=2
end
function s.fextra(e,tp,mg)
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1 then
		local sg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_EXTRA,0,nil)
		if #sg>0 then
			return sg,s.fcheck
		end
	end
	return nil
end
function s.exfilter(c)
	return c:IsSetCard(0x99) and c:IsAbleToGrave()
end

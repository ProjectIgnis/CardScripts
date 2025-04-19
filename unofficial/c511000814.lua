--エクストラ・フュージョン
--Extra Fusion
--rescripted by Naim (to match the Fusion summon procedure)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,nil,aux.FALSE,s.fextra)
	c:RegisterEffect(e1)
end
function s.fextra(e,tp,mg)
	local sg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_EXTRA,0,nil)
	if #sg>0 then return sg end
	return nil
end
function s.exfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsAbleToGrave()
end
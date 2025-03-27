--ミュートリアスの産声
--Myutant Cry
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Fusion summon 1 "Myutant" fusion monster by shuffling fusion materials from field/GY/face-up banished into deck
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,SET_MYUTANT),Fusion.OnFieldMat(Card.IsAbleToDeck),s.fextra,Fusion.ShuffleMaterial,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	c:RegisterEffect(e1)
end
	--Lists "Myutant" archetype
s.listed_series={SET_MYUTANT}
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(aux.NecroValleyFilter(Card.IsFaceup,Card.IsAbleToDeck)),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_PUBLIC)
end
--JP name
--Myutant Cry
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Fusion summon 1 "Myutant" fusion monster
	--By shuffling fusion materials from field/GY/face-up banished into deck
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x259),Fusion.OnFieldMat(Card.IsAbleToDeck),s.fextra,Fusion.ShuffleMaterial)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
	--Lists "Myutant" archetype
s.listed_series={0x259}

function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(aux.NecroValleyFilter(Card.IsFaceup,Card.IsAbleToDeck)),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
end
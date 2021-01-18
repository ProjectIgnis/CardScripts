--ミラクル・コンタクト (Anime)
--Miracle Contact (Anime)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,s.spfilter,Fusion.OnFieldMat(Card.IsAbleToDeck),s.fextra,Fusion.ShuffleMaterial,nil,nil,nil,SUMMON_TYPE_FUSION|MATERIAL_FUSION,nil,FUSPROC_NOTFUSION)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
s.listed_series={0x3008}
s.listed_names={CARD_NEOS}
function s.spfilter(c)
	return c:IsSetCard(0x3008) and aux.IsMaterialListCode(c,CARD_NEOS)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsAbleToDeck)),tp,LOCATION_GRAVE,0,nil)
end

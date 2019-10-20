--サイバーダーク・インパクト！
--Cyberdark Impact!
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsCode,40418351),Card.IsAbleToDeck,s.fextra,Fusion.ShuffleMaterial,nil,nil,3)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
s.listed_names={40418351,41230939,77625948,3019642}
function s.matfilter(c,lc,stype,tp)
	return c:IsSummonCode(lc,stype,tp,41230939,77625948,3019642) and c:IsAbleToDeck()
end
function s.fcheck(tp,sg,fc,mg)
	return sg:IsExists(Card.IsSummonCode,1,nil,fc,SUMMON_TYPE_FUSION,tp,41230939)
		and sg:IsExists(Card.IsSummonCode,1,nil,fc,SUMMON_TYPE_FUSION,tp,77625948)
		and sg:IsExists(Card.IsSummonCode,1,nil,fc,SUMMON_TYPE_FUSION,tp,3019642)
end
function s.fextra(e,tp,mg)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	return g,s.fcheck
end

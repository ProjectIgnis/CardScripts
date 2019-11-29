--死魂融合
--Necro Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,nil,s.matfilter,s.fextra,s.extraop)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
function s.matfilter(c)
	return aux.SpElimFilter(c) and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extraop(e,tc,tp,sg)
	Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Clear()
end

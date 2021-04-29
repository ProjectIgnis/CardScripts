--Dowsing Fusion (anime)
--rescripted by Naim (to match the Fusion Summon Procedure)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,nil,aux.FALSE,s.fextra,s.extraop)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToExtra),tp,LOCATION_GRAVE,0,nil):Filter(Card.IsType,nil,TYPE_PENDULUM)
end
function s.extraop(e,tc,tp,sg)
	Duel.SendtoExtraP(sg,nil,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Clear()
end

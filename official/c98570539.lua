--Dream Mirror of Chaos
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0x131),matfilter=Fusion.OnFieldMat,extrafil=s.fextra,extraop=s.extraop})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
s.listed_series={0x131}
s.listed_names={CARD_DREAM_MIRROR_JOY,CARD_DREAM_MIRROR_TERROR}
function s.fextra(e,tp,mg)
	if Duel.IsEnvironment(CARD_DREAM_MIRROR_JOY,PLAYER_ALL,LOCATION_FZONE) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_HAND,0,nil)
	end
	if Duel.IsEnvironment(CARD_DREAM_MIRROR_TERROR,PLAYER_ALL,LOCATION_FZONE) and not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
end
function s.extraop(e,tc,tp,sg)
	local g1=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.Remove(g1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Sub(g1)
end
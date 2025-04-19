--極寒の氷柱
--Twin Pillars of Ice
--AlphaKretin
--Credit to edo9300 for implementing the Ice Pillar mechanic
Duel.EnableUnofficialProc(PROC_ICE_PILLAR)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>1 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0) < 2 then return end
	IcePillarZone[tp+1] = IcePillarZone[tp+1] + Duel.SelectDisableField(tp,2,LOCATION_MZONE,0,IcePillarZone[tp+1])
end
--禁断儀式術
--Forbidden Ritual Art
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon 1 Ritual Monster from your GY, by banishing monsters from your GY whose total Levels equal its Level, but destroy it during the End Phase
	local e1=Ritual.AddProcEqual({
		handler=c,
		location=LOCATION_GRAVE,
		matfilter=function(c) return c:IsLocation(LOCATION_GRAVE) end,
		extrafil=s.rextra,
		extratg=s.extratg,
		stage2=s.stage2
	})
	e1:SetCategory(e1:GetCategory()+CATEGORY_REMOVE)
	e1:SetCountLimit(1,{id,0})
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--Apply an "once this turn, when you Ritual Summon with a card effect that requires use of monster Tributes, you can also banish Ritual Monsters from your GY as monsters used for the Ritual Summon" effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetOperation(s.effop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
function s.rextra(e,tp,eg,ep,ev,re,r,rp,chk)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(aux.AND(Card.HasLevel,Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,rc)
	--Destroy it during the End Phase
	aux.DelayedOperation(rc,PHASE_END,id,e,tp,function(ag) Duel.Destroy(ag,REASON_EFFECT) end,nil,0,0,aux.Stringid(id,2))
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,3))
	--Once this turn, when you Ritual Summon with a card effect that requires use of monster Tributes, you can also banish Ritual Monsters from your GY as monsters used for the Ritual Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e1:SetCountLimit(1,id)
	e1:SetTargetRange(LOCATION_GRAVE,0)
	e1:SetCondition(function(e) return not Duel.HasFlagEffect(tp,id) end)
	e1:SetTarget(function(e,c) return c:IsRitualMonster() and c:IsAbleToRemove() end)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
end
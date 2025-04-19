--誕生の祝福
--Celebration of Creation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and re
		and (re:IsHasType(EFFECT_TYPE_ACTIONS) or re:IsHasType(EFFECT_TYPE_CONTINUOUS))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.SkipPhase(1-tp,PHASE_DRAW,RESET_PHASE|PHASE_END,1)
	Duel.SkipPhase(1-tp,PHASE_STANDBY,RESET_PHASE|PHASE_END,1)
	Duel.SkipPhase(1-tp,PHASE_MAIN1,RESET_PHASE|PHASE_END,1)
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE|PHASE_END,1,1)
	Duel.SkipPhase(1-tp,PHASE_MAIN2,RESET_PHASE|PHASE_END,1)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
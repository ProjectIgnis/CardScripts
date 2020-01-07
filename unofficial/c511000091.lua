--時の飛躍－ターンジャンプ－
--Turn Jump
--clean up by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_START,TIMING_BATTLE_START)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	Duel.SkipPhase(p,PHASE_DRAW,RESET_PHASE+PHASE_END,4)
	Duel.SkipPhase(p,PHASE_MAIN1,RESET_PHASE+PHASE_END,4)
	Duel.SkipPhase(p,PHASE_BATTLE,RESET_PHASE+PHASE_END,2,2)
	Duel.SkipPhase(p,PHASE_MAIN2,RESET_PHASE+PHASE_END,2)
	Duel.SkipPhase(1-p,PHASE_DRAW,RESET_PHASE+PHASE_END,3)
	Duel.SkipPhase(1-p,PHASE_MAIN1,RESET_PHASE+PHASE_END,3)
	Duel.SkipPhase(1-p,PHASE_BATTLE,RESET_PHASE+PHASE_END,3,3)
	Duel.SkipPhase(1-p,PHASE_MAIN2,RESET_PHASE+PHASE_END,3)
	local e1=Effect.GlobalEffect()
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(1,1)
	e1:SetReset(RESET_PHASE+PHASE_END,5)
	Duel.RegisterEffect(e1,tp)
	local be=Effect.GlobalEffect()
	be:SetType(EFFECT_TYPE_FIELD)
	be:SetCode(EFFECT_CANNOT_EP)
	be:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	be:SetTargetRange(1,1)
	be:SetReset(RESET_PHASE+PHASE_MAIN1,6)
	Duel.RegisterEffect(be,tp)
end
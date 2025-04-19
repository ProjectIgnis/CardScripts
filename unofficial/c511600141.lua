--時の飛躍－ターンジャンプ－ (Manga)
--Turn Jump (Manga)
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_START,TIMING_BATTLE_START)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=Duel.GetTurnPlayer()
	Duel.SkipPhase(p,PHASE_DRAW,RESET_PHASE|PHASE_END,4)
	Duel.SkipPhase(p,PHASE_MAIN1,RESET_PHASE|PHASE_END,4)
	Duel.SkipPhase(p,PHASE_BATTLE,RESET_PHASE|PHASE_END,2,2)
	Duel.SkipPhase(p,PHASE_MAIN2,RESET_PHASE|PHASE_END,2)
	Duel.SkipPhase(1-p,PHASE_DRAW,RESET_PHASE|PHASE_END,3)
	Duel.SkipPhase(1-p,PHASE_MAIN1,RESET_PHASE|PHASE_END,3)
	Duel.SkipPhase(1-p,PHASE_BATTLE,RESET_PHASE|PHASE_END,3,3)
	Duel.SkipPhase(1-p,PHASE_MAIN2,RESET_PHASE|PHASE_END,3)
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
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetValue(1)
	e2:SetCondition(s.con)
	e2:SetReset(RESET_PHASE+PHASE_END,6)
	Duel.RegisterEffect(e2,tp)
	local ac=Duel.GetAttacker()
	if ac and (Duel.GetCurrentPhase()<PHASE_DAMAGE_CAL or not Duel.IsDamageCalculated()) then
		local ag=Group.FromCards(ac,Duel.GetAttackTarget())
		ag:KeepAlive()
		local at=Effect.CreateEffect(c)
		at:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		at:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		at:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		at:SetCountLimit(1)
		at:SetLabelObject(ag)
		at:SetTarget(s.bttg)
		at:SetOperation(s.btop)
		at:SetReset(RESET_PHASE+PHASE_END,6)
		Duel.RegisterEffect(at,tp)
		for tc in aux.Next(ag) do
			tc:CreateEffectRelation(at)
		end
	end
end
function s.bttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ac=e:GetLabelObject():GetFirst()
	local at=e:GetLabelObject():GetNext()
	local p=ac:GetControler()
	if chk==0 then return ac:IsFaceup() and (ac:IsAttackPos() or ac:IsHasEffect(EFFECT_DEFENSE_ATTACK))
		and ac:IsRelateToEffect(e) and (not ac:IsHasEffect(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		and not ac:IsHasEffect(EFFECT_FORBIDDEN) and not ac:IsHasEffect(EFFECT_CANNOT_ATTACK)
		and not Duel.IsPlayerAffectedByEffect(p,EFFECT_CANNOT_ATTACK_ANNOUNCE)
		and not Duel.IsPlayerAffectedByEffect(p,EFFECT_CANNOT_ATTACK)
		or ac:IsHasEffect(EFFECT_UNSTOPPABLE_ATTACK))
		and (not at or ac:GetAttackableTarget():IsContains(at) and at:IsRelateToEffect(e)) end
	Duel.SetChainLimit(aux.FALSE)
end
function s.btop(e,tp,eg,ep,ev,re,r,rp)
	Duel.CalculateDamage(e:GetLabelObject():GetFirst(),e:GetLabelObject():GetNext())
	e:Reset()
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=e:GetOwnerPlayer()
end
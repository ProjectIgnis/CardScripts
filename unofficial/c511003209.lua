--ゼロ・ポテンシャル
--Zero Potential (Manga)
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--0 Battle Damage/Draw 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetBattleDamage(tp)>0 and Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Draw(1-tp,1,REASON_EFFECT)
	Duel.Draw(tp,1,REASON_EFFECT)
	local dg=Duel.GetOperatedGroup():GetFirst()
	if dg:IsSetCard(SET_DDD) then
		Duel.ConfirmCards(1-tp,dg)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		Duel.RegisterEffect(e1,tp)
	end
end
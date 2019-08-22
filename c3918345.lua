--マジック・スライム
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableGeminiAttribute(c)
	--reflect battle dam
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetCondition(aux.IsGeminiState)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local dam=Duel.GetBattleDamage(tp)
	if dam>0 then
		Duel.ChangeBattleDamage(1-tp,Duel.GetBattleDamage(1-tp)+dam,false)
		Duel.ChangeBattleDamage(tp,0)
	end
end

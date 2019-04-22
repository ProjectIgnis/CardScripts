--Lengard
local s,id=GetID()
function s.initial_effect(c)
	--no damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDestructable(e) and ep==tp and Duel.SelectEffectYesNo(tp,e:GetHandler()) 
		and Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE) then
		Duel.ChangeBattleDamage(tp,0)
	end
end

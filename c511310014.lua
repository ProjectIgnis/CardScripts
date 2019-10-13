--Bubble Barrier (Anime)
--AlphaKretin
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--effect gain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.negop)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
s.listed_series={0x9f,0xc6}
function s.eftg(e,c)
	return (c:IsSetCard(0x9f) or c:IsSetCard(0xc6)) and c:IsAttackBelow(1500)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)==0 and Duel.SelectEffectYesNo(tp,c) then
		Duel.Hint(HINT_CARD,0,c:GetOriginalCode())
		Duel.Hint(HINT_CARD,0,id)
		Duel.NegateAttack()
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
end

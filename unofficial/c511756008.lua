--M・HERO ヴェイパー
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--battle des rep
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetTarget(s.reptg)
	c:RegisterEffect(e1)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_BATTLE) end
	Duel.Hint(HINT_CARD,0,id)
	return true
end

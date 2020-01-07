--coded by Lyris
--fixed by MLD
--Comic Field
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--If exactly 1 "Comics Hero" monster would be destroyed by battle, it gains 500 ATK instead. [Puzzle Reborn & Crystal Protector]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
end
s.listed_names={77631175,13030280}
function s.dfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsReason(REASON_BATTLE) and (c:IsCode(77631175) or c:IsCode(13030280))
end
function s.indtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:FilterCount(s.dfilter,nil)==1 end
	Duel.Hint(HINT_CARD,0,id)
	local g=eg:Filter(s.dfilter,nil)
	local tc=g:GetFirst()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(500)
	tc:RegisterEffect(e1)
	return true
end
function s.indval(e,c)
	return c:IsFaceup() and c:IsOnField() and c:IsReason(REASON_BATTLE) and (c:IsCode(77631175) or c:IsCode(13030280))
end

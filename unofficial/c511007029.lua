--Coded by Lyris
--Double Evolution
local s,id=GetID()
function s.initial_effect(c)
	--Double an equip spell effect.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:GetEquipTarget()~=nil-- and c:IsType(TYPE_EQUIP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		tc:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD)
	end
end

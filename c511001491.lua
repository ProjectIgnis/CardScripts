--Overlay Burglary
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	return at:IsControler(tp) and at:IsFaceup() and at:IsType(TYPE_XYZ) and a:IsType(TYPE_XYZ) and a:GetOverlayCount()>0
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	if a and a:IsControler(1-tp) and a:IsLocation(LOCATION_MZONE) and at and at:IsControler(tp) and at:IsLocation(LOCATION_MZONE) then
		local g=a:GetOverlayGroup()
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(47660516,0))
			local mg=g:Select(tp,1,1,nil)
			local oc=mg:GetFirst():GetOverlayTarget()
			Duel.Overlay(at,mg)
			Duel.RaiseSingleEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
		end
	end
end

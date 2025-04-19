--不死鳥の闘翼
--Phoenix Battle Wing
--Re-scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Destroy replace
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.desreptg)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.atkop)
	c:RegisterEffect(e2)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_CARD,0,id)
		return true
	else return false end
end
function s.atkop(e)
	local c=e:GetHandler()
	local eq=c:GetEquipTarget()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) and eq then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(eq:GetAttack()*2)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	return false
end
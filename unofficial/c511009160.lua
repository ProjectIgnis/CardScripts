--霊剣タナトス
--Sacred Sword Thanatos
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--The equipped monster gains 300 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	--Destroy all Tokens on the field, and if you do, the equipped monster gains ATK equal to their ATK
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)	
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.desfilter(c,e,tp)
	if not c:IsType(TYPE_TOKEN) then return false end
	if c:IsDestructable(e) then return true end
	local indes_eff=c:IsHasEffect(EFFECT_INDESTRUCTABLE_EFFECT)
	return c:IsHasEffect(EFFECT_INDESTRUCTABLE_COUNT) and not (indes_eff
		and (type(indes_eff:GetValue())~='function' or indes_eff:GetValue()(indes_eff,e,tp,c)))
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec then return end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local atk=Duel.GetOperatedGroup():GetSum(Card.GetPreviousAttackOnField)
		if atk==0 then return end
		--The equipped monster gains ATK equal to the total ATK of the destroyed Tokens
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		ec:RegisterEffect(e1)
	end
end
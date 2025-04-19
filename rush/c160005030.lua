--花牙蘭獅子ガジュウ丸
--Gajumaru the Shadow Flower Lion
local s,id=GetID()
function s.initial_effect(c)
	--Targeted monster loses ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_PLANT) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0 and c:IsLevelBelow(8) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsNotMaximumModeSide()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	local ct=Duel.SendtoGrave(g,REASON_COST)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local dg=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
		if #dg>0 then
			Duel.HintSelection(dg)
			--Original ATK becomes 0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetValue(0)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			dg:GetFirst():RegisterEffect(e1)
		end
	end
end

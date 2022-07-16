--呪腐竜ディアーガ
--Cursed Skeletal Dragon Diarga
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Send itself to the GY and decrease ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_ZOMBIE),tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,-1000)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local c=e:GetHandler()
	if Duel.SendtoGrave(c,REASON_COST)>0 then
		--Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffectRush(e1)
		end
	end
end
--地霊術師の使い魔
--Familiar of the Earth Spiritualist
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Change selected monster's attribute to EARTH
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() or Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function s.attfilter(c)
	return c:IsFaceup() and c:CanChangeIntoAttributeRush(ATTRIBUTE_EARTH) and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attfilter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.cfilter(c)
	return c:IsCode(37970940) and c:IsFacedown()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	local b1=c:IsAbleToGraveAsCost()
	local b2=Duel.IsPlayerCanDiscardDeckAsCost(tp,1)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,2)},{b2,aux.Stringid(id,3)})
	if op==1 then
		if Duel.SendtoGrave(c,REASON_COST)<1 then return end
	elseif op==2 then
		if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local g=Duel.SelectMatchingCard(tp,s.attfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.HintSelection(g)
	if #g>0 then
		local tc=g:GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_EARTH)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local sc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
			Duel.HintSelection(sc)
			Duel.ChangePosition(sc,POS_FACEUP_DEFENSE)
		end
	end
end
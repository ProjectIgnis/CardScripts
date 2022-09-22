--ギャラクティカ・タブララサ
--Galactica Tabula Rasa
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Return 1 card on the field to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.tgfilter(c)
	return c:IsSpell() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.thfilter(c)
	return c:IsAbleToHand() and c:GetSequence()<5
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,0,LOCATION_SZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0)
end
function s.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(7) and c:IsAttackAbove(2500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==0 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,0,LOCATION_SZONE,1,1,nil)
	if #tc>0 then
		Duel.HintSelection(tc,true)
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		if Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter),tp,0,LOCATION_MZONE,1,1,nil)
			if #g>0 then
				g=g:AddMaximumCheck()
				Duel.HintSelection(g)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(-2500)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				g:GetFirst():RegisterEffectRush(e1)
			end
		end
	end
end
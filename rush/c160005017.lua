--執念の竜
--Fortitude Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 of opponent's monsters lose 400 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function s.filter(c)
	return c:IsFaceup() and c:IsAttackAbove(2000) and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return
		Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil)
	end
end
function s.sfilter(c)
	return c:IsCode(160405003) and c:IsSSetable()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)==1 then
		--Effect
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
			if #g>0 then
				Duel.HintSelection(g)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(-400)
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				g:GetFirst():RegisterEffect(e1)
			end
			--Set cards
			local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
			local sg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_GRAVE,0,nil)
			if ft>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
				Duel.HintSelection(tg)
				Duel.SSet(tp,tg)
			end
		end
	end
end
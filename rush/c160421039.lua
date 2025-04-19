--不成ゴブリン
--Unfulfilled Goblin
local s,id=GetID()
function s.initial_effect(c)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_UPSTART_GOBLIN}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
end
function s.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(8)
end
--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(aux.FilterMaximumSideFunctionEx(s.filter),tp,0,LOCATION_MZONE,1,e:GetHandler()) end
end
--Send this card to the GY to decrease an opponent's monster atk
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.SendtoGrave(e:GetHandler(),REASON_COST)==0 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter),tp,0,LOCATION_MZONE,1,1,e:GetHandler()):GetFirst()
	if tc then
		Duel.HintSelection(tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		if Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			Duel.BreakEffect()
			local tg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			local sg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.filter),tp,0,LOCATION_MZONE,nil)
			if Duel.SendtoDeck(tg,nil,0,REASON_EFFECT) and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				local tg=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter),tp,0,LOCATION_MZONE,1,1,nil)
				if #tg>0 then
					tg=tg:AddMaximumCheck()
					Duel.Destroy(tg,REASON_EFFECT)
				end
			end
		end
	end
end
function s.tdfilter(c)
	return c:IsAbleToDeck() and c:IsCode(CARD_UPSTART_GOBLIN)
end
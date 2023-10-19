--聖麗の凍士グラキエス
--Glacies the Snowmeister of Sacred Splendor
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Increase Level by 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,e:GetHandler()) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():HasLevel() end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD)
end
function s.tdfilter(c)
	return c:IsPosition(POS_FACEDOWN) and c:IsAbleToDeck()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,6,c)
	local req=Duel.SendtoGrave(g,REASON_COST)
	if req<1 then return end
	--Effect
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		c:UpdateLevel(1,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,c)
		-- Effect (cannot be destroyed by opponent's trap effects)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3060)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(function(e,te)return te:GetOwnerPlayer()~=e:GetOwnerPlayer()end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
		local fdg=Duel.GetMatchingGroup(s.tdfilter,tp,0,LOCATION_ONFIELD,nil)
		local ct=math.min(req//3,#fdg)
		if ct>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local tdg=fdg:Select(tp,1,ct,true,nil)
			Duel.HintSelection(tdg,true)
			Duel.SendtoDeck(tdg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

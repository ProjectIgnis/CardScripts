--ヨクトロン
--Yoctron

local s,id=GetID()
function s.initial_effect(c)
	--Send itself to GY, draw 3, then send 3 cards from hand to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW+CATEGORY_TOGRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160202014,160202015,160202016}

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,160202014)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,160202015)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,160202016)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(3)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
function s.ctfilter(c)
	return c:IsCode(160202014,160202015,160202016) and c:IsAbleToDeckOrExtraAsCost()
end
function s.ctcheck(sg,e,tp)
	return sg:GetClassCount(Card.GetCode)==#sg
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_GRAVE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.ctcheck,1,tp,HINTMSG_TODECK)
	Duel.HintSelection(sg)
	Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_COST)
	Duel.SortDeckbottom(tp,tp,3)
	local c=e:GetHandler()
	--Effect
	if Duel.SendtoGrave(c,REASON_EFFECT)>0 then
		if Duel.Draw(tp,3,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND,0,3,3,nil)
			Duel.SendtoGrave(dg,REASON_EFFECT)
		end
	end
end
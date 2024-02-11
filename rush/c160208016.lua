--ハーピィの羽根嵐
--Harpie's Feather Tempest
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsCode(CARD_HARPIE_LADY,160208002) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return ep==1-tp and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) end
	tc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
function s.filter(c)
	return c:IsLocation(LOCATION_DECK) and c:IsType(TYPE_NORMAL)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	if #g==0 then return end
	Duel.HintSelection(g,true)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=2 then return end
	--Effect
	local tc=eg:GetFirst()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local pg=Duel.GetMatchingGroup(Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,nil)
		if g:FilterCount(s.filter,nil)>0 and #pg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
			local g2=pg:Select(tp,1,1,nil)
			if #g2>0 then
				Duel.HintSelection(g2,true)
				Duel.ChangePosition(g2,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
			end
		end
	end
end

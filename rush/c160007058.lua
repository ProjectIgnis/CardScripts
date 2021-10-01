--海豚反撃
--Dolphin Counter

local s,id=GetID()
function s.initial_effect(c)
	--Opponent's attacking monster loses 1000 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_UMI,CARD_BIG_OCEAN}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRace(RACE_FISH+RACE_SEASERPENT)
end
function s.cfilter(c)
	return (c:IsCode(CARD_UMI) or c:IsCode(CARD_BIG_OCEAN)) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
function s.filter(c)
	return c:IsFaceup()
end
function s.umifilter(c)
	return c:IsCode(CARD_UMI) or c:IsCode(CARD_BIG_OCEAN)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(g)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		--Effect
		local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			local tg=g:GetMaxGroup(Card.GetAttack)
			if #tg>1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local sg=tg:Select(tp,1,1,nil)
				Duel.HintSelection(sg)
				if Duel.Destroy(sg,REASON_EFFECT) then 
					if Duel.Draw(tp,1,REASON_EFFECT)<1 then return end
					local dg=Duel.GetOperatedGroup()
					Duel.ConfirmCards(1-tp,dg)
					local ct=dg:FilterCount(s.umifilter,nil)
					if ct>1 then Duel.Damage(1-tp,500,REASON_EFFECT) end
				end
			else if Duel.Destroy(tg,REASON_EFFECT) then
					if Duel.Draw(tp,1,REASON_EFFECT)<1 then return end
					local dg=Duel.GetOperatedGroup()
					Duel.ConfirmCards(1-tp,dg)
					local ct=dg:FilterCount(s.umifilter,nil)
					if ct>1 then Duel.Damage(1-tp,500,REASON_EFFECT) end
				end
			end
		end
	end
end
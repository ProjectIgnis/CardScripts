--海豚反撃
--Dolphin Counterattack
local s,id=GetID()
function s.initial_effect(c)
	--Destroy a monster with the highest ATK, draw 1 card and inflict 500 damage to the opponent
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_DAMAGE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_UMI,CARD_BIG_UMI}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRace(RACE_FISH|RACE_SEASERPENT)
end
function s.cfilter(c)
	return (c:IsCode(CARD_UMI) or c:IsCode(CARD_BIG_UMI)) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,500)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(g)
	if #g==0 or Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end
	Duel.BreakEffect()
	Duel.ShuffleDeck(tp)
	--Effect
	local tg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)
	if #tg>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		tg=tg:Select(tp,1,1,nil)
		Duel.HintSelection(tg,true)
	end
	if #tg>0 then
		Duel.Destroy(tg:AddMaximumCheck(),REASON_EFFECT)
	end
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	local dg=Duel.GetOperatedGroup()
	Duel.ConfirmCards(1-tp,dg)
	if dg:FilterCount(Card.IsCode,nil,CARD_UMI,CARD_BIG_UMI)>0 then
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
	Duel.ShuffleHand(tp)
end
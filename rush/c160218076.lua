--オーバーラッシュ・ボルケーノ
--Over Rush Volcano
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	return tc and tc:IsControler(1-tp) and tc:IsLevelBelow(8) and tc:IsType(TYPE_EFFECT)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetAttack)==#sg
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
		return aux.SelectUnselectGroup(cg,e,tp,3,3,s.rescon,0)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetAttacker()
	if chk==0 then return tg:IsOnField() end
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local cg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_TODECK)
	Duel.HintSelection(cg)
	Duel.SendtoDeck(cg,nil,SEQ_DECKBOTTOM,REASON_COST)
	local g2=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
	if #g2>1 then
		Duel.SortDeckbottom(tp,tp,#g2)
	end
	--Effect
	local tc=Duel.GetAttacker()
	local tg=Group.CreateGroup()
	tg:AddCard(tc)
	tg=tg:AddMaximumCheck()
	if Duel.Destroy(tg,REASON_EFFECT)==0 then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end

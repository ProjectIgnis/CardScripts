--ＪＡＭ：Ｐキャッチ！
--JAM:P Catch!
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Change opponent's attacking monster to defense position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DAMAGE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at and at:IsControler(1-tp) and at:IsAttackPos() and at:IsOnField() and at:IsCanChangePositionRush()
end
function s.cfilter(c)
	return c:IsMonster() and c:IsRace(RACE_PSYCHIC) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,at,1,0,0)
end
function s.filter(c)
	return c:IsMonster() and c:IsRace(RACE_PSYCHIC) and c:IsType(TYPE_NORMAL)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,4,nil)
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)<=0 then return end
	Duel.ShuffleDeck(tp)
	--Effect
	local at=Duel.GetAttacker()
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if at and at:IsAttackPos() and at:IsRelateToBattle() and Duel.ChangePosition(at,POS_FACEUP_DEFENSE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil)
		and ct<6 and Duel.IsPlayerCanDraw(tp,6-ct) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Draw(tp,6-ct,REASON_EFFECT)
	end
end
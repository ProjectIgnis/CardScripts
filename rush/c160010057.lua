--妖虎東洋撃
--Yokai Tiger Orient Strike
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 of opponent's monsters lose 300 ATK per Spells in their GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(Card.IsSpellTrap,tp,0,LOCATION_GRAVE,nil)
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,ct*(-300))
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.desfilter(c)
	return c:IsFaceup() and c:HasDefense() and c:IsDefenseBelow(1600)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.HintSelection(g)
	if #g==0 or Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g==0 then return end
	Duel.HintSelection(g)
	local ct=Duel.GetMatchingGroupCount(Card.IsSpellTrap,c:GetControler(),0,LOCATION_GRAVE,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(ct*(-300))
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	g:GetFirst():RegisterEffect(e1)
	if Duel.GetMatchingGroupCount(Card.IsSpell,c:GetControler(),0,LOCATION_GRAVE,nil)>4
		and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local tg=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,1,1,nil)
		if #tg>0 then
			tg=tg:AddMaximumCheck()
			Duel.Destroy(tg,REASON_EFFECT)
		end
	end
end
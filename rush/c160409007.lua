--ギャラクティカ・ゴッドオブリビオン
--Galactica God Oblivion
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	c:RegisterFlagEffect(FLAG_TRIPLE_TRIBUTE,0,0,1)
	--Summon with 3 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,3,3,SUMMON_TYPE_TRIBUTE+1,aux.Stringid(id,0))
	--Destroy all monsters your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SUMMON_TURN) and c:GetSummonType()==SUMMON_TYPE_TRIBUTE+1
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,5,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local sg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.filter(c)
	return c:IsMonster() and c:IsType(TYPE_NORMAL)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,5,5,nil)
	Duel.HintSelection(g,true)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)<1 then return end
	--Effect
	local sg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if Duel.Destroy(sg,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
		if #g==0 then return end
		local atk=g:GetMaxGroup(Card.GetAttack):GetFirst():GetAttack()
		if atk>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local c=e:GetHandler()
			--Gain ATK
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
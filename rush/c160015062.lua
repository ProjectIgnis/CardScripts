--フィッシャーチャージ (Rush)
--Fish Depth Charge (Rush)
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 card on your opponent's field then draw 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spellcondition)
	c:RegisterEffect(e3)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.costfilter(c)
	return c:IsRace(RACE_FISH) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
	sg=sg:AddMaximumCheck()
	local ct=Duel.SendtoGrave(sg,REASON_COST)
	if ct>0 then
		--Effect
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		if #g==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=g:Select(tp,1,1,nil)
		if #dg>0 then
			Duel.HintSelection(dg,true)
			dg=dg:AddMaximumCheck()
			if Duel.Destroy(dg,REASON_EFFECT)>0 then
				Duel.BreakEffect()
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
function s.spellcondition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsSpellEffect() and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
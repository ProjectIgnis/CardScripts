--スペース・バドエクスプロイト
--Space Bud Exploit
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- atk + damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160211020}
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsLevelAbove(7)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,500)
end
function s.setfilter(c)
	return c:IsCode(160211020) and c:IsSSetable()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,nil)
	if Duel.Damage(1-tp,500,REASON_EFFECT)>0 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=g2:Select(tp,1,1,nil)
		Duel.BreakEffect()
		Duel.SSet(tp,sg)
	end
end
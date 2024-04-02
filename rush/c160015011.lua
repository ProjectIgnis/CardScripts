--幻壊兵アシバ・ビッケ
--Demolition Soldier Ashiba Bikke
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Mill
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCountRush(tp,LOCATION_MZONE,0)<=2
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WYRM)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,nil)*2
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,nil)*2
	Duel.DiscardDeck(tp,ct,REASON_EFFECT)
	local ct=Duel.GetOperatedGroup():Filter(Card.IsMonster,nil):GetCount()
	if ct>=2 and c:CanBeDoubleTribute(FLAG_DOUBLE_TRIB_WYRM) then
		c:AddDoubleTribute(id,s.otfilter,s.eftg,RESETS_STANDARD_PHASE_END,FLAG_DOUBLE_TRIB_WYRM)
	end
end
function s.otfilter(c,tp)
	return c:IsDoubleTribute(FLAG_DOUBLE_TRIB_WYRM) and (c:IsControler(tp) or c:IsFaceup())
end
function s.eftg(e,c)
	return c:IsRace(RACE_WYRM) and c:IsLevelAbove(7) and c:IsSummonableCard()
end
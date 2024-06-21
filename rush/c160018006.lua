--ダークマター・ドラゴン
--Dark Matter Dragon
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Destroy monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN|STATUS_SPSUMMON_TURN)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and not c:IsMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 and #g2>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,LOCATION_MZONE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 and #g2>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		sg=g2:Select(tp,1,#g,nil)
		sg=sg:AddMaximumCheck()
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

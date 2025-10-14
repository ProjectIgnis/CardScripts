--反攻の竜撃
--Vengeful Dragon's Counterattack
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 card on your opponent's field then draw 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousRaceOnField()&RACE_DRAGON==RACE_DRAGON
		and c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsPlayerAffectedByEffect(tp,160023004) or Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) 
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #dg>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,LOCATION_MZONE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if not Duel.IsPlayerAffectedByEffect(tp,160023004) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
		Duel.SendtoGrave(g,REASON_COST)
	end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_MZONE,nil)
	if #dg>0 then
		local sg=dg:Select(tp,1,1,nil)
		local sg2=sg:AddMaximumCheck()
		Duel.HintSelection(sg2)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
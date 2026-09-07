--羊界のおやすみ
--Wooly Wonderland Naptime
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--If opponent normal summons or special summons, inflict damage
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.filter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanChangePositionRush()
end
function s.tgfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsRace(RACE_BEAST) and c:IsType(TYPE_NORMAL|TYPE_MAXIMUM)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
	local ct=Duel.GetOperatedGroup():FilterCount(s.tgfilter,nil)
	local sg=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if ct>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local sc=sg:Select(tp,1,ct,nil)
		if #sc==0 then return end
		Duel.HintSelection(sc)
		Duel.BreakEffect()
		Duel.ChangePosition(sc,POS_FACEDOWN_DEFENSE,0,POS_FACEDOWN_DEFENSE,0)
	end
end
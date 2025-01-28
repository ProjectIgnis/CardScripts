--夙めてはしろ 二人ではしろ
--Do it Early, Do it Together
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Your opponent banishes 7 cards from their Extra Deck and/or the top of their Deck, face-down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(s.rmcon)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(tp,7)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==7 end
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local p=1-tp
		local dg=Duel.GetDecktopGroup(p,7)
		local exg=Duel.GetFieldGroup(p,LOCATION_EXTRA,0)
		return (dg+exg):IsExists(Card.IsAbleToRemove,7,nil,p,POS_FACEDOWN,REASON_EFFECT)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,7,1-tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local p=1-tp
	local rg=nil
	local exg=Duel.GetMatchingGroup(Card.IsAbleToRemove,p,LOCATION_EXTRA,0,nil,p,POS_FACEDOWN,REASON_EFFECT)
	if #exg>0 then
		local min=math.max(0,7-Duel.GetFieldGroupCount(p,LOCATION_DECK,0))
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_REMOVE)
		rg=exg:Select(p,min,7,nil)
		rg:Merge(Duel.GetDecktopGroup(p,7-#rg))
	else
		rg=Duel.GetDecktopGroup(p,7)
	end
	if #rg>0 then
		Duel.DisableShuffleCheck()
		Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT,nil,p)
	end
end
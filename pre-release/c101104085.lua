--Terrors of the Underroot
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_REMOVED,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,0,LOCATION_REMOVED,nil,e)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,#g,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_REMOVED,#g1,#g1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,#g1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g2,#g2,0,0)
end
function s.cfilter1(c,e)
	return c:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e)
end
function s.cfilter2(c,e)
	return c:IsLocation(LOCATION_REMOVED) and c:IsRelateToEffect(e)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=g:Filter(s.cfilter1,nil,e)
	local sg=g:Filter(s.cfilter2,nil,e)
	if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		if #sg>0 and og:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
		end
	end
end
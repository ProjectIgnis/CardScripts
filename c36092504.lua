--ベイオネット・パニッシャー
--Bayonet Punisher
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x10f}
function s.cfilter(c)
	return c:IsSetCard(0x10f) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
end
function s.exfilter(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown()
end
function s.stfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsOnField()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_EXTRA,nil)
	local bf=g:IsExists(Card.IsType,1,nil,TYPE_FUSION) and rg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
	local bs=g:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO) and rg:IsExists(s.exfilter,3,nil)
	local bx=g:IsExists(Card.IsType,1,nil,TYPE_XYZ) and rg:IsExists(s.stfilter,1,nil)
	local bl=g:IsExists(Card.IsType,1,nil,TYPE_LINK) and rg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
	if chk==0 then return bf or bs or bx or bl end
	local loc=0
	local ct=0
	if bf then loc,ct=loc|LOCATION_MZONE,ct+1 end
	if bs then loc,ct=loc|LOCATION_EXTRA,ct+3 end
	if bx then loc,ct=loc|LOCATION_ONFIELD,ct+1 end
	if bl then loc,ct=loc|LOCATION_GRAVE,ct+1 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,loc)
	if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsAttackAbove,3000),tp,LOCATION_MZONE,0,1,nil) then
		Duel.SetChainLimit(s.chlimit)
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_EXTRA,nil)
	local og=Group.CreateGroup()
	if g:IsExists(Card.IsType,1,nil,TYPE_FUSION) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		og:Merge(rg:FilterSelect(tp,Card.IsLocation,1,1,og,LOCATION_MZONE))
	end
	if g:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		og:Merge(rg:Filter(s.exfilter,og):RandomSelect(tp,3))
	end
	if g:IsExists(Card.IsType,1,nil,TYPE_XYZ) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		og:Merge(rg:FilterSelect(tp,s.stfilter,1,1,og))
	end
	if g:IsExists(Card.IsType,1,nil,TYPE_LINK) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		og:Merge(rg:FilterSelect(tp,Card.IsLocation,1,3,og,LOCATION_GRAVE))
	end
	if #og>0 then
		Duel.Remove(og,POS_FACEUP,REASON_EFFECT)
	end
end


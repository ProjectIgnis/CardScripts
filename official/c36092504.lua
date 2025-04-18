--ベイオネット・パニッシャー
--Bayonet Punisher
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_BORREL}
function s.cfilter(c)
	return c:IsSetCard(SET_BORREL) and c:IsFaceup() and c:IsMonster() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
function s.exfilter(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown()
end
function s.stfilter(c)
	return c:IsSpellTrap() and c:IsOnField()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_EXTRA,nil)
	local bf=g:IsExists(Card.IsType,1,nil,TYPE_FUSION) and rg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
	local bs=g:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO) and rg:IsExists(s.exfilter,3,nil)
	local bx=g:IsExists(Card.IsType,1,nil,TYPE_XYZ) and rg:IsExists(s.stfilter,1,nil)
	local bl=g:IsExists(Card.IsType,1,nil,TYPE_LINK) and rg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
	if chk==0 then return bf or bs or bx or bl end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_EXTRA)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttackAbove,3000),tp,LOCATION_MZONE,0,1,nil) then
		Duel.SetChainLimit(s.chlimit)
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	if #g==0 then return end
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_EXTRA,nil)
	if #rg==0 then return end
	local og=Group.CreateGroup()
	local break_chk=0
	if g:IsExists(Card.IsType,1,nil,TYPE_FUSION) and rg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then
		--Fusion: Banish 1 monster the opponent controls
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		og=rg:FilterSelect(tp,Card.IsLocation,1,1,nil,LOCATION_MZONE)
		Duel.HintSelection(og,true)
		break_chk=Duel.Remove(og,POS_FACEUP,REASON_EFFECT)
	end
	if g:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO) and rg:IsExists(s.exfilter,3,nil) then
		--Synchro: Banish 3 random face-down cards from the opponent's Extra Deck
		if break_chk>0 then Duel.BreakEffect() end
		og=rg:Filter(s.exfilter,nil):RandomSelect(tp,3)
		Duel.HintSelection(og,true)
		break_chk=Duel.Remove(og,POS_FACEUP,REASON_EFFECT)
	end
	if g:IsExists(Card.IsType,1,nil,TYPE_XYZ) and rg:IsExists(s.stfilter,1,nil) then
		--Xyz: Banish 1 Spell/Trap the opponent controls
		if break_chk>0 then Duel.BreakEffect() end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		og=rg:FilterSelect(tp,s.stfilter,1,1,nil)
		Duel.HintSelection(og,true)
		break_chk=Duel.Remove(og,POS_FACEUP,REASON_EFFECT)
	end
	if g:IsExists(Card.IsType,1,nil,TYPE_LINK) and rg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		--Link: Banish up to 3 cards in the opponent's GY
		if break_chk>0 then Duel.BreakEffect() end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		og=rg:FilterSelect(tp,Card.IsLocation,1,3,nil,LOCATION_GRAVE)
		Duel.HintSelection(og,true)
		Duel.Remove(og,POS_FACEUP,REASON_EFFECT)
	end
end
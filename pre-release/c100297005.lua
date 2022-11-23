--表裏一体
--Duality
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 monster from Hand or Extra Deck with the same original Type and Level
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetLabel(0)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Shuffle 1 LIGHT and 1 DARK monster into the Deck and draw 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.cfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_LIGHT)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_EXTRA,0,1,nil,e,tp,c:GetOriginalRace(),c:GetOriginalLevel(),c:GetOriginalAttribute())
end
function s.spfilter(c,e,tp,race,lvl,att)
	return c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_LIGHT) and c:IsOriginalRace(race) and c:GetOriginalLevel()==lvl and not c:IsOriginalAttribute(att)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and ((c:IsLocation(LOCATION_HAND) and Duel.GetMZoneCount(tp,c)>0) or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rc=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,e,tp):GetFirst()
	e:SetLabel(rc:GetOriginalRace(),rc:GetOriginalLevel(),rc:GetOriginalAttribute())
	Duel.Release(rc,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local race,lvl,att=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_EXTRA,0,1,1,nil,e,tp,race,lvl,att)
	if #g>0 then 
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.tdfilter(c,e)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_LIGHT)
		and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_DARK)>0 and sg:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_LIGHT)>0
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and #rg>1
		and aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0) end
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg~=2 or Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)~=2 then return end
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
	if ct==2 and Duel.IsPlayerCanDraw(tp) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
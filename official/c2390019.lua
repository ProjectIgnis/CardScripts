--おジャマ改造
--Ojamassimilation
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon Fusion Materials
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Shuffle "Ojama" monsters into the deck and draw 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_OJAMA}
function s.ffilter(c,e,tp,rg,ft)
	if not (c.material and c:IsType(TYPE_FUSION)) then return false end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,e,tp,c.material)
	return #g>0 and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
		and aux.SelectUnselectGroup(rg,e,tp,nil,1,s.rescon1(g,ft),0)
end
function s.cfilter(c)
	return c:IsSetCard(SET_OJAMA) and c:IsMonster() and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c,true,true))
end
function s.spfilter(c,e,tp,codes)
	return c:IsCode(codes) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon1(g,ft)
	return	function(sg,e,tp,mg)
				local ct=#sg
				return ft+sg:FilterCount(Card.IsInMainMZone,nil,tp)>=ct and aux.SelectUnselectGroup(g-sg,e,tp,ct,ct,s.rescon2,0)
			end
end
function s.rescon2(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)>=#sg
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return ft>-1 and #rg>0 and Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,rg,ft)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,rg,ft):GetFirst()
	Duel.ConfirmCards(1-tp,rc)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,e,tp,rc.material)
	local maxc=math.min((Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and 1 or 5),rc.material_count)
	local g=aux.SelectUnselectGroup(rg,e,tp,nil,maxc,s.rescon1(sg,ft),1,tp,HINTMSG_REMOVE,s.rescon1(sg,ft))
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	local ct=#g
	Duel.SetTargetCard(rc)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local rc=Duel.GetFirstTarget()
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=math.min(ft,1) end
	if not rc or ct>ft then return end
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,nil,e,tp,rc.material)
	local g=aux.SelectUnselectGroup(mg,e,tp,ct,ct,s.rescon2,1,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
function s.tdfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_OJAMA) and c:IsAbleToDeck()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,3,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
	if ct>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
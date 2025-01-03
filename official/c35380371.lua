--氷結界に至る晶域
--Frozen Domain of the Ice Barrier
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Your opponent cannot activate effects in response to the effects of your "Ice Barrier" monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.chainop)
	c:RegisterEffect(e2)
	--Return 1 "Ice Barrier" monster the hand/Deck and can place 1 card on the field/GY on the bottom of the Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e,tp,eg) return eg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_EXTRA) end)
	e3:SetTarget(s.rettg)
	e3:SetOperation(s.retop)
	c:RegisterEffect(e3)
	--Reveal 3 "Ice Barrier" monsters or destroy this card
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e4:SetTarget(s.selfdestg)
	e4:SetOperation(s.selfdesop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_ICE_BARRIER}
function s.chfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(SET_ICE_BARRIER) and c:IsControler(tp)
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep==tp and re:IsMonsterEffect() and rc:IsSetCard(SET_ICE_BARRIER) then
		Duel.SetChainLimit(function(_e,_rp,_tp) return _tp==_rp end)
	end
end
function s.icefilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_ICE_BARRIER) and (c:IsAbleToHand() or c:IsAbleToDeck())
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.icefilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_EITHER,LOCATION_ONFIELD|LOCATION_GRAVE)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,s.icefilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc,true)
	local b1=sc:IsAbleToHand()
	local b2=sc:IsAbleToDeck()
	local op=0
	if sc:IsAbleToExtra() then
		op=2
	else
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,3)},
			{b2,aux.Stringid(id,4)})
	end
	local func=nil
	local params={}
	local shuffle_func=nil
	if op==1 then
		func=Duel.SendtoHand
		params={nil,REASON_EFFECT}
		shuffle_func=Duel.ShuffleHand
	elseif op==2 then
		func=Duel.SendtoDeck
		params={nil,SEQ_DECKSHUFFLE,REASON_EFFECT}
		shuffle_func=Duel.ShuffleDeck
	end
	if func(sc,table.unpack(params))==0 or not sc:IsLocation(LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA) then return end
	if not sc:IsLocation(LOCATION_EXTRA) then shuffle_func(tp) end
	local rg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,nil)
	if #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=rg:Select(tp,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g,true)
			Duel.BreakEffect()
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
function s.selfdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,LOCATION_SZONE)
end
function s.rvlfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_ICE_BARRIER) and not c:IsPublic()
end
function s.selfdesop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rvlfilter,tp,LOCATION_EXTRA,0,nil)
	if #g>=3 and aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,0) and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
		local rvg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_CONFIRM)
		Duel.ConfirmCards(1-tp,rvg)
		Duel.ShuffleExtra(tp)
	else
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
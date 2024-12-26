--ライゼオル・クロス
--Ryzeal Cross
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--You cannot Xyz Summon monsters with the same name as a card you control
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.xyzlimit)
	c:RegisterEffect(e1)
	--Place 2 "Ryzeal" cards from your GY on the bottom of the Deck then draw 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--Detach 1 material from a "Ryzeal" Xyz Monster you control, and if you do, negate an opponent's activated monster effect when it resolves
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.negcon)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_RYZEAL}
s.listed_names={id}
function s.xyzlimit(e,c,sump,sumtyp)
	return (sumtyp&SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,c:GetCode()),sump,LOCATION_ONFIELD,0,1,nil)
end
function s.tdfilter(c)
	return c:IsSetCard(SET_RYZEAL) and c:IsAbleToDeck() and not c:IsCode(id)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 or Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)==0 then return end
	local dg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
	if #dg==0 then return end
	local ct=dg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if ct>1 then
		Duel.SortDeckbottom(tp,tp,ct)
	end
	if Duel.IsPlayerCanDraw(tp) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function s.xyzfilter(c)
	return c:IsSetCard(SET_RYZEAL) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0 and c:IsFaceup()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
	return rp==1-tp and re:IsMonsterEffect() and Duel.IsChainDisablable(ev) and not e:GetHandler():HasFlagEffect(id)
		and #g>0 and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT,g)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if not (Duel.GetFlagEffectLabel(tp,id)~=cid and #g>0 and Duel.SelectEffectYesNo(tp,c)) then return end
	Duel.Hint(HINT_CARD,0,id)
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT,g)
	Duel.NegateEffect(ev)
	c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1,cid)
end
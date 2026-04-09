--絶境なる獄神域－ヴィライア
--Dead-End Power Patron Realm - Viraia
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Show 1 "Nerva the Power Patron of Creation", 1 "Jupiter the Power Patron of Destruction", and 1 "Junora the Power Patron of Tuning" from your Extra Deck, face-up field, and/or GY, and if you do, your opponent cannot activate cards or effects in response the activation of your "Power Patron" monsters' effects this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE)
	c:RegisterEffect(e1)
	--If you would banish the top card(s) of your Deck to activate the effect of a "Power Patron" monster you control, you can banish this card from your GY instead
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_POWER_PATRON_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTargetRange(1,0)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():IsAbleToRemoveAsCost() end)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
s.listed_names={53589300,68231287,5914858} --"Nerva the Power Patron of Creation", "Jupiter the Power Patron of Destruction", "Junora the Power Patron of Tuning"
s.listed_series={SET_POWER_PATRON}
function s.showfilter(c)
	return c:IsCode(53589300,68231287,5914858) and (c:IsFaceup() or not c:IsOnField())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.showfilter,tp,LOCATION_EXTRA|LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)
		return g:GetClassCount(Card.GetCode)>=3
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.showfilter,tp,LOCATION_EXTRA|LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)
	if #g>=3 then
		local rg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_CONFIRM)
		local fieldgraveg,extrag=rg:Split(Card.IsLocation,nil,LOCATION_ONFIELD|LOCATION_GRAVE)
		if #fieldgraveg>0 then Duel.HintSelection(fieldgraveg) end
		if #extrag>0 then Duel.ConfirmCards(1-tp,extrag) end
		if rg:IsExists(Card.IsLocation,1,nil,LOCATION_EXTRA) then Duel.ShuffleExtra(tp) end
		local c=e:GetHandler()
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1))
		--Your opponent cannot activate cards or effects in response the activation of your "Power Patron" monsters' effects this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.inactop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.inactop(e,tp,eg,ep,ev,re,r,rp)
	if ep==1-tp then return end
	local trig_typ,trig_setcodes=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_TYPE,CHAININFO_TRIGGERING_SETCODES)
	if trig_typ&TYPE_MONSTER~=TYPE_MONSTER then return end
	for _,setcode in ipairs(trig_setcodes) do
		if (SET_POWER_PATRON&0xfff)==(setcode&0xfff) and (SET_POWER_PATRON&setcode)==SET_POWER_PATRON then
			return Duel.SetChainLimit(function(e,rp,tp) return rp==tp end)
		end
	end
end
function s.repval(base,e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	return c:IsSetCard(SET_POWER_PATRON) and c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function s.repop(base,e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Remove(base:GetHandler(),POS_FACEUP,REASON_COST)
end
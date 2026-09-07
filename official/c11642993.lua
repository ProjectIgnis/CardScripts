--Ｓ－Ｆｏｒｃｅ ソート・ワールド
--S-Force World Sorting
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e0)
	--If you would banish a card(s) from the hand to activate the effect of an "S-Force" monster you control, you can send 1 "S-Force" card from your Deck to the GY instead, except "S-Force Sorted World"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_COST_REPLACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.repcon)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
	--If another card(s) is banished: You can target 1 card in your opponent's field or GY; banish it, then you can move 1 "S-Force" monster you control to another of your Main Monster Zones
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg) return eg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) end)
	e2:SetTarget(s.bantg)
	e2:SetOperation(s.banop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_S_FORCE}
function s.repcostfilter(c,extracon,base,e,tp,eg,ep,ev,re,r,rp)
	return c:IsSetCard(SET_S_FORCE) and not c:IsCode(id) and c:IsAbleToGraveAsCost()
		and (not extracon or extracon(base,e,tp,eg,ep,ev,re,r,rp,c))
end
function s.repcon(e)
	return Duel.IsExistingMatchingCard(s.repcostfilter,e:GetHandlerPlayer(),LOCATION_DECK,0,1,nil)
end
function s.repval(base,extracon,e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(SET_S_FORCE)
			and Duel.IsExistingMatchingCard(s.repcostfilter,tp,LOCATION_DECK,0,1,nil,extracon,base,e,tp,eg,ep,ev,re,r,rp)
	end
	return Chain.IsTriggeringControler(0,tp) and Chain.IsTriggeringLocation(0,LOCATION_MZONE)
		and Chain.IsTriggeringPosition(0,POS_FACEUP) and Chain.IsTriggeringSetcode(0,SET_S_FORCE)
		and Duel.IsExistingMatchingCard(s.repcostfilter,tp,LOCATION_DECK,0,1,nil,extracon,base,e,tp,eg,ep,ev,re,r,rp)
end
function s.repop(base,extracon,e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.repcostfilter,tp,LOCATION_DECK,0,1,1,nil,extracon,base,e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD|LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_S_FORCE),tp,LOCATION_MZONE,0,nil)
		if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if not sc then return end
		Duel.HintSelection(sc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		local zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		Duel.BreakEffect()
		if tc:IsImmuneToEffect(e) then return end
		Duel.MoveSequence(sc,math.log(zone,2))
	end
end

--獄神封門－共滅の剣－
--Power Patron Portal Plugging -Sword of Mutual Destruction-
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Discard 1 "Power Patron" card; place 1 "Power Patron" Pendulum Monster from your Extra Deck in your Pendulum Zone, then if it is a Fusion Monster, you can place 1 "Power Patron" Pendulum Monster from your Deck in your Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.Discard(function(c)
		return c:IsSetCard(SET_POWER_PATRON)
	end,true))
	e1:SetTarget(s.pendtg)
	e1:SetOperation(s.pendop)
	e1:SetValue(s.availablezones)
	c:RegisterEffect(e1)
	--If you control a "Power Patron" monster: You can banish this card from your GY, then target 1 face-up monster on the field; it gains 1500 ATK, also it cannot attack this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_POWER_PATRON),tp,LOCATION_MZONE,0,1,nil)
	end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_POWER_PATRON}
function s.availablezones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff --all S/T zones
	local left_pend=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	local right_pend=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	if left_pend and right_pend then
		return zone
	elseif left_pend then
		--Remove the left-most Spell & Trap Zone
		zone=zone-0x1
	elseif right_pend then
		--Remove the right-most Spell & Trap Zone
		zone=zone-0x10
	end
	return zone
end
function s.plfilter(c)
	return c:IsSetCard(SET_POWER_PATRON) and c:IsPendulumMonster() and not c:IsForbidden()
end
function s.pendtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
function s.pendop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local pend_from_extra=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if pend_from_extra and Duel.MoveToField(pend_from_extra,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		and pend_from_extra:IsOriginalType(TYPE_FUSION) and Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local pend_from_main=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if pend_from_main then
			Duel.BreakEffect()
			Duel.MoveToField(pend_from_main,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local tc=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,tp,1500)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local c=e:GetHandler()
		if tc:IsFaceup() then
			--It gains 1500 ATK
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1500)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		--Also it cannot attack this turn
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3206)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
	end
end
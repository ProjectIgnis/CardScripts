--超重機回送
--Heavy Forward
--Scripted by King Yamato
local s,id=GetID()
function s.initial_effect(c)
	--Add to Hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Change position or attach as material
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(s.opttarget)
	e2:SetOperation(s.opteffect)
	c:RegisterEffect(e2)
end
s.listed_series={0x127}

-- Infinitrack monster
function s.filter(c,e,tp)
	return c:IsSetCard(0x127) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

-- Add to hand
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

-- Machine-type Xyz monster
function s.optfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE)
end

-- Target 1 Machine-type Xyz monster and activate one of those effects
function s.opttarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.optfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.optfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.optfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local op=0
	if tc:GetFirst():IsCanChangePosition() then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,2))
	end
	e:SetLabel(op)
end

-- Execute chosen effect
function s.opteffect(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not e:GetHandler():IsRelateToEffect(e) or not tc:IsRelateToEffect(e)
		or tc:IsImmuneToEffect(e) then return end

	local op=e:GetLabel()
	if op~=1 then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
	if op~=0 then
		Duel.Overlay(tc,Group.FromCards(e:GetHandler()))
	end
end


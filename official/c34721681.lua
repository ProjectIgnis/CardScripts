--超重機回送
--Heavy Forward
--Scripted by King Yamato
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Infinitrack" monster from Deck to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Change position or attach as material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(s.opttarget)
	e2:SetOperation(s.opteffect)
	c:RegisterEffect(e2)
end
s.listed_series={SET_INFINITRACK}
-- Infinitrack monster
function s.filter(c,e,tp)
	return c:IsSetCard(SET_INFINITRACK) and c:IsMonster() and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp) -- Add to hand
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- Machine Xyz Monster
function s.optfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE)
end
-- Target 1 Machine Xyz Monster and activate one of those effects
function s.opttarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.optfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.optfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.optfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local op=Duel.SelectEffect(tp,
		{tc:GetFirst():IsCanChangePosition(),aux.Stringid(id,2)},
		{e:GetHandler():IsCanBeXyzMaterial(tc,tp,REASON_EFFECT),aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_POSITION)
	else
		e:SetCategory(0)
	end
end
-- Execute chosen effect
function s.opteffect(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	if e:GetLabel()==1 then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	else
		if c:IsCanBeXyzMaterial(tc,tp,REASON_EFFECT) then
			Duel.Overlay(tc,c)
		end
	end
end


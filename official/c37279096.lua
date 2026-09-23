--無垢なる芸術－「黄昏の変幻」
--Ars Magna - "Citrinitas"
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--You can activate the effects of monsters you control with "Ars Magna" in their original names as Quick Effects while you control a "Power Patron" Link Monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_ARS_MAGNA_CITRINITAS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.effcon)
	e1:SetTargetRange(1,0)
	c:RegisterEffect(e1)
	--Once while face-up on the field: You can add 1 "Medius" or "Ars Magna" monster from your Deck to your hand. You can only use this effect of "Ars Magna - "Citrinitas"" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ARTMAGE,SET_DOOMZ,SET_ELFNOTE,SET_ARS_MAGNA,SET_POWER_PATRON,SET_MEDIUS}
function s.powerpatronfilter(c)
	return c:IsSetCard(SET_POWER_PATRON) and c:IsLinkMonster() and c:IsFaceup()
end
function s.effcon(e)
	return Duel.IsExistingMatchingCard(s.powerpatronfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.thfilter(c)
	return c:IsSetCard({SET_MEDIUS,SET_ARS_MAGNA}) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
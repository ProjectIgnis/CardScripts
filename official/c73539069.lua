--ストライカー・ドラゴン
--Striker Dragon
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,s.matfilter,1,1)
	--Add 1 "Boot Sector Launch" from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Destroy 1 face-up monster you control and add 1 "Rokket" monster from your GY to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_names={36668118} --"Boot Sector Launch"
s.listed_series={SET_ROKKET}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_DRAGON,scard,sumtype,tp)
end
function s.dthfilter(c)
	return c:IsCode(36668118) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dthfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.dthfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.gythfilter(c)
	return c:IsSetCard(SET_ROKKET) and c:IsMonster() and c:IsAbleToHand()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(s.gythfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local hg=Duel.SelectTarget(tp,s.gythfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,hg,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local dg,hg=tg:Split(Card.IsLocation,nil,LOCATION_MZONE)
	if #dg>0 and Duel.Destroy(dg,REASON_EFFECT)>0 and #hg>0 then
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
	end
end
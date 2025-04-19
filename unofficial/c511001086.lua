--食罪庫
--Food Cemetery
local s,id=GetID()
function s.initial_effect(c)
	--Place "Cookpal" monsters under this card and add "Cookpal" monsters to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Destroy all cards you control
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_series={0x512} --"Cookpal" archetype
function s.cfilter(c,tid)
	return c:IsSetCard(0x512) and c:IsMonster() and c:GetTurnID()==tid and not c:IsReason(REASON_RETURN)
end
function s.thfilter(c)
	return c:IsSetCard(0x512) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil,Duel.GetTurnCount())
	local ct=#g
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,ct,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil,Duel.GetTurnCount())
	if #g>0 then
		Duel.Overlay(c,g)
		local ct=c:GetOverlayCount()
		if ct>0 then
			local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,ct,ct,nil)
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetOverlayCount()
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>ct then
		Duel.Hint(HINT_CARD,0,id)
		local sg=Duel.GetMatchingGroup(Card.IsDestructable,tp,LOCATION_ONFIELD,0,nil)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
--魁炎星－シーブ
--Brotherhood of the Fire Fist - Ram
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--When normal summoned, set 1 "Fire Formation" spell/trap from deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--If special summoned by effect of a "Fire Fist" monster, set 1 "Fire Formation" spell/trap from deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.setcon2)
	e2:SetTarget(s.settg2)
	e2:SetOperation(s.setop2)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FIRE_FORMATION,SET_FIRE_FIST}
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
end
function s.setfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_FIRE_FORMATION) and c:IsSpellTrap()
		and Duel.IsExistingMatchingCard(s.setfilter2,tp,LOCATION_DECK,0,1,nil,c)
end
function s.setfilter2(c,tc)
	return c:IsSetCard(SET_FIRE_FORMATION) and c:IsSpellTrap() and not c:IsCode(tc:GetCode()) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and s.setfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter2,tp,LOCATION_DECK,0,1,1,nil,tc)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
function s.setcon2(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsMonsterEffect() and re:GetHandler():IsSetCard(SET_FIRE_FIST)
end
function s.setfilter3(c,tp)
	return c:IsSetCard(SET_FIRE_FORMATION) and c:IsSpellTrap() and c:IsSSetable()
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function s.settg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter3,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.setop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter3,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
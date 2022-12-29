--閃刀姫-シズク
--Sky Striker Ace - Shizuku
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--Decrease opponent's monster's ATK/DEF by 100
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Register a flag when it is special summoned
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	--Add 1 "Sky Striker" Spell from Deck to the hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id)~=0 end)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_SKY_STRIKER}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(SET_SKY_STRIKER_ACE,scard,sumtype,tp) and c:IsAttribute(ATTRIBUTE_ALL-ATTRIBUTE_WATER,scard,sumtype,tp)
end
function s.atkval(e)
	return Duel.GetMatchingGroupCount(Card.IsSpell,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)*-100
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.thfilter(c,tp)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsSpell() and c:IsAbleToHand()
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
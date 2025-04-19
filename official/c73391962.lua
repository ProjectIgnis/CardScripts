--告死聖徒ルシエラーゴ
--Azamina Mu Rcielago
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 Illusion monster + 1 LIGHT Spellcaster monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ILLUSION),s.matfilter)
	--Monsters your opponent controls lose 500 ATK/DEF for each "Azamina" monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(function(e,c) return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_AZAMINA),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*-500 end)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Add 1 "Azamina" or "Sinful Spoils" card from your Deck to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--Add 1 "Sinful Spoils" Spell from your Deck to your hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return r&(REASON_BATTLE|REASON_EFFECT)>0 end)
	e4:SetTarget(s.desthtg)
	e4:SetOperation(s.desthop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_AZAMINA,SET_SINFUL_SPOILS}
function s.matfilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT,fc,sumtype,tp) and c:IsRace(RACE_SPELLCASTER,fc,sumtype,tp)
end
function s.thfilter(c,tp)
	return c:IsSetCard({SET_AZAMINA,SET_SINFUL_SPOILS}) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.desthfilter(c)
	return c:IsSetCard(SET_SINFUL_SPOILS) and c:IsSpell() and c:IsAbleToHand()
end
function s.desthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desthfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.desthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.desthfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--サイバー・アルサーフィ
--Cyber Alsafi
--scripted by Naim
local s,id=GetID()
local CARD_BORN_FROM_DRACONIS=96699830
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must first be Special Summoned (from your hand) if you control a Machine "Cyber" monster
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)
	--If this card is Special Summoned: You can add 1 "Born from Draconis" from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--If this card is banished: You can activate this effect; until the end of your turn, the next battle damage your Level 10 LIGHT Machine monster inflicts to your opponent is doubled
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_BORN_FROM_DRACONIS}
s.listed_series={SET_CYBER}
function s.spconfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsSetCard(SET_CYBER) and c:IsFaceup()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.thfilter(c)
	return c:IsCode(CARD_BORN_FROM_DRACONIS) and c:IsAbleToHand()
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
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return end
	local c=e:GetHandler()
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END|RESET_SELF_TURN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	--Until the end of your turn, the next battle damage your Level 10 LIGHT Machine monster inflicts to your opponent is doubled
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c)
		return c:IsLevel(10) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
	end)
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	e1:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN)
	Duel.RegisterEffect(e1,tp)
	--Manually reset e1 when your Level 10 LIGHT Machine monster inflicts damage to your opponent
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local bc=eg:GetFirst()
		if ep==1-tp and bc:IsLevel(10) and bc:IsAttribute(ATTRIBUTE_LIGHT) and bc:IsRace(RACE_MACHINE)
			and bc:IsControler(tp) then
			e1:Reset()
			e:Reset()
		end
	end)
	e2:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN)
	Duel.RegisterEffect(e2,tp)
end
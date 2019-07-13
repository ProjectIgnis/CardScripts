--Cubic Karma (movie)
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.condition0)
	e2:SetCost(s.cost0)
	e2:SetTarget(s.target0)
	e2:SetOperation(s.operation0)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_VIJAM}
function s.filter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsSetCard(0xe3)
end
function s.filter2(c)
	return c:IsCode(CARD_VIJAM)
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil) and Duel.GetMatchingGroupCount(s.filter2,tp,LOCATION_HAND,0,nil)~=0 end
	local tg=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetTargetCard(tg)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local mg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_HAND,0,nil)
	if #mg==0 then return end
	Duel.Overlay(tc,mg)
end
function s.filter3(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCubicSeed()
end
function s.condition0(e,tp,eg,ev,ep,re,r,rp)
	return eg:IsExists(s.filter3,1,nil,tp) and re:GetHandler():IsType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0xe3) and Duel.GetTurnPlayer()~=tp
end
function s.cost0(e,tp,eg,ev,ep,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.target0(e,tp,eg,ev,ep,re,r,rp,chk)
	if chk==0 then return true end
end
function s.operation0(e,tp,eg,ev,ep,re,r,rp)
	local lp=Duel.GetLP(1-tp)
	Duel.SetLP(1-tp,math.floor(lp/2))
end
--CARD_VIJAM vijam
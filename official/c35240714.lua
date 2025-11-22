--セイバー・コンビネーション
--Saber Combination
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--While you have 10 or more "X-Saber" monsters in your field, GY, and/or banishment, "X-Saber" monsters you control gain ATK equal to their own original DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(function(e,c) return c:IsSetCard(SET_X_SABER) end)
	e1:SetValue(function(e,c) return c:GetBaseDefense() end)
	c:RegisterEffect(e1)
	--Special Summon 1 "X-Saber" monster from your hand or Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.handdeckspcon)
	e2:SetTarget(s.sptg(LOCATION_HAND|LOCATION_DECK))
	e2:SetOperation(s.spop(LOCATION_HAND|LOCATION_DECK))
	c:RegisterEffect(e2)
	--Special Summon 1 "X-Saber" monster from your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	e3:SetTarget(s.sptg(LOCATION_HAND))
	e3:SetOperation(s.spop(LOCATION_HAND))
	c:RegisterEffect(e3)
end
s.listed_series={SET_X_SABER}
function s.atkfilter(c)
	return c:IsSetCard(SET_X_SABER) and c:IsMonster() and c:IsFaceup()
end
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0,10,nil)
end
function s.handdeckspconfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSetCard(SET_X_SABER) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsFaceup()
end
function s.handdeckspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.handdeckspconfilter,1,nil,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_X_SABER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(location)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,location,0,1,nil,e,tp) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
	end
end
function s.spop(location)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,location,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
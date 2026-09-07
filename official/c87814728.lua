--磁石の戦士Σ－
--Magnet Warrior Sigma Minus
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Negate an attack involving 2 EARTH monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.atknegcon)
	e1:SetOperation(function() Duel.NegateAttack() end)
	c:RegisterEffect(e1)
	--Fusion Summon 1 Fusion Monster from your Extra Deck, using Rock monsters from your hand or field, including this card in your hand
	local fusion_params={
			handler=c,
			matfilter=function(c) return c:IsRace(RACE_ROCK) end,
			gc=Fusion.ForcedHandler
		}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfReveal)
	e2:SetTarget(Fusion.SummonEffTG(fusion_params))
	e2:SetOperation(Fusion.SummonEffOP(fusion_params))
	c:RegisterEffect(e2)
	--Send 1 Level 8 "Magna Warrior" monster from your Deck to your GY
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,2))
	e3a:SetCategory(CATEGORY_TOGRAVE)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3a:SetProperty(EFFECT_FLAG_DELAY)
	e3a:SetCode(EVENT_SUMMON_SUCCESS)
	e3a:SetCountLimit(1,{id,1})
	e3a:SetTarget(s.tgtg)
	e3a:SetOperation(s.tgop)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3b)
end
s.listed_series={SET_MAGNA_WARRIOR}
function s.atknegcon(e,tp,eg,ep,ev,re,r,rp)
	local bc1=Duel.GetAttacker()
	local bc2=Duel.GetAttackTarget()
	return bc1:IsAttribute(ATTRIBUTE_EARTH) and bc2 and bc2:IsAttribute(ATTRIBUTE_EARTH) and bc2:IsFaceup()
end
function s.tgfilter(c)
	return c:IsLevel(8) and c:IsSetCard(SET_MAGNA_WARRIOR) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
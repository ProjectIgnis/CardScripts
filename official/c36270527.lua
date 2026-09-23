--無限と有限のアルス＝マグナ
--Ars Magna of Infinity and Finity
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--You can banish this card from your hand; add 1 non-Warrior "Ars Magna" monster from your Deck to your hand, also the original ATK of "Power Patron" Link Monsters you control become tripled for the rest of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.SelfBanish)
	e1:SetTarget(s.thatktg)
	e1:SetOperation(s.thatkop)
	c:RegisterEffect(e1)
	--If a Fusion and/or Link Monster(s) is Special Summoned while this card is banished: You can Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(aux.FaceupFilter(Card.IsType,TYPE_FUSION|TYPE_LINK),1,nil)
	end)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end)
	c:RegisterEffect(e2)
	--If you control a "Power Patron" Link Monster: You can target 1 monster on the field; banish it
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,2))
	e3a:SetCategory(CATEGORY_REMOVE)
	e3a:SetType(EFFECT_TYPE_IGNITION)
	e3a:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetCountLimit(1,{id,2})
	e3a:SetCondition(aux.AND(s.bancon,aux.NOT(s.citrinitascon)))
	e3a:SetTarget(s.bantg)
	e3a:SetOperation(s.banop)
	c:RegisterEffect(e3a)
	--Quick version if the effect of "Ars Magna - "Citrinitas"" is applying
	local e3b=e3a:Clone()
	e3b:SetType(EFFECT_TYPE_QUICK_O)
	e3b:SetCode(EVENT_FREE_CHAIN)
	e3b:SetCondition(aux.AND(s.bancon,s.citrinitascon))
	e3b:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e3b)
end
s.listed_series={SET_ARS_MAGNA,SET_POWER_PATRON}
function s.thfilter(c)
	return c:IsSetCard(SET_ARS_MAGNA) and c:IsMonster() and c:IsRaceExcept(RACE_WARRIOR) and c:IsAbleToHand()
end
function s.thatktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,0)
end
function s.thatkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	local c=e:GetHandler()
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,3))
	--Also the original ATK of "Power Patron" Link Monsters you control become tripled for the rest of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c)
		return c:IsSetCard(SET_POWER_PATRON) and c:IsLinkMonster()
	end)
	e1:SetValue(function(e,c)
		return c:GetBaseAttack()*3
	end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.citrinitascon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,EFFECT_ARS_MAGNA_CITRINITAS)
end
function s.powerpatronfilter(c)
	return c:IsSetCard(SET_POWER_PATRON) and c:IsLinkMonster() and c:IsFaceup()
end
function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.powerpatronfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
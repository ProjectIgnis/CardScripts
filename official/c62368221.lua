--浄化と腐敗のアルス＝マグナ
--Ars Magna of Purification and Corruption
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--You can banish this card from your hand; add 1 "Ars Magna" Spell/Trap from your Deck to your hand, also until the end of the next turn, the first 3 times each of your "Power Patron" Link Monsters would be destroyed by battle each turn, it is not destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.SelfBanish)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--If an Xyz and/or Link Monster(s) is Special Summoned while this card is banished: You can Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(aux.FaceupFilter(Card.IsType,TYPE_XYZ|TYPE_LINK),1,nil)
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
	--You can target Spells/Traps on the field up to the number of "Power Patron" Link Monsters you control; banish them
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,2))
	e3a:SetCategory(CATEGORY_REMOVE)
	e3a:SetType(EFFECT_TYPE_IGNITION)
	e3a:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetCountLimit(1,{id,2})
	e3a:SetCondition(aux.NOT(s.citrinitascon))
	e3a:SetTarget(s.bantg)
	e3a:SetOperation(s.banop)
	c:RegisterEffect(e3a)
	--Quick version if the effect of "Ars Magna - "Citrinitas"" is applying
	local e3b=e3a:Clone()
	e3b:SetType(EFFECT_TYPE_QUICK_O)
	e3b:SetCode(EVENT_FREE_CHAIN)
	e3b:SetCondition(s.citrinitascon)
	e3b:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e3b)
end
s.listed_series={SET_ARS_MAGNA,SET_POWER_PATRON}
function s.thfilter(c)
	return c:IsSetCard(SET_ARS_MAGNA) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
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
	local c=e:GetHandler()
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,3),nil,2)
	--Also until the end of the next turn, the first 3 times each of your "Power Patron" Link Monsters would be destroyed by battle each turn, it is not destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCountLimit(3)
	e1:SetValue(function(e,re,r,rp)
		return r&REASON_BATTLE==REASON_BATTLE
	end)
	e1:SetTarget(function(e,c)
		return c:IsSetCard(SET_POWER_PATRON) and c:IsLinkMonster()
	end)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end
function s.citrinitascon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,EFFECT_ARS_MAGNA_CITRINITAS)
end
function s.powerpatronfilter(c)
	return c:IsSetCard(SET_POWER_PATRON) and c:IsLinkMonster() and c:IsFaceup()
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsSpellTrap() and chkc:IsAbleToRemove() end
	local power_patron_count=Duel.GetMatchingGroupCount(s.powerpatronfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return power_patron_count>0 and Duel.IsExistingTarget(aux.AND(Card.IsSpellTrap,Card.IsAbleToRemove),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,aux.AND(Card.IsSpellTrap,Card.IsAbleToRemove),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,power_patron_count,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,tp,0)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
--魔導書の賢才バテル
--Spellbook Genius of Prophecy
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is added to your hand, except by drawing it: You can Special Summon it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsPreviousLocation(LOCATION_DECK) and not e:GetHandler():IsReason(REASON_DRAW)
	end)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	--If you have "Regulus, the Prince of Endymion" in your field or GY: You can banish 1 Spell from your GY; Special Summon 1 monster from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_REGULUS_THE_PRINCE_OF_ENDYMION),tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
	end)
	e2:SetCost(s.banishspellcost)
	e2:SetTarget(s.handsptg)
	e2:SetOperation(s.handspop)
	c:RegisterEffect(e2)
	--During the Battle Phase (Quick Effect): You can banish 1 Spell from your GY, then target 1 face-up monster on the field; change it to face-down Defense Position
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_SET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsBattlePhase()
	end)
	e3:SetCost(s.banishspellcost)
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	e3:SetHintTiming(0,TIMING_BATTLE_START|TIMING_BATTLE_PHASE|TIMING_BATTLE_END)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_REGULUS_THE_PRINCE_OF_ENDYMION}
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.banishspellcostfilter(c)
	return c:IsSpell() and c:IsAbleToRemoveAsCost()
end
function s.banishspellcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.banishspellcostfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.banishspellcostfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.handspfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.handsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.handspfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.handspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.handspfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanTurnSet() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,tp,POS_FACEDOWN_DEFENSE)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsMonster() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
--大いなる三賢者
--Trinitas Magistus
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ Spellcaster monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),2)
	--If this card is Special Summoned from the Extra Deck: You can equip 1 "Magistus" or Spellcaster monster from your Extra Deck to this card as an Equip Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
	end)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,function(ec,_,tp) return s.eqfilter(ec,tp) end,s.equipop,e1)
	--You can discard 1 card; return all Fusion, Synchro, Xyz, and Link Monsters from your opponent's field and GY to the Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.Discard())
	e2:SetTarget(s.textg)
	e2:SetOperation(s.texop)
	c:RegisterEffect(e2)
	--During your opponent's Main Phase (Quick Effect): You can add 1 "Magistus" card from your GY or banishment to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsMainPhase(1-tp)
	end)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	e3:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MAGISTUS}
local TYPES_FUSION_SYNCHRO_XYZ_LINK=TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK
function s.eqfilter(c,tp)
	return (c:IsSetCard(SET_MAGISTUS) or c:IsRace(RACE_SPELLCASTER)) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_EXTRA)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
		if ec then
			s.equipop(c,e,tp,ec)
		end
	end
end
function s.equipop(c,e,tp,ec)
	c:EquipByEffectAndLimitRegister(e,tp,ec,id,true)
end
function s.texfilter(c)
	return c:IsType(TYPES_FUSION_SYNCHRO_XYZ_LINK) and c:IsMonster() and c:IsFaceup() and c:IsAbleToExtra()
end
function s.textg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.texfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,1-tp,LOCATION_MZONE|LOCATION_GRAVE)
end
function s.texop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.texfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_MAGISTUS) and c:IsFaceup() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
--海晶乙女神流
--Marincess Overflow
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Target Spells/Traps on the field up to the number of "Marincess" Link Monsters you control; destroy them
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--You can banish this card from your GY; send 1 Link-3 or higher "Marincess" Link Monster Card you control to the GY, then you can Special Summon 1 WATER Cyberse Ritual Monster from your hand or GY (this is treated as a Ritual Summon)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
	--If you control a Link-3 or higher "Marincess" Link Monster, you can activate this card from your hand
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(function(e)
		return Duel.GetMatchingGroup(s.marincesslinkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil):IsExists(Card.IsLinkAbove,1,nil,3)
	end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MARINCESS}
function s.marincesslinkfilter(c)
	return c:IsSetCard(SET_MARINCESS) and c:IsLinkMonster() and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsSpellTrap() and chkc~=c end
	local max_target_count=Duel.GetMatchingGroupCount(s.marincesslinkfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return max_target_count>0 and Duel.IsExistingTarget(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,max_target_count,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
function s.tgfilter(c)
	return c:IsSetCard(SET_MARINCESS) and c:IsOriginalType(TYPE_LINK) and c:IsMonsterCard() and c:IsLinkAbove(3) and c:IsAbleToGrave() and c:IsFaceup()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_CYBERSE) and c:IsRitualMonster()
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	if Duel.SendtoGrave(sc,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local rc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if not rc then return end
		Duel.BreakEffect()
		if Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)>0 then
			rc:CompleteProcedure()
		end
	end
end
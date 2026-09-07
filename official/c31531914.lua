--破械式鬼シュマ
--Unchained Ogre Shma
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Normal Summoned: You can Special Summon 1 Level 4 or lower "Unchained" monster from your Deck, except "Unchained Ogre Shma", then destroy 1 card you control, also you cannot Special Summon for the rest of this turn, except Fiend monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.lv4sptg)
	e1:SetOperation(s.lv4spop)
	c:RegisterEffect(e1)
	--If this card on the field is destroyed by card effect, except "Unchained Ogre Shma", or by battle: You can Special Summon 1 "Unchained" monster from your hand or Deck, except "Unchained Ogre Shma"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.handdeckspcon)
	e2:SetTarget(s.handdecksptg)
	e2:SetOperation(s.handdeckspop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_UNCHAINED}
s.listed_names={id}
function s.lv4spfilter(c,e,tp)
	return c:IsLevelBelow(4) and s.unchainedspfilter(c,e,tp)
end
function s.unchainedspfilter(c,e,tp)
	return c:IsSetCard(SET_UNCHAINED) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.lv4sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.lv4spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.lv4spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.lv4spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
			if #dg>0 then
				Duel.HintSelection(dg)
				Duel.BreakEffect()
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
	local c=e:GetHandler()
	--You cannot Special Summon for the rest of this turn, except Fiend monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsRaceExcept(RACE_FIEND) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--"Clock Lizard" check
	aux.addTempLizardCheck(c,tp,function(e,c) return not c:IsOriginalRace(RACE_FIEND) end)
end
function s.handdeckspcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_BATTLE|REASON_EFFECT)) then return false end
	if c:IsReason(REASON_BATTLE) then
		return true
	elseif c:IsReason(REASON_EFFECT) then
		local rc=re:GetHandler()
		if Duel.IsChainSolving() then
			if rc==c then
				return not c:IsPreviousCodeOnField(id)
			else
				if rc:IsRelateToEffect(re) and rc:IsFaceup() then
					return not rc:IsCode(id)
				else
					local code1,code2=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
					return code1~=id and code2~=id
				end
			end
		else
			return not rc:IsCode(id)
		end
	end
	return false
end
function s.handdecksptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.unchainedspfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.handdeckspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.unchainedspfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
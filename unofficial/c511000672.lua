--ファイヤー・ウイップ
--Fire Whip
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon all monsters that were destroyed this turn to your field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
local LOCATION_HDGRE=LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_EXTRA
function s.confilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_FIEND)
end
function s.spfilter(c,e,tp,tid)
	return c:IsReason(REASON_DESTROY) and c:GetTurnID()==tid and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tid=Duel.GetTurnCount()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HDGRE,LOCATION_HDGRE,nil,e,tp,tid)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>#g-1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HDGRE,LOCATION_HDGRE,1,nil,e,tp,tid) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,tp,LOCATION_HDGRE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HDGRE,LOCATION_HDGRE,nil,e,tp,Duel.GetTurnCount())
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if ft<=#g-1 then return end
	if #g>0 then
		for tc in g:Iter() do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			--Those monsters become FIRE Attribute
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(ATTRIBUTE_FIRE)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
			--Their effects are negated
			tc:NegateEffects(e:GetHandler())
		end
		Duel.SpecialSummonComplete()
	end
end

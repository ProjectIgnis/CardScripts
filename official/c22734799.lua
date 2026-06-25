--三幻魔の操世者
--The Orchestrator of the Sacred Beasts
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--You can reveal this card in your hand; discard 1 card, and if you do, Special Summon 1 "Sacred Beast" monster from your hand in Defense Position, except a Level 8 monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.sptg(LOCATION_HAND))
	e1:SetOperation(s.spop(LOCATION_HAND))
	c:RegisterEffect(e1)
	--You can discard 1 card; Special Summon 1 "Sacred Beast" monster from your hand or GY in Defense Position, except a Level 8 monster or the discarded card
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.Discard(nil,false,1,1,function(e,tp,og) local oc=og:GetFirst() oc:CreateEffectRelation(e) e:SetLabelObject(oc) end))
	e2:SetTarget(s.sptg(LOCATION_HAND|LOCATION_GRAVE))
	e2:SetOperation(s.spop(LOCATION_HAND|LOCATION_GRAVE))
	c:RegisterEffect(e2)
	--You can banish this card from your GY; Special Summon 1 "Sacred Beast" monster from your GY in Defense Postion, except a Level 8 monster
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.sptg(LOCATION_GRAVE))
	e3:SetOperation(s.spop(LOCATION_GRAVE))
	c:RegisterEffect(e3)
end
s.listed_series={SET_SACRED_BEAST}
function s.discardfilter(c,e,tp)
	return c:IsDiscardable(REASON_EFFECT) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SACRED_BEAST) and not c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,true,POS_FACEUP_DEFENSE)
end
function s.sptg(summon_location)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
			if summon_location==LOCATION_HAND then
				return Duel.IsExistingMatchingCard(s.discardfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
			else
				return Duel.IsExistingMatchingCard(s.spfilter,tp,summon_location,0,1,e:GetHandler(),e,tp)
			end
		end
		if summon_location==LOCATION_HAND then
			Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
		end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,summon_location)
	end
end
function s.spop(summon_location)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if summon_location==LOCATION_HAND and Duel.DiscardHand(tp,s.discardfilter,1,1,REASON_EFFECT|REASON_DISCARD,nil,e,tp)<0 then return end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local exc=nil
		if summon_location==LOCATION_HAND|LOCATION_GRAVE then
			local cost_card=e:GetLabelObject()
			exc=cost_card:IsRelateToEffect(e) and cost_card or nil
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,summon_location,0,1,1,exc,e,tp):GetFirst()
		if sc and Duel.SpecialSummon(sc,0,tp,tp,false,true,POS_FACEUP_DEFENSE)>0 then
			sc:CompleteProcedure()
		end
	end
end
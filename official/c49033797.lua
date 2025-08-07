--禁断のトラペゾヘドロン
--Forbidden Trapezohedron
local s,id=GetID()
function s.initial_effect(c)
	--Apply the following effect based on the card types you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_OUTER_ENTITY,SET_ELDER_ENTITY,SET_OLD_ENTITY}
function s.outerfilter(c,e,tp)
	return c:IsSetCard(SET_OUTER_ENTITY) and c:IsXyzMonster() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.elderfilter(c,e,tp)
	return c:IsSetCard(SET_ELDER_ENTITY) and c:IsFusionMonster() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.oldfilter(c,e,tp)
	return c:IsSetCard(SET_OLD_ENTITY) and c:IsSynchroMonster() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local flag=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):GetBitwiseOr(function(c) return c:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ) end)
		if flag==(TYPE_FUSION|TYPE_SYNCHRO) then
			return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingMatchingCard(s.outerfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		elseif flag==(TYPE_SYNCHRO|TYPE_XYZ) then
			return Duel.IsExistingMatchingCard(s.elderfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		elseif flag==(TYPE_XYZ|TYPE_FUSION) then
			return Duel.IsExistingMatchingCard(s.oldfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		else
			return false
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local flag=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):GetBitwiseOr(function(c) return c:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ) end)
	if flag==(TYPE_FUSION|TYPE_SYNCHRO) then
		--● Fusion and Synchro: Special Summon 1 "Outer Entity" Xyz Monster from your Extra Deck, and if you do, attach this card to it as material
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.outerfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
			local c=e:GetHandler()
			if c:IsRelateToEffect(e) then
				c:CancelToGrave()
				Duel.Overlay(sc,c)
			end
		end
	elseif flag==(TYPE_SYNCHRO|TYPE_XYZ) then
		--● Synchro and Xyz: Special Summon 1 "Elder Entity" Fusion Monster from your Extra Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.elderfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif flag==(TYPE_XYZ|TYPE_FUSION) then
		--● Xyz and Fusion: Special Summon 1 "Old Entity" Synchro Monster from your Extra Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.oldfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
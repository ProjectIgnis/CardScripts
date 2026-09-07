--神風のドラグニティ
--Dragunity Divine Wind
--scripted by pyrQ
local s,id=GetID()
local CARD_DRAGON_RAVINE=62265044
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Apply 1 of these effects, or if "Dragon Ravine" is in your GY, you can apply any of them, in sequence
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_DRAGON_RAVINE}
s.listed_series={SET_DRAGUNITY}
function s.thfilter(c)
	return c:IsRace(RACE_DRAGON|RACE_WINGEDBEAST) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_DRAGUNITY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		return b1 or b2
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.eqfilter(c,tp)
	return c:IsRace(RACE_DRAGON) and c:IsSetCard(SET_DRAGUNITY) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local ravine_chk=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_DRAGON_RAVINE)
	local op=nil
	if not ravine_chk then
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
	end
	local breakeffect=false
	if (op and op==1) or (ravine_chk and b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(id,3)))) then
		--Add 1 Dragon or Winged Beast monster from your GY to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ShuffleHand(tp)
			b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		end
		breakeffect=true
	end
	if (op and op==2) or (ravine_chk and b2 and (not breakeffect or Duel.SelectYesNo(tp,aux.Stringid(id,4)))) then
		--Special Summon 1 "Dragunity" monster from your hand, then you can equip 1 Dragon "Dragunity" monster from your Deck to it as an Equip Spell
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
		if sc then
			if breakeffect then Duel.BreakEffect() end
			if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
				and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,tp)
				and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
				if not ec then return end
				Duel.BreakEffect()
				if Duel.Equip(tp,ec,sc) then
					--Equip limit
					local e0=Effect.CreateEffect(e:GetHandler())
					e0:SetType(EFFECT_TYPE_SINGLE)
					e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e0:SetCode(EFFECT_EQUIP_LIMIT)
					e0:SetValue(function(e,c) return c==sc end)
					e0:SetReset(RESET_EVENT|RESETS_STANDARD)
					ec:RegisterEffect(e0)
				end
			end
		end
	end
end
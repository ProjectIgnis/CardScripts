--レーナのキノコスープ
--Lena's Mushroom Soup
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Choose 1 face-up monster on the field. While that monster is face-up, it loses 700 ATK. If you chose a "Doomed by the Blackblight" on your field by this effect, you can Ritual Summon a Level 1 DARK Attribute Warrior Type monster by sending the chosen monster to the Graveyard as material.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_DOOMED_BY_THE_BLACKBLIGHT}--"Doomed by the Blackblight"
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WARRIOR)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,LOCATION_MZONE)
end
function s.ritualfilter(c,e,tp,mat_c)
	return c:IsRitualMonster() and c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WARRIOR)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
		and Duel.GetLocationCountFromEx(tp,tp,mat_c,c)>0
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local tc=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	Duel.HintSelection(tc)
	if tc then
		--It loses 700 ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(-700)
		tc:RegisterEffect(e1)
		--If you chose a "Doomed by the Blackblight" on your field by this effect, you can Ritual Summon a Level 1 DARK Attribute Warrior Type monster by sending the chosen monster to the Graveyard as material
		if tc:IsCode(CARD_DOOMED_BY_THE_BLACKBLIGHT)
			and Duel.IsExistingMatchingCard(s.ritualfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,tc)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=Duel.SelectMatchingCard(tp,s.ritualfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
			if sc and Duel.SendtoGrave(tc,REASON_MATERIAL|REASON_RITUAL)>0 then
				Duel.SpecialSummon(sc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
				sc:SetMaterial(tc)
				sc:CompleteProcedure()
			end
		end
	end
end
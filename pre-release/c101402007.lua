--ゴルゴニック・アンブラル
--Gorgonic Umbral Horror
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--You cannot Special Summon from the Extra Deck, except "Number" Xyz Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c)
		return c:IsLocation(LOCATION_EXTRA) and not (c:IsSetCard(SET_NUMBER) and c:IsXyzMonster())
	end)
	c:RegisterEffect(e1)
	aux.addContinuousLizardCheck(c,LOCATION_MZONE,function(e,c) return not (c:IsOriginalType(TYPE_XYZ) and c:IsOriginalSetCard(SET_NUMBER)) end)
	--If you control no monsters, or all monsters you control are "Umbral Horror" monsters: You can Special Summon this card from your hand, and if you do, add 1 non-Rock "Umbral Horror" monster from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Can be treated as 2 materials for the Xyz Summon of a "Number" Xyz Monster that requires 3 or more materials
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DOUBLE_XYZ_MATERIAL)
	e3:SetValue(1)
	e3:SetCountLimit(1,{id,1})
	e3:SetOperation(function(e,c)
		return c.minxyzct and c.minxyzct>=3 and c:IsSetCard(SET_NUMBER)
	end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_NUMBER,SET_UMBRAL_HORROR}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g==0 or #g==g:FilterCount(aux.FaceupFilter(Card.IsSetCard,SET_UMBRAL_HORROR),nil)
end
function s.thfilter(c)
	return c:IsSetCard(SET_UMBRAL_HORROR) and c:IsMonster() and not c:IsRace(RACE_ROCK) and c:IsAbleToHand()
end 
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #sc>0 and Duel.SendtoHand(sc,tp,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,sc)
		end
	end
end
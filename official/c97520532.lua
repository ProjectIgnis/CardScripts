--ギミック・パペット－キメラ・ドール
--Gimmick Puppet Chimera Doll
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon Procedure
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),2,2)
	--Take 1 "Gimmick Puppet" monster from your Deck, and either add it to your hand or send it to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GIMMICK_PUPPET}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.filter(c)
	return c:IsSetCard(SET_GIMMICK_PUPPET) and c:IsMonster() and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_GIMMICK_PUPPET) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		aux.ToHandOrElse(tc,tp)
		local fg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
		local hg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if #fg>0 and fg:FilterCount(aux.FaceupFilter(Card.IsSetCard,SET_GIMMICK_PUPPET),nil)==#fg 
			and #hg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=hg:Select(tp,1,1,nil)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local c=e:GetHandler()
	--Cannot Special Summon monsters from the Extra Deck for the rest of this turn
	local ge1=Effect.CreateEffect(c)
	ge1:SetDescription(aux.Stringid(id,3))
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	ge1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	ge1:SetTargetRange(1,0)
	ge1:SetTarget(s.splimit)
	ge1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(ge1,tp)
	--lizard check
	aux.addTempLizardCheck(c,tp,s.lizfilter)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE)) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not (c:IsOriginalType(TYPE_XYZ) and c:IsOriginalRace(RACE_MACHINE))
end
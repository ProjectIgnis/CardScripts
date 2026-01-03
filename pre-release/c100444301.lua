--大輪の霊使い
--Charmers of the Grand Circle
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 2+ "Charmer" and/or "Familiar-Possessed" monsters
	Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,{SET_CHARMER,SET_FAMILIAR_POSSESSED}),2,99)
	--Keep track of the number of different original Attributes of the monsters used as its material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(function(e,c) e:SetLabel(c:GetMaterial():GetClassCount(Card.GetOriginalAttribute)) end)
	c:RegisterEffect(e0)
	--Repeat the process of applying 1 of these effects, up to the number of different original Attributes of the monsters used as its material (max. 4)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
end
s.listed_series={SET_CHARMER,SET_FAMILIAR_POSSESSED,SET_POSSESSED}
s.material_setcode={SET_CHARMER,SET_FAMILIAR_POSSESSED}
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local material_check_eff=e:GetLabelObject()
	local label=material_check_eff:GetLabel()
	if chk==0 then return label>0 end
	material_check_eff:SetLabel(0)
	Duel.SetTargetParam(label)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,800)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:IsSetCard(SET_POSSESSED) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1,b2,b3,b4,b5,op
	local max_count=math.min(Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM),4)
	local remaining_count=max_count
	repeat
		b1=c:IsRelateToEffect(e) and c:IsFaceup()
		b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		b3=Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		b4=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		if not (b1 or b2 or b3 or b4) then return end
		b5=remaining_count<max_count
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)},
			{b3,aux.Stringid(id,3)},
			{b4,aux.Stringid(id,4)},
			{b5,aux.Stringid(id,5)})
		remaining_count=remaining_count-1
		if op==1 then
			--This card gains 800 ATK
			c:UpdateAttack(800)
		elseif op==2 then
			--Add 1 "Possessed" Spell/Trap from your Deck to your hand
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		elseif op==3 then
			--Return 1 card on the field to the hand
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.SendtoHand(g,nil,REASON_EFFECT)
			end
		elseif op==4 then
			--Special Summon 1 Spellcaster monster from your GY
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif op==5 then
			--Finish applying effects
			return
		end
	until remaining_count==0
end
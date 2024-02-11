--ギャラクティカ・デジャヴュ
--Galactica Deja Vu
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send the top card of your Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(1-tp)>=4000
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.SendtoGrave(e:GetHandler(),REASON_COST)<1 then return end
	--Effect
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	local ct=g:GetFirst()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ct and ct:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and ct:IsType(TYPE_NORMAL) and ct:IsRace(RACE_GALAXY) and ct:IsAttribute(ATTRIBUTE_LIGHT) and ct:IsLevelBelow(4)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.SpecialSummon(ct,0,tp,tp,false,false,POS_FACEUP)
		local atk=ct:GetBaseAttack()
		if atk>0 then
			Duel.BreakEffect()
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end

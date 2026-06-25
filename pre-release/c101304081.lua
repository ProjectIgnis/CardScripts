--JP name
--Gaming Gamer GG
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 4 Machine monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),4,2)
	--If this card is Special Summoned: You can change all monsters your opponent controls to Attack Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	--If your opponent has a monster in their field or GY: You can detach 1 material from this card; send 1 Machine monster from your Deck/Extra Deck to the GY, then you can apply this effect: ● Choose 1 Machine Xyz Monster in your GY, and this card's name becomes that monster's name until the End Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil) end)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsDefensePos,Card.IsCanChangePosition),tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,tp,POS_FACEUP_ATTACK)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsDefensePos,Card.IsCanChangePosition),tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	end
end
function s.tgfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.namefilter(c,current_name)
	return c:IsRace(RACE_MACHINE) and c:IsXyzMonster() and not c:IsCode(current_name)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=c:GetCode()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if sc and Duel.SendtoGrave(sc,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.namefilter,tp,LOCATION_GRAVE,0,1,nil,code)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		local xyz=Duel.SelectMatchingCard(tp,s.namefilter,tp,LOCATION_GRAVE,0,1,1,nil,code):GetFirst()
		if not xyz then return end
		Duel.HintSelection(xyz)
		Duel.BreakEffect()
		--This card's name becomes that monster's name until the End Phase
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(xyz:GetCode())
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
		--Reset the card's name manually during the End Phase
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,4))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1)
		e2:SetOperation(function(e)
				e1:Reset()
				Duel.HintSelection(c)
				Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
			end)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e2)
	end
end
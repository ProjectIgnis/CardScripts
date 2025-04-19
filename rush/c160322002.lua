--ハーピィ・レディ・ＦＤ
--Harpie Lady Feather Duster
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,nil,nil,SUMMON_TYPE_FUSION,nil,false)
	--Name change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_HARPIE_LADY}
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsCode(CARD_HARPIE_LADY) and c:IsLevel(4)
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_WINGEDBEAST,fc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_WIND,fc,sumtype,tp) and c:IsType(TYPE_NORMAL)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsCode(CARD_HARPIE_LADY) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	local c=e:GetHandler()
	--Name becomes "Cyber Dragon"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(CARD_HARPIE_LADY)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
	if c:IsStatus(STATUS_SPSUMMON_TURN) and Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.HintSelection(dg)
		Duel.BreakEffect()
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
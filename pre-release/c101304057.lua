--絶無なる獄神界－ヴィードリア
--Null Power Patron Realm - Vidria
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--You can reveal 1 "Power Patron" monster in your Extra Deck; banish (face-down) 1 card from your hand, then add to your hand, or Special Summon, 1 monster from your Deck that mentions the revealed monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.Reveal(s.revealfilter,false,1,1,function(e,tp,g) e:SetLabel(g:GetFirst():GetCode()) end,LOCATION_EXTRA))
	e1:SetTarget(s.thsptg)
	e1:SetOperation(s.thspop)
	c:RegisterEffect(e1)
	--Monsters your opponent controls lose 100 ATK for each banished card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(function(e,c) return -100*Duel.GetFieldGroupCount(0,LOCATION_REMOVED,LOCATION_REMOVED) end)
	c:RegisterEffect(e2)
	--Your opponent cannot activate card effects in the GY while you control "Nerva the Power Patron of Creation", "Jupiter the Power Patron of Destruction", and "Junora the Power Patron of Tuning"
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.cannotactcon)
	e3:SetValue(function(e,re,tp) return re:GetActivateLocation()==LOCATION_GRAVE end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_POWER_PATRON}
s.listed_names={53589300,68231287,5914858} --"Nerva the Power Patron of Creation", "Jupiter the Power Patron of Destruction", "Junora the Power Patron of Tuning"
function s.cannotactcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,53589300),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,68231287),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,5914858),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.revealfilter(c,e,tp)
	return c:IsSetCard(SET_POWER_PATRON) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode(),Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
function s.thspfilter(c,e,tp,code,mmz_chk)
	return c:ListsCode(code) and (c:IsAbleToHand() or (mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil,nil,POS_FACEDOWN) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil,nil,POS_FACEDOWN)
	if #g==0 or Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)==0 then return end
	local code=e:GetLabel()
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local sc=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,code,mmz_chk):GetFirst()
	if not sc then return end
	Duel.BreakEffect()
	aux.ToHandOrElse(sc,tp,
		function()
			return mmz_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function()
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,2)
	)
end
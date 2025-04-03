--Japanese name
--Mimighoul Maker
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Reveal 2 Flip monsters to Special Summon or add to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.revtg)
	e1:SetOperation(s.revop)
	c:RegisterEffect(e1)
	--Change 1 face-down monster to face-up Attack or Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp,eg) return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MIMIGHOUL}
function s.revfilter(c,e,tp)
	return c:IsType(TYPE_FLIP) and not c:IsPublic()
		and c:IsAbleToHand() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)==0 then return false end
		local g=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_DECK,0,nil,e,tp)
		return aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_MIMIGHOUL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)==0 then return end
	local g=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_DECK,0,nil,e,tp)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_SELECT)
	if #sg~=2 then return end
	Duel.ConfirmCards(1-tp,sg)
	local sc=sg:RandomSelect(1-tp,1):GetFirst()
	if not sc or Duel.SpecialSummon(sc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)==0 then return end
	Duel.ConfirmCards(tp,sc)
	sg:RemoveCard(sc)
	if Duel.SendtoHand(sg,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	local hg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if #hg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local hsg=hg:Select(tp,1,1,nil)
	if #hsg>0 then
		Duel.BreakEffect()
		Duel.SpecialSummon(hsg,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFacedown() and chkc:IsCanChangePosition() end
	if chk==0 then return Duel.IsExistingTarget(aux.AND(Card.IsFacedown,Card.IsCanChangePosition),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,aux.AND(Card.IsFacedown,Card.IsCanChangePosition),tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,tp,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local pos=(POS_FACEUP_ATTACK|POS_FACEUP_DEFENSE)&~tc:GetPosition()
		pos=Duel.SelectPosition(tp,tc,pos)
		Duel.ChangePosition(tc,pos)
	end
end
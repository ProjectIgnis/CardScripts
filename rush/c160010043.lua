-- Ａくま・リリス
-- Diabearical Lilith
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- "Ama Lilith" + "A.I. Bear Can"
	Fusion.AddProcMix(c,true,true,160428042,160428037)
	-- Return 1 monster to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if not tc then return end
	Duel.HintSelection(tc,true)
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 or not tc:IsLocation(LOCATION_HAND) then return end
	local opp=1-tp
	local g=Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,opp,LOCATION_HAND,0,nil,e,0,opp,false,false,POS_FACEUP_ATTACK)
	if #g==0 or not Duel.SelectYesNo(opp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SELECTMSG,opp,HINTMSG_SPSUMMON)
	local sg=g:Select(opp,1,1,nil)
	if #sg>0 then
		Duel.BreakEffect()
		Duel.SpecialSummon(sg,0,opp,opp,false,false,POS_FACEUP_ATTACK)
	end
end
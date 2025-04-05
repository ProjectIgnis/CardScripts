--エクシーズ・フォース
--Xyz Force
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 "Xyz" card to the GY or add it to the hand if an Xyz monster with an Xyz monster as material is on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--Detach 1 material from an Xyz, then you can Special Summon it if it is an Xyz Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.exccon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.detachtg)
	e2:SetOperation(s.detachop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_XYZ}
s.listed_names={id}
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_XYZ)
end
function s.cfilter(c,to_hand)
	return c:IsSetCard(SET_XYZ) and not c:IsCode(id) and (c:IsAbleToGrave() or (to_hand and c:IsAbleToHand()))
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local to_hand=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil,to_hand) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local to_hand=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local hintmsg=to_hand and aux.Stringid(id,2) or HINTMSG_TOGRAVE
	Duel.Hint(HINT_SELECTMSG,tp,hintmsg)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil,to_hand):GetFirst()
	if not tc then return end
	if to_hand and tc:IsAbleToHand() then
		aux.ToHandOrElse(tc,tp)
	else
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
function s.detachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED|LOCATION_GRAVE)
end
function s.detachop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)==0 then return end
	local sc=Duel.GetOperatedGroup():GetFirst()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsControler(tp) and sc:IsMonster()
		and sc:IsType(TYPE_XYZ) and sc:IsLocation(LOCATION_REMOVED|LOCATION_GRAVE)
		and sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and aux.nvfilter(sc)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
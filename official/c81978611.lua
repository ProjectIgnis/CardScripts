--エクシーズ・エントラスト
--Xyz Entrust
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Armored Xyz" card from the Deck/GY to the hand and change the levels of up to 2 monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Special Summon 1 Xyz Monster treated as an Equip Card from your S/T Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ARMORED_XYZ}
function s.thfilter(c)
	return c:IsSetCard(SET_ARMORED_XYZ) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_LVCHANGE,nil,1,tp,0)
end
function s.rescon(sg,e,tp,mg)
	return not (sg:IsExists(Card.IsLevel,1,nil,3) and sg:IsExists(Card.IsLevel,1,nil,5))
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local thg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #thg>0 and Duel.SendtoHand(thg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,thg)
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.HasLevel),tp,LOCATION_MZONE,0,nil)
		if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
		local sg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_FACEUP)
		if #sg==0 then return end
		Duel.HintSelection(sg,true)
		local lv=(sg:IsExists(Card.IsLevel,1,nil,3) and 5)
			or (sg:IsExists(Card.IsLevel,1,nil,5) and 3)
			or Duel.AnnounceLevel(tp,3,5,4)
		local c=e:GetHandler()
		Duel.BreakEffect()
		for tc in sg:Iter() do
			--Its Level becomes 3 or 5
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
			e1:SetValue(lv)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:GetOriginalType()&TYPE_XYZ>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_STZONE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_STZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_STZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
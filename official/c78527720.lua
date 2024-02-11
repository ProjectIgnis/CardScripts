--シンデレラ
--Prinzessin
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Pumpkin Carriage from hand or Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Equip "Glass Slippers" to another monster on the field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(s.eqcon)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
end
s.listed_names={14512825,CARD_STROMBERG,9677699} --Pumpkin Carriage, Glass Slippers
function s.spfilter(c,e,tp)
	return c:IsCode(14512825) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.eqfilter1(c,ec)
	return c:IsCode(9677699) and c:CheckEquipTarget(ec) and not c:IsForbidden()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsControler(tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_STROMBERG),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.eqfilter1,tp,LOCATION_DECK,0,1,nil,e:GetHandler())
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local g2=Duel.SelectMatchingCard(tp,s.eqfilter1,tp,LOCATION_DECK,0,1,1,nil,c)
			if #g2>0 then
				Duel.BreakEffect()
				Duel.Equip(tp,g2:GetFirst(),c)
			end
		end
	end
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.GetAttackTarget()==nil
end
function s.eqfilter2(c,tc,tp)
	return c:IsCode(9677699) and tc:GetEquipGroup():IsContains(c)
		and Duel.IsExistingTarget(s.eqfilter3,tp,LOCATION_MZONE,LOCATION_MZONE,1,tc,c)
		and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.eqfilter3(c,ec)
	return c:IsFaceup() and ec:CheckEquipTarget(c)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter2,tp,LOCATION_SZONE,0,1,nil,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g1=Duel.SelectTarget(tp,s.eqfilter2,tp,LOCATION_SZONE,0,1,1,nil,c,tp)
	e:SetLabelObject(g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g2=Duel.SelectTarget(tp,s.eqfilter3,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,g1:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g1,1,tp,0)
end
function s.equal(c,tc)
	return c==tc
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==ec then tc=g:GetNext() end
	if ec:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,ec,tc)
	end
end
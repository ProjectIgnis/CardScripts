--バリアンズ・ホープ
--Barian's Hope
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Umbral Horror" monster or "Masquerade" Xyz Monster from your hand or GY, then you can make the Levels of all "Umbral Horror" monsters you control become the Level of 1 "Umbral Horror" monster in your field or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--You can banish this card from your GY, then target 1 Xyz Monster you control; attach 1 "Number" Xyz Monster from your Extra Deck or GY to it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.attachtg)
	e2:SetOperation(s.attachop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_UMBRAL_HORROR,SET_MASQUERADE,SET_NUMBER}
function s.spfilter(c,e,tp)
	return (c:IsSetCard(SET_UMBRAL_HORROR) or (c:IsSetCard(SET_MASQUERADE) and c:IsXyzMonster())) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_LVCHANGE,nil,1,tp,0)
end
function s.umbralfilter(c,umbral_group)
	return c:IsSetCard(SET_UMBRAL_HORROR) and c:HasLevel() and c:IsFaceup()
		and umbral_group:IsExists(aux.NOT(Card.IsLevel),1,c,c:GetLevel())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local umbral_group=Duel.GetMatchingGroup(aux.AND(Card.IsSetCard,Card.HasLevel,Card.IsFaceup),tp,LOCATION_MZONE,0,nil,SET_UMBRAL_HORROR)
		if #umbral_group>0 and Duel.IsExistingMatchingCard(s.umbralfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,umbral_group)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
			local sc=Duel.SelectMatchingCard(tp,s.umbralfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,umbral_group):GetFirst()
			if not sc then return end
			Duel.HintSelection(sc)
			local c=e:GetHandler()
			local lv=sc:GetLevel()
			Duel.BreakEffect()
			for tc in umbral_group:Iter() do
				--You can make the Levels of all "Umbral Horror" monsters you control become the Level of 1 "Umbral Horror" monster in your field or GY
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end
function s.xyzfilter(c,tp)
	return c:IsXyzMonster() and c:IsFaceup() and Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,tp,c)
end
function s.attachfilter(c,tp,xyzc)
	return c:IsSetCard(SET_NUMBER) and c:IsXyzMonster() and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsXyzMonster() and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.attachfilter),tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil,tp,tc):GetFirst()
		if not sc then return end
		if sc:IsLocation(LOCATION_EXTRA) then
			Duel.ConfirmCards(1-tp,sc)
		else
			Duel.HintSelection(sc)
		end
		Duel.Overlay(tc,sc)
	end
end